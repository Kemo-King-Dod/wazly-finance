import 'package:dartz/dartz.dart';
import 'package:wazly/core/errors/failures.dart';
import '../../../domain/repositories/unit_of_work.dart';
import 'app_database.dart';
import 'data_event_bus.dart';

class UnitOfWorkException implements Exception {
  final Failure failure;
  const UnitOfWorkException(this.failure);

  @override
  String toString() => 'UnitOfWorkException: $failure';
}

class DriftUnitOfWork implements UnitOfWork {
  final AppDatabase database;
  final DataEventBus eventBus;

  DriftUnitOfWork({required this.database, required this.eventBus});

  @override
  Future<Either<Failure, T>> executeTransaction<T>(
    Future<Either<Failure, T>> Function() action, {
    List<DataChangeEvent>? eventsToEmit,
  }) async {
    try {
      // Execute the entire closure within a Drift atomic transaction block.
      final finalResult = await database.transaction(() async {
        final result = await action();

        return result.fold(
          (failure) => throw UnitOfWorkException(failure), // Force SQL rollback
          (success) => Right<Failure, T>(success),
        );
      });

      // Transaction successfully committed. Emit requested CQRS events.
      if (finalResult.isRight() && eventsToEmit != null) {
        for (final event in eventsToEmit) {
          eventBus.emit(event);
        }
      }

      return finalResult;
    } on UnitOfWorkException catch (e) {
      return Left(e.failure); // Caught intentional rollback
    } catch (e) {
      return Left(GeneralFailure('Database transaction failed: $e'));
    }
  }
}

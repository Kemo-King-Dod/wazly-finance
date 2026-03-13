import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../../data/local/database/data_event_bus.dart';

/// The Unit of Work interface acts as an abstraction over database transactions.
/// It ensures that operations affecting multiple entities (e.g., adding a payment
/// which creates a Transaction AND updates the Treasury) either succeed entirely
/// or roll back entirely.
abstract class UnitOfWork {
  // Executes a block of asynchronous operations atomically.
  Future<Either<Failure, T>> executeTransaction<T>(
    Future<Either<Failure, T>> Function() action, {
    List<DataChangeEvent>? eventsToEmit,
  });
}

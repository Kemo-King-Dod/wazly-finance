import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../errors/failures.dart';
import '../../usecases/usecase.dart';
import '../entities/transaction.dart';
import '../entities/transaction_enums.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/unit_of_work.dart';
import '../../data/local/database/data_event_bus.dart';

class AddDebtParams {
  final String personId;
  final int amountInCents;
  final DebtDirection direction;
  final String description;
  final DateTime date;

  const AddDebtParams({
    required this.personId,
    required this.amountInCents,
    required this.direction,
    required this.description,
    required this.date,
  });
}

class AddDebt implements UseCase<void, AddDebtParams> {
  final TransactionRepository repository;
  final UnitOfWork unitOfWork;

  AddDebt({required this.repository, required this.unitOfWork});

  @override
  Future<Either<Failure, void>> call(AddDebtParams params) async {
    try {
      final transaction = Transaction(
        id: const Uuid().v4(),
        amountInCents: params.amountInCents,
        type: TransactionType.debt,
        direction: params.direction,
        description: params.description,
        date: params.date,
        personId: params.personId,
      );

      return await unitOfWork.executeTransaction(
        () async {
          return await repository.addTransaction(transaction);
        },
        eventsToEmit: [
          DataChangeEvent(
            DataChangeType.transactionUpdated,
            personId: params.personId,
          ),
          DataChangeEvent(
            DataChangeType.personUpdated,
            personId: params.personId,
          ),
        ],
      );
    } catch (e) {
      if (e is ArgumentError) {
        return Left(ValidationFailure(e.message));
      }
      return Left(GeneralFailure(e.toString()));
    }
  }
}

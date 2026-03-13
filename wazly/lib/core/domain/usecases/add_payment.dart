import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../errors/failures.dart';
import '../../usecases/usecase.dart';
import '../entities/transaction.dart';
import '../entities/transaction_enums.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/treasury_repository.dart';
import '../repositories/unit_of_work.dart';
import '../../data/local/database/data_event_bus.dart';

class AddPaymentParams {
  final String personId;
  final int amountInCents;
  final DebtDirection direction;
  final String description;
  final DateTime date;

  const AddPaymentParams({
    required this.personId,
    required this.amountInCents,
    required this.direction,
    required this.description,
    required this.date,
  });
}

class AddPayment implements UseCase<void, AddPaymentParams> {
  final TransactionRepository transactionRepository;
  final TreasuryRepository treasuryRepository;
  final UnitOfWork unitOfWork;

  AddPayment({
    required this.transactionRepository,
    required this.treasuryRepository,
    required this.unitOfWork,
  });

  @override
  Future<Either<Failure, void>> call(AddPaymentParams params) async {
    try {
      final transaction = Transaction(
        id: const Uuid().v4(),
        amountInCents: params.amountInCents,
        type: TransactionType.payment,
        direction: params.direction,
        description: params.description,
        date: params.date,
        personId: params.personId,
      );

      return await unitOfWork.executeTransaction(
        () async {
          // 1. Fetch current treasury
          final treasuryResult = await treasuryRepository.getTreasury();
          return treasuryResult.fold((failure) => Left(failure), (
            currentTreasury,
          ) async {
            // 2. Apply the transaction domain logic to get an updated Immutable Treasury
            final updatedTreasury = currentTreasury.applyTransaction(
              transaction,
            );

            // 3. Save the Transaction
            final txResult = await transactionRepository.addTransaction(
              transaction,
            );
            if (txResult.isLeft()) return txResult;

            // 4. Save the updated Treasury
            return await treasuryRepository.updateTreasury(updatedTreasury);
          });
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
          const DataChangeEvent(DataChangeType.treasuryUpdated),
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

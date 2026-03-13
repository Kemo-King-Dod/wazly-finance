import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/treasury_repository.dart';
import '../repositories/unit_of_work.dart';
import '../../data/local/database/data_event_bus.dart';
import 'package:equatable/equatable.dart';

class DeleteTransactionParams extends Equatable {
  final String transactionId;

  const DeleteTransactionParams({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}

class DeleteTransaction {
  final TransactionRepository transactionRepository;
  final TreasuryRepository treasuryRepository;
  final UnitOfWork unitOfWork;

  DeleteTransaction({
    required this.transactionRepository,
    required this.treasuryRepository,
    required this.unitOfWork,
  });

  Future<Either<Failure, void>> call(DeleteTransactionParams params) async {
    // We must pass the events we want to emit if the transaction succeeds
    final List<DataChangeEvent> eventsToEmit = [];

    return unitOfWork.executeTransaction(() async {
      // 1. Fetch the transaction to know its properties
      final txResult = await transactionRepository.getTransactionById(
        params.transactionId,
      );

      return txResult.fold((failure) async => Left(failure), (
        transaction,
      ) async {
        // 2. Queue events based on transaction data
        eventsToEmit.add(
          DataChangeEvent(
            DataChangeType.transactionUpdated,
            personId: transaction.personId,
          ),
        );

        if (transaction.personId != null) {
          eventsToEmit.add(
            DataChangeEvent(
              DataChangeType.personUpdated,
              personId: transaction.personId,
            ),
          );
        }

        // 3. Calculate treasury effect and reverse it if necessary
        final treasuryEffect = transaction.signedAmountForTreasury();
        if (treasuryEffect != 0) {
          final treasuryResult = await treasuryRepository.getTreasury();
          final Either<Failure, Right<Failure, void>> treasuryUpdateResult =
              await treasuryResult.fold((failure) async => Left(failure), (
                treasury,
              ) async {
                // To reverse the effect, we SUBTRACT the original signed effect
                final newBalance = treasury.balanceInCents - treasuryEffect;
                final updatedTreasury = treasury.copyWith(
                  balanceInCents: newBalance,
                );

                final updateResult = await treasuryRepository.updateTreasury(
                  updatedTreasury,
                );
                return updateResult.fold(
                  (failure) => Left(failure),
                  (_) => const Right(Right<Failure, void>(null)),
                );
              });

          if (treasuryUpdateResult.isLeft()) {
            Failure? extractedFailure;
            treasuryUpdateResult.fold((l) => extractedFailure = l, (r) => null);
            return Left(extractedFailure!);
          }

          eventsToEmit.add(
            const DataChangeEvent(DataChangeType.treasuryUpdated),
          );
        }

        // 4. Finally, delete the actual transaction record
        final deleteResult = await transactionRepository.deleteTransactionById(
          params.transactionId,
        );
        return deleteResult;
      });
    }, eventsToEmit: eventsToEmit);
  }
}

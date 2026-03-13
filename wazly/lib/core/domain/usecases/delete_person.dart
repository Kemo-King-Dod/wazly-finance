import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../errors/failures.dart';
import '../repositories/person_repository.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/installment_repository.dart';
import '../repositories/treasury_repository.dart';
import '../repositories/unit_of_work.dart';
import '../entities/transaction.dart';
import '../../data/local/database/data_event_bus.dart';

class DeletePersonParams extends Equatable {
  final String personId;

  const DeletePersonParams({required this.personId});

  @override
  List<Object?> get props => [personId];
}

class DeletePerson {
  final PersonRepository personRepository;
  final TransactionRepository transactionRepository;
  final InstallmentRepository installmentRepository;
  final TreasuryRepository treasuryRepository;
  final UnitOfWork unitOfWork;

  DeletePerson({
    required this.personRepository,
    required this.transactionRepository,
    required this.installmentRepository,
    required this.treasuryRepository,
    required this.unitOfWork,
  });

  Future<Either<Failure, void>> call(DeletePersonParams params) async {
    final List<DataChangeEvent> events = [];

    return unitOfWork.executeTransaction(() async {
      // 1. Fetch all transactions for this person
      final txResult = await transactionRepository.getTransactionsByPerson(
        params.personId,
      );
      List<Transaction> transactions = [];

      final Either<Failure, void> extractTxs = txResult.fold(
        (failure) => Left(failure),
        (txs) {
          transactions = txs;
          return const Right(null);
        },
      );

      if (extractTxs.isLeft()) return extractTxs;

      // 2. Adjust treasury
      int totalTreasuryAdjustment = 0;
      for (var tx in transactions) {
        // Payments affect treasury. We reverse their effect by subtracting.
        totalTreasuryAdjustment -= tx.signedAmountForTreasury();
      }

      if (totalTreasuryAdjustment != 0) {
        final treasuryResult = await treasuryRepository.getTreasury();
        final Either<Failure, Right<Failure, void>> treasuryUpdateResult =
            await treasuryResult.fold((failure) async => Left(failure), (
              treasury,
            ) async {
              final newBalance =
                  treasury.balanceInCents + totalTreasuryAdjustment;
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
        events.add(const DataChangeEvent(DataChangeType.treasuryUpdated));
      }

      // 3. Delete Installments
      final plansResult = await installmentRepository.getPlansByPerson(
        params.personId,
      );
      final Either<Failure, void> processPlans = await plansResult.fold(
        (failure) async => Left(failure),
        (plans) async {
          for (var plan in plans) {
            final itemsResult = await installmentRepository.deleteItemsByPlanId(
              plan.id,
            );
            if (itemsResult.isLeft()) return itemsResult;

            final planDelResult = await installmentRepository.deletePlanById(
              plan.id,
            );
            if (planDelResult.isLeft()) return planDelResult;
          }
          if (plans.isNotEmpty) {
            events.add(
              const DataChangeEvent(DataChangeType.installmentUpdated),
            );
          }
          return const Right(null);
        },
      );

      if (processPlans.isLeft()) return processPlans;

      // 4. Delete transactions
      if (transactions.isNotEmpty) {
        final txDelResult = await transactionRepository
            .deleteTransactionsByPersonId(params.personId);
        if (txDelResult.isLeft()) return txDelResult;
        events.add(const DataChangeEvent(DataChangeType.transactionUpdated));
      }

      // 5. Delete Person
      final personDelResult = await personRepository.deletePerson(
        params.personId,
      );
      if (personDelResult.isLeft()) return personDelResult;

      events.add(const DataChangeEvent(DataChangeType.personUpdated));

      return const Right(null);
    }, eventsToEmit: events);
  }
}

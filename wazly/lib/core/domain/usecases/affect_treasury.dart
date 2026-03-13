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

class AffectTreasuryParams {
  final int amountInCents;
  final TransactionType type; // Must be treasuryIn or treasuryOut
  final String description;
  final DateTime date;

  const AffectTreasuryParams({
    required this.amountInCents,
    required this.type,
    required this.description,
    required this.date,
  });
}

class AffectTreasury implements UseCase<void, AffectTreasuryParams> {
  final TransactionRepository transactionRepository;
  final TreasuryRepository treasuryRepository;
  final UnitOfWork unitOfWork;

  AffectTreasury({
    required this.transactionRepository,
    required this.treasuryRepository,
    required this.unitOfWork,
  });

  @override
  Future<Either<Failure, void>> call(AffectTreasuryParams params) async {
    try {
      if (params.type != TransactionType.treasuryIn &&
          params.type != TransactionType.treasuryOut) {
        return const Left(
          ValidationFailure(
            'AffectTreasury only accepts treasuryIn or treasuryOut types.',
          ),
        );
      }

      final transaction = Transaction(
        id: const Uuid().v4(),
        amountInCents: params.amountInCents,
        type: params.type,
        direction: null, // General treasury flow, no distinct debtor direction
        description: params.description,
        date: params.date,
        personId: null, // Not associated with a person
      );

      return await unitOfWork.executeTransaction(
        () async {
          final treasuryResult = await treasuryRepository.getTreasury();
          return treasuryResult.fold((failure) => Left(failure), (
            currentTreasury,
          ) async {
            // Ensure treasury logic applies natively
            final updatedTreasury = currentTreasury.applyTransaction(
              transaction,
            );

            // Atomic saves
            final txResult = await transactionRepository.addTransaction(
              transaction,
            );
            if (txResult.isLeft()) return txResult;

            return await treasuryRepository.updateTreasury(updatedTreasury);
          });
        },
        eventsToEmit: [
          const DataChangeEvent(DataChangeType.transactionUpdated),
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

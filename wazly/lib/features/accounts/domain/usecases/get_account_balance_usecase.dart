import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';

/// Parameters for GetAccountBalanceUseCase
class AccountBalanceParams extends Equatable {
  final String accountId;

  const AccountBalanceParams({required this.accountId});

  @override
  List<Object?> get props => [accountId];
}

/// Result containing debt assets and liabilities for an account
class AccountBalance extends Equatable {
  final double debtAssets; // Money owed TO you by this account
  final double debtLiabilities; // Money you OWE to this account
  final DateTime? lastActivity; // Most recent transaction date
  final DateTime? nextDueDate; // Closest upcoming due date

  const AccountBalance({
    required this.debtAssets,
    required this.debtLiabilities,
    this.lastActivity,
    this.nextDueDate,
  });

  double get netBalance => debtAssets - debtLiabilities;

  @override
  List<Object?> get props => [
    debtAssets,
    debtLiabilities,
    lastActivity,
    nextDueDate,
  ];
}

/// Use case for calculating account balance from linked transactions
class GetAccountBalanceUseCase
    implements UseCase<AccountBalance, AccountBalanceParams> {
  final TransactionRepository repository;

  GetAccountBalanceUseCase(this.repository);

  @override
  Future<Either<Failure, AccountBalance>> call(
    AccountBalanceParams params,
  ) async {
    try {
      // Get all transactions
      final transactionsResult = await repository.getTransactions();

      return transactionsResult.fold((failure) => Left(failure), (
        transactions,
      ) {
        // Filter transactions linked to this account
        final linkedTransactions = transactions
            .where((t) => t.linkedAccountId == params.accountId && t.isDebt)
            .toList();

        double debtAssets = 0;
        double debtLiabilities = 0;
        DateTime? lastActivity;
        DateTime? nextDueDate;
        final now = DateTime.now();

        for (final transaction in linkedTransactions) {
          // Track last activity
          if (lastActivity == null || transaction.date.isAfter(lastActivity)) {
            lastActivity = transaction.date;
          }

          // Track next due date (if not settled and in future)
          if (!transaction.isSettled && transaction.dueDate != null) {
            if (transaction.dueDate!.isAfter(now)) {
              if (nextDueDate == null ||
                  transaction.dueDate!.isBefore(nextDueDate)) {
                nextDueDate = transaction.dueDate;
              }
            }
          }

          if (transaction.isSettled) {
            if (transaction.isIncome) {
              // Money in + Settled = Reducing an asset (they paid you back)
              debtAssets -= transaction.amount;
            } else {
              // Money out + Settled = Reducing a liability (you paid them back)
              debtLiabilities -= transaction.amount;
            }
          } else {
            if (transaction.isIncome) {
              // Money in + Debt = Asset (They owe you - they borrowed from you)
              debtAssets += transaction.amount;
            } else {
              // Money out + Debt = Liability (You owe them - you borrowed from them)
              debtLiabilities += transaction.amount;
            }
          }
        }

        return Right(
          AccountBalance(
            debtAssets: debtAssets < 0 ? 0 : debtAssets,
            debtLiabilities: debtLiabilities < 0 ? 0 : debtLiabilities,
            lastActivity: lastActivity,
            nextDueDate: nextDueDate,
          ),
        );
      });
    } catch (e) {
      return Left(GeneralFailure('Failed to calculate account balance: $e'));
    }
  }
}

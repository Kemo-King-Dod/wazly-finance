import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/wallet_repository.dart';

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

  const AccountBalance({
    required this.debtAssets,
    required this.debtLiabilities,
  });

  double get netBalance => debtAssets - debtLiabilities;

  @override
  List<Object?> get props => [debtAssets, debtLiabilities];
}

/// Use case for calculating account balance from linked transactions
class GetAccountBalanceUseCase
    implements UseCase<AccountBalance, AccountBalanceParams> {
  final WalletRepository repository;

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

        for (final transaction in linkedTransactions) {
          if (transaction.isIncome) {
            // Money in + Debt = Liability (You owe them)
            debtLiabilities += transaction.amount;
          } else {
            // Money out + Debt = Asset (They owe you)
            debtAssets += transaction.amount;
          }
        }

        return Right(
          AccountBalance(
            debtAssets: debtAssets,
            debtLiabilities: debtLiabilities,
          ),
        );
      });
    } catch (e) {
      return Left(GeneralFailure('Failed to calculate account balance: $e'));
    }
  }
}

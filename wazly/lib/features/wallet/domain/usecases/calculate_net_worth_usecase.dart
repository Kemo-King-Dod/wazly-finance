import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../../transactions/domain/usecases/balance_calculator.dart';
import '../../../accounts/domain/usecases/get_account_balance_usecase.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

/// Result of net worth calculation
class NetWorthResult {
  final double vaultBalance;
  final double debtAssets;
  final double debtLiabilities;

  const NetWorthResult({
    required this.vaultBalance,
    required this.debtAssets,
    required this.debtLiabilities,
  });

  double get netWorth => vaultBalance + debtAssets - debtLiabilities;
}

/// Use case to calculate the total Net Worth of the user
class CalculateNetWorthUseCase implements UseCase<NetWorthResult, NoParams> {
  final TransactionRepository transactionRepository;
  final AccountRepository accountRepository;
  final BalanceCalculator balanceCalculator;
  final GetAccountBalanceUseCase getAccountBalanceUseCase;

  CalculateNetWorthUseCase({
    required this.transactionRepository,
    required this.accountRepository,
    required this.balanceCalculator,
    required this.getAccountBalanceUseCase,
  });

  @override
  Future<Either<Failure, NetWorthResult>> call(NoParams params) async {
    try {
      // 1. Get Vault Balance from standard transactions
      final transactionsResult = await transactionRepository.getTransactions();

      return transactionsResult.fold((failure) => Left(failure), (
        List<TransactionEntity> transactions,
      ) async {
        final vaultBalance = balanceCalculator.calculateBalance(transactions);

        // 2. Get All Accounts to sum up debt assets and liabilities
        final accountsResult = await accountRepository.getAccounts();
        double totalDebtAssets = 0;
        double totalDebtLiabilities = 0;

        return accountsResult.fold((failure) => Left(failure), (
          accounts,
        ) async {
          for (final account in accounts) {
            final balanceResult = await getAccountBalanceUseCase(
              AccountBalanceParams(accountId: account.id),
            );
            balanceResult.fold((failure) {}, (balance) {
              totalDebtAssets += balance.debtAssets;
              totalDebtLiabilities += balance.debtLiabilities;
            });
          }

          return Right(
            NetWorthResult(
              vaultBalance: vaultBalance,
              debtAssets: totalDebtAssets,
              debtLiabilities: totalDebtLiabilities,
            ),
          );
        });
      });
    } catch (e) {
      return Left(
        GeneralFailure('Failed to calculate net worth: ${e.toString()}'),
      );
    }
  }
}

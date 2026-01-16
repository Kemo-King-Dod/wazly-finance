import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/wallet_repository.dart';
import 'balance_calculator.dart';
import 'get_account_balance_usecase.dart';

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
  final WalletRepository repository;
  final BalanceCalculator balanceCalculator;
  final GetAccountBalanceUseCase getAccountBalanceUseCase;

  CalculateNetWorthUseCase({
    required this.repository,
    required this.balanceCalculator,
    required this.getAccountBalanceUseCase,
  });

  @override
  Future<Either<Failure, NetWorthResult>> call(NoParams params) async {
    // 1. Get Vault Balance from standard transactions
    final transactionsResult = await repository.getTransactions();

    return transactionsResult.fold((failure) => Left(failure), (
      transactions,
    ) async {
      final vaultBalance = balanceCalculator.calculateBalance(transactions);

      // 2. Get All Accounts to sum up debt assets and liabilities
      final accountsResult = await repository.getAccounts();
      double totalDebtAssets = 0;
      double totalDebtLiabilities = 0;

      return accountsResult.fold((failure) => Left(failure), (accounts) async {
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
  }
}

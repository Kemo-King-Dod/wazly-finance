import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../../transactions/domain/usecases/balance_calculator.dart';
import '../repositories/account_repository.dart';
import '../usecases/get_account_balance_usecase.dart';
import '../entities/net_worth_result.dart';

/// Use case for calculating total net worth
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
      // Get all transactions
      final transactionsResult = await transactionRepository.getTransactions();

      return transactionsResult.fold((failure) => Left(failure), (
        transactions,
      ) {
        // Calculate vault balance (non-debt transactions)
        final vaultBalance = balanceCalculator.calculateBalance(
          transactions.where((t) => !t.isDebt).toList(),
        );

        // Calculate debt assets (money owed to us)
        final debtAssets = transactions
            .where((t) => t.isDebt && t.isIncome)
            .fold<double>(0, (sum, t) => sum + t.amount);

        // Calculate debt liabilities (money we owe)
        final debtLiabilities = transactions
            .where((t) => t.isDebt && !t.isIncome)
            .fold<double>(0, (sum, t) => sum + t.amount);

        return Right(
          NetWorthResult(
            vaultBalance: vaultBalance,
            debtAssets: debtAssets,
            debtLiabilities: debtLiabilities,
          ),
        );
      });
    } catch (e) {
      return Left(GeneralFailure('Failed to calculate net worth: $e'));
    }
  }
}

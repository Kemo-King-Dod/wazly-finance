import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../../usecases/usecase.dart';
import '../entities/dashboard_summary.dart';
import '../entities/person_with_balance.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/treasury_repository.dart';
import 'get_people_with_balances.dart';

class GetDashboardSummary implements UseCase<DashboardSummary, NoParams> {
  final TreasuryRepository treasuryRepository;
  final TransactionRepository transactionRepository;
  final GetPeopleWithBalances getPeopleWithBalances;

  GetDashboardSummary({
    required this.treasuryRepository,
    required this.transactionRepository,
    required this.getPeopleWithBalances,
  });

  @override
  Future<Either<Failure, DashboardSummary>> call(NoParams params) async {
    try {
      // 1. Fetch current Treasury
      final treasuryResult = await treasuryRepository.getTreasury();
      if (treasuryResult.isLeft()) {
        return Left(treasuryResult.fold((l) => l, (r) => throw Exception()));
      }

      // 2. Fetch People with Balances (Active Debts)
      final peopleResult = await getPeopleWithBalances(const NoParams());
      if (peopleResult.isLeft()) {
        return Left(peopleResult.fold((l) => l, (r) => throw Exception()));
      }

      // 3. Fetch Recent Transactions
      final recentTxResult = await transactionRepository.getRecentTransactions(
        5,
      );
      if (recentTxResult.isLeft()) {
        return Left(recentTxResult.fold((l) => l, (r) => throw Exception()));
      }

      // Extract results safely
      final treasury = treasuryResult.getOrElse(() => throw Exception());
      final allPeople = peopleResult.getOrElse(() => []);
      final recentTxs = recentTxResult.getOrElse(() => []);

      // Filter active debts (netBalanceInCents != 0)
      final List<PersonWithBalance> activeDebts = allPeople
          .where((p) => p.netBalanceInCents != 0)
          .toList();

      return Right(
        DashboardSummary(
          treasury: treasury,
          activeDebts: activeDebts,
          recentTransactions: recentTxs,
        ),
      );
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/entities/time_filter.dart';
import '../../../transactions/domain/usecases/get_transactions_usecase.dart';
import '../../../transactions/domain/usecases/add_transaction_usecase.dart';
import '../../domain/usecases/balance_calculator.dart';
import '../../domain/usecases/get_category_wise_expenses_usecase.dart';
import '../../../wallet/domain/usecases/calculate_net_worth_usecase.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

/// BLoC for managing transaction state
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactionsUseCase getTransactionsUseCase;
  final AddTransactionUseCase addTransactionUseCase;
  final BalanceCalculator balanceCalculator;
  final GetCategoryWiseExpensesUseCase getCategoryWiseExpensesUseCase;
  final CalculateNetWorthUseCase calculateNetWorthUseCase;

  TransactionBloc({
    required this.getTransactionsUseCase,
    required this.addTransactionUseCase,
    required this.balanceCalculator,
    required this.getCategoryWiseExpensesUseCase,
    required this.calculateNetWorthUseCase,
  }) : super(const TransactionInitial()) {
    on<FetchTransactionData>(_onFetchTransactionData);
    on<AddTransactionEvent>(_onAddTransaction);
    on<RefreshTransactionData>(_onRefreshTransactionData);
    on<FetchAnalyticsData>(_onFetchAnalyticsData);
  }

  /// Handle fetching transaction data
  Future<void> _onFetchTransactionData(
    FetchTransactionData event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());

    final transactionsResult = await getTransactionsUseCase(const NoParams());
    final netWorthResult = await calculateNetWorthUseCase(const NoParams());

    final transactions = transactionsResult.fold((failure) {
      emit(TransactionError(failure.message));
      return null;
    }, (txs) => txs);

    if (transactions == null) return;

    final netWorth = netWorthResult.fold((failure) {
      emit(TransactionError(failure.message));
      return null;
    }, (nw) => nw);

    if (netWorth == null) return;

    final sortedTransactions = List<TransactionEntity>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    final recentTransactions = sortedTransactions.take(5).toList();

    emit(
      TransactionLoaded(
        totalBalance: netWorth.vaultBalance,
        debtAssets: netWorth.debtAssets,
        debtLiabilities: netWorth.debtLiabilities,
        recentTransactions: recentTransactions,
        allTransactions: transactions,
      ),
    );
  }

  /// Handle adding a transaction
  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionAddingTransaction());

    final result = await addTransactionUseCase(
      AddTransactionParams(transaction: event.transaction),
    );

    result.fold((failure) => emit(TransactionError(failure.message)), (_) {
      emit(const TransactionAdded());
      add(const RefreshTransactionData());
    });
  }

  /// Handle refreshing transaction data
  Future<void> _onRefreshTransactionData(
    RefreshTransactionData event,
    Emitter<TransactionState> emit,
  ) async {
    final transactionsResult = await getTransactionsUseCase(const NoParams());
    final netWorthResult = await calculateNetWorthUseCase(const NoParams());

    final transactions = transactionsResult.fold((failure) {
      emit(TransactionError(failure.message));
      return null;
    }, (txs) => txs);

    if (transactions == null) return;

    final netWorth = netWorthResult.fold((failure) {
      emit(TransactionError(failure.message));
      return null;
    }, (nw) => nw);

    if (netWorth == null) return;

    final sortedTransactions = List<TransactionEntity>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    final recentTransactions = sortedTransactions.take(5).toList();

    emit(
      TransactionLoaded(
        totalBalance: netWorth.vaultBalance,
        debtAssets: netWorth.debtAssets,
        debtLiabilities: netWorth.debtLiabilities,
        recentTransactions: recentTransactions,
        allTransactions: transactions,
      ),
    );
  }

  /// Helper to filter transactions by time period
  List<TransactionEntity> _filterTransactionsByTime(
    List<TransactionEntity> transactions,
    TimeFilter filter,
  ) {
    final now = DateTime.now();

    switch (filter) {
      case TimeFilter.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return transactions.where((t) {
          return t.date.isAfter(
                startOfMonth.subtract(const Duration(seconds: 1)),
              ) &&
              t.date.isBefore(endOfMonth.add(const Duration(seconds: 1)));
        }).toList();

      case TimeFilter.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        final endOfLastMonth = DateTime(now.year, now.month, 0, 23, 59, 59);
        return transactions.where((t) {
          return t.date.isAfter(
                lastMonth.subtract(const Duration(seconds: 1)),
              ) &&
              t.date.isBefore(endOfLastMonth.add(const Duration(seconds: 1)));
        }).toList();

      case TimeFilter.allTime:
        return transactions;
    }
  }

  /// Handle fetching analytics data
  Future<void> _onFetchAnalyticsData(
    FetchAnalyticsData event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionAnalyticsLoading());

    final expensesResult = await getCategoryWiseExpensesUseCase(
      CategoryExpensesParams(filter: event.filter),
    );

    final transactionsResult = await getTransactionsUseCase(const NoParams());

    final categoryExpenses = expensesResult.fold((failure) {
      emit(TransactionError(failure.message));
      return null;
    }, (expenses) => expenses);

    if (categoryExpenses == null) return;

    final transactions = transactionsResult.fold((failure) {
      emit(TransactionError(failure.message));
      return null;
    }, (txs) => txs);

    if (transactions == null) return;

    final filteredTransactions = _filterTransactionsByTime(
      transactions,
      event.filter,
    );

    double totalIncome = 0;
    double totalExpenses = 0;

    for (final transaction in filteredTransactions) {
      if (transaction.isDebt) continue;

      if (transaction.isIncome) {
        totalIncome += transaction.amount;
      } else {
        totalExpenses += transaction.amount;
      }
    }

    final netWorthResult = await calculateNetWorthUseCase(const NoParams());

    netWorthResult.fold((failure) => emit(TransactionError(failure.message)), (
      netWorth,
    ) {
      emit(
        TransactionAnalyticsLoaded(
          categoryExpenses: categoryExpenses,
          totalIncome: totalIncome,
          totalExpenses: totalExpenses,
          currentFilter: event.filter,
          totalBalance: netWorth.vaultBalance,
          debtAssets: netWorth.debtAssets,
          debtLiabilities: netWorth.debtLiabilities,
        ),
      );
    });
  }
}

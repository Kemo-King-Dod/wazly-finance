import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/domain/usecases/get_transactions_usecase.dart';
import '../../../transactions/domain/usecases/add_transaction_usecase.dart';
import '../../domain/usecases/balance_calculator.dart';
import '../../../accounts/domain/usecases/calculate_net_worth_usecase.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

/// BLoC for managing transaction state
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactionsUseCase getTransactionsUseCase;
  final AddTransactionUseCase addTransactionUseCase;
  final BalanceCalculator balanceCalculator;
  final CalculateNetWorthUseCase calculateNetWorthUseCase;

  TransactionBloc({
    required this.getTransactionsUseCase,
    required this.addTransactionUseCase,
    required this.balanceCalculator,
    required this.calculateNetWorthUseCase,
  }) : super(const TransactionInitial()) {
    on<FetchTransactionData>(_onFetchTransactionData);
    on<AddTransactionEvent>(_onAddTransaction);
    on<RefreshTransactionData>(_onRefreshTransactionData);
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

  @override
  void onTransition(Transition<TransactionEvent, TransactionState> transition) {
    super.onTransition(transition);
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/entities/time_filter.dart';
import '../../domain/entities/account_filter.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../domain/usecases/add_transaction_usecase.dart';
import '../../domain/usecases/balance_calculator.dart';
import '../../domain/usecases/get_category_wise_expenses_usecase.dart';
import '../../domain/usecases/get_accounts_usecase.dart';
import '../../domain/usecases/add_account_usecase.dart';
import '../../domain/usecases/calculate_net_worth_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/get_account_balance_usecase.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

/// BLoC for managing wallet state
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetTransactionsUseCase getTransactionsUseCase;
  final AddTransactionUseCase addTransactionUseCase;
  final BalanceCalculator balanceCalculator;
  final GetCategoryWiseExpensesUseCase getCategoryWiseExpensesUseCase;
  final GetAccountsUseCase getAccountsUseCase;
  final AddAccountUseCase addAccountUseCase;
  final CalculateNetWorthUseCase calculateNetWorthUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;

  WalletBloc({
    required this.getTransactionsUseCase,
    required this.addTransactionUseCase,
    required this.balanceCalculator,
    required this.getCategoryWiseExpensesUseCase,
    required this.getAccountsUseCase,
    required this.addAccountUseCase,
    required this.calculateNetWorthUseCase,
    required this.deleteAccountUseCase,
  }) : super(const WalletInitial()) {
    on<FetchWalletData>(_onFetchWalletData);
    on<AddTransactionEvent>(_onAddTransaction);
    on<RefreshWalletData>(_onRefreshWalletData);
    on<FetchAnalyticsData>(_onFetchAnalyticsData);
    on<FetchAccounts>(_onFetchAccounts);
    on<AddAccountEvent>(_onAddAccount);
    on<DeleteAccountEvent>(_onDeleteAccount);
    on<SearchAccounts>(_onSearchAccounts);
  }

  /// Handle fetching wallet data
  Future<void> _onFetchWalletData(
    FetchWalletData event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());

    final transactionsResult = await getTransactionsUseCase(const NoParams());
    final netWorthResult = await calculateNetWorthUseCase(const NoParams());

    final transactions = transactionsResult.fold((failure) {
      emit(WalletError(failure.message));
      return null;
    }, (txs) => txs);

    if (transactions == null) return;

    final netWorth = netWorthResult.fold((failure) {
      emit(WalletError(failure.message));
      return null;
    }, (nw) => nw);

    if (netWorth == null) return;

    final sortedTransactions = List<TransactionEntity>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    final recentTransactions = sortedTransactions.take(5).toList();

    emit(
      WalletLoaded(
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
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletAddingTransaction());

    final result = await addTransactionUseCase(
      AddTransactionParams(transaction: event.transaction),
    );

    result.fold((failure) => emit(WalletError(failure.message)), (_) {
      emit(const WalletTransactionAdded());
      add(const RefreshWalletData());
    });
  }

  /// Handle refreshing wallet data
  Future<void> _onRefreshWalletData(
    RefreshWalletData event,
    Emitter<WalletState> emit,
  ) async {
    final transactionsResult = await getTransactionsUseCase(const NoParams());
    final netWorthResult = await calculateNetWorthUseCase(const NoParams());

    final transactions = transactionsResult.fold((failure) {
      emit(WalletError(failure.message));
      return null;
    }, (txs) => txs);

    if (transactions == null) return;

    final netWorth = netWorthResult.fold((failure) {
      emit(WalletError(failure.message));
      return null;
    }, (nw) => nw);

    if (netWorth == null) return;

    final sortedTransactions = List<TransactionEntity>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    final recentTransactions = sortedTransactions.take(5).toList();

    emit(
      WalletLoaded(
        totalBalance: netWorth.vaultBalance,
        debtAssets: netWorth.debtAssets,
        debtLiabilities: netWorth.debtLiabilities,
        recentTransactions: recentTransactions,
        allTransactions: transactions,
      ),
    );
  }

  /// Handle fetching analytics data
  Future<void> _onFetchAnalyticsData(
    FetchAnalyticsData event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletAnalyticsLoading());

    final expensesResult = await getCategoryWiseExpensesUseCase(
      CategoryExpensesParams(filter: event.filter),
    );

    final transactionsResult = await getTransactionsUseCase(const NoParams());

    final categoryExpenses = expensesResult.fold((failure) {
      emit(WalletError(failure.message));
      return null;
    }, (expenses) => expenses);

    if (categoryExpenses == null) return;

    final transactions = transactionsResult.fold((failure) {
      emit(WalletError(failure.message));
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

    netWorthResult.fold((failure) => emit(WalletError(failure.message)), (
      netWorth,
    ) {
      emit(
        WalletAnalyticsLoaded(
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

  /// Handle fetching accounts
  Future<void> _onFetchAccounts(
    FetchAccounts event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletAccountsLoading());

    final result = await getAccountsUseCase(const NoParams());
    final netWorthResult = await calculateNetWorthUseCase(const NoParams());

    result.fold((failure) => emit(WalletError(failure.message)), (accounts) {
      netWorthResult.fold((failure) => emit(WalletError(failure.message)), (
        netWorth,
      ) {
        emit(
          WalletAccountsLoaded(
            accounts: accounts,
            debtAssets: netWorth.debtAssets,
            debtLiabilities: netWorth.debtLiabilities,
          ),
        );
      });
    });
  }

  /// Handle adding an account
  Future<void> _onAddAccount(
    AddAccountEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletAddingAccount());

    final result = await addAccountUseCase(
      AddAccountParams(account: event.account),
    );

    result.fold((failure) => emit(WalletError(failure.message)), (_) {
      emit(const WalletAccountAdded());
      add(const FetchAccounts());
    });
  }

  /// Handle deleting an account
  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<WalletState> emit,
  ) async {
    final result = await deleteAccountUseCase(event.accountId);

    result.fold(
      (failure) => emit(WalletError(failure.message)),
      (_) => add(const FetchAccounts()),
    );
  }

  /// Handle searching and filtering accounts
  Future<void> _onSearchAccounts(
    SearchAccounts event,
    Emitter<WalletState> emit,
  ) async {
    final currentState = state;
    if (currentState is WalletAccountsLoaded ||
        currentState is WalletAccountsLoading) {
      final allAccountsResult = await getAccountsUseCase(const NoParams());

      await allAccountsResult.fold(
        (failure) async => emit(WalletError(failure.message)),
        (accounts) async {
          List<AccountEntity> filteredAccounts = accounts.where((account) {
            final nameMatch = account.name.toLowerCase().contains(
              event.query.toLowerCase(),
            );
            final phoneMatch = account.phone.contains(event.query);
            return nameMatch || phoneMatch;
          }).toList();

          if (event.filter != AccountFilter.all) {
            final filteredWithBalance = <AccountEntity>[];
            final getBalanceUseCase = sl<GetAccountBalanceUseCase>();

            for (final account in filteredAccounts) {
              final balanceResult = await getBalanceUseCase(
                AccountBalanceParams(accountId: account.id),
              );
              final balance = balanceResult.fold((_) => null, (b) => b);

              if (balance != null) {
                bool matches = false;

                switch (event.filter) {
                  case AccountFilter.owedToMe:
                    matches = balance.debtAssets > 0;
                    break;
                  case AccountFilter.iOwe:
                    matches = balance.debtLiabilities > 0;
                    break;
                  case AccountFilter.settled:
                    matches =
                        balance.debtAssets == 0 && balance.debtLiabilities == 0;
                    break;
                  case AccountFilter.all:
                    matches = true;
                    break;
                }

                if (matches) filteredWithBalance.add(account);
              }
            }
            filteredAccounts = filteredWithBalance;
          }

          final netWorthResult = await calculateNetWorthUseCase(
            const NoParams(),
          );
          netWorthResult.fold(
            (failure) => emit(WalletError(failure.message)),
            (netWorth) => emit(
              WalletAccountsLoaded(
                accounts: filteredAccounts,
                debtAssets: netWorth.debtAssets,
                debtLiabilities: netWorth.debtLiabilities,
                searchQuery: event.query,
              ),
            ),
          );
        },
      );
    }
  }
}

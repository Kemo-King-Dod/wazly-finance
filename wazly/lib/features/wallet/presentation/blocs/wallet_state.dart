import 'package:equatable/equatable.dart';
import '../../domain/entities/account_sort.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/entities/category_expense.dart';
import '../../domain/entities/time_filter.dart';
import '../../domain/entities/account_filter.dart';

/// Base class for all Wallet states
abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class WalletInitial extends WalletState {
  const WalletInitial();
}

/// State when wallet data is being loaded
class WalletLoading extends WalletState {
  const WalletLoading();
}

/// State when wallet data is successfully loaded
class WalletLoaded extends WalletState {
  final double totalBalance;
  final double debtAssets;
  final double debtLiabilities;
  final List<TransactionEntity> recentTransactions;
  final List<TransactionEntity> allTransactions;

  const WalletLoaded({
    required this.totalBalance,
    this.debtAssets = 0,
    this.debtLiabilities = 0,
    required this.recentTransactions,
    required this.allTransactions,
  });

  double get netWorth => totalBalance + debtAssets - debtLiabilities;

  @override
  List<Object?> get props => [
    totalBalance,
    debtAssets,
    debtLiabilities,
    recentTransactions,
    allTransactions,
  ];

  /// Create a copy with updated values
  WalletLoaded copyWith({
    double? totalBalance,
    double? debtAssets,
    double? debtLiabilities,
    List<TransactionEntity>? recentTransactions,
    List<TransactionEntity>? allTransactions,
  }) {
    return WalletLoaded(
      totalBalance: totalBalance ?? this.totalBalance,
      debtAssets: debtAssets ?? this.debtAssets,
      debtLiabilities: debtLiabilities ?? this.debtLiabilities,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      allTransactions: allTransactions ?? this.allTransactions,
    );
  }
}

/// State when an error occurs
class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when a transaction is being added
class WalletAddingTransaction extends WalletState {
  const WalletAddingTransaction();
}

/// State when a transaction is successfully added
class WalletTransactionAdded extends WalletState {
  const WalletTransactionAdded();
}

/// State when analytics data is being loaded
class WalletAnalyticsLoading extends WalletState {
  const WalletAnalyticsLoading();
}

/// State when analytics data is successfully loaded
class WalletAnalyticsLoaded extends WalletState {
  final List<CategoryExpense> categoryExpenses;
  final double totalIncome;
  final double totalExpenses;
  final TimeFilter currentFilter;
  final double totalBalance;
  final double debtAssets;
  final double debtLiabilities;

  const WalletAnalyticsLoaded({
    required this.categoryExpenses,
    required this.totalIncome,
    required this.totalExpenses,
    required this.currentFilter,
    this.totalBalance = 0,
    this.debtAssets = 0,
    this.debtLiabilities = 0,
  });

  double get netWorth => totalBalance + debtAssets - debtLiabilities;

  @override
  List<Object?> get props => [
    categoryExpenses,
    totalIncome,
    totalExpenses,
    currentFilter,
    totalBalance,
    debtAssets,
    debtLiabilities,
  ];
}

/// State when accounts are being loaded
class WalletAccountsLoading extends WalletState {
  const WalletAccountsLoading();
}

/// State when accounts are successfully loaded
class WalletAccountsLoaded extends WalletState {
  final List<AccountEntity> accounts;
  final double totalBalance;
  final double debtAssets;
  final double debtLiabilities;
  final String searchQuery;
  final AccountFilter filter;
  final AccountSort currentSort;

  const WalletAccountsLoaded({
    required this.accounts,
    this.totalBalance = 0,
    this.debtAssets = 0,
    this.debtLiabilities = 0,
    this.searchQuery = '',
    this.filter = AccountFilter.all,
    this.currentSort = AccountSort.name,
  });

  double get netWorth => totalBalance + debtAssets - debtLiabilities;

  @override
  List<Object?> get props => [
    accounts,
    totalBalance,
    debtAssets,
    debtLiabilities,
    searchQuery,
    filter,
    currentSort,
  ];
}

/// State when an account is being added
class WalletAddingAccount extends WalletState {
  const WalletAddingAccount();
}

/// State when an account is successfully added
class WalletAccountAdded extends WalletState {
  const WalletAccountAdded();
}

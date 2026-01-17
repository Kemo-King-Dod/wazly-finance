import 'package:equatable/equatable.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/entities/category_expense.dart';
import '../../domain/entities/time_filter.dart';

/// Base class for all Transaction states
abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

/// State when transaction data is being loaded
class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

/// State when transaction data is successfully loaded
class TransactionLoaded extends TransactionState {
  final double totalBalance;
  final double debtAssets;
  final double debtLiabilities;
  final List<TransactionEntity> recentTransactions;
  final List<TransactionEntity> allTransactions;

  const TransactionLoaded({
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
  TransactionLoaded copyWith({
    double? totalBalance,
    double? debtAssets,
    double? debtLiabilities,
    List<TransactionEntity>? recentTransactions,
    List<TransactionEntity>? allTransactions,
  }) {
    return TransactionLoaded(
      totalBalance: totalBalance ?? this.totalBalance,
      debtAssets: debtAssets ?? this.debtAssets,
      debtLiabilities: debtLiabilities ?? this.debtLiabilities,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      allTransactions: allTransactions ?? this.allTransactions,
    );
  }
}

/// State when an error occurs
class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when a transaction is being added
class TransactionAddingTransaction extends TransactionState {
  const TransactionAddingTransaction();
}

/// State when a transaction is successfully added
class TransactionAdded extends TransactionState {
  const TransactionAdded();
}

/// State when analytics data is being loaded
class TransactionAnalyticsLoading extends TransactionState {
  const TransactionAnalyticsLoading();
}

/// State when analytics data is successfully loaded
class TransactionAnalyticsLoaded extends TransactionState {
  final List<CategoryExpense> categoryExpenses;
  final double totalIncome;
  final double totalExpenses;
  final TimeFilter currentFilter;
  final double totalBalance;
  final double debtAssets;
  final double debtLiabilities;

  const TransactionAnalyticsLoaded({
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

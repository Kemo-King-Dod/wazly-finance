import 'package:equatable/equatable.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

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

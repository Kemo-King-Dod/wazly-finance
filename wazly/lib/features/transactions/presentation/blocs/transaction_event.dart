import 'package:equatable/equatable.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

/// Base class for all Transaction events
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch transaction data (transactions and calculate balance)
class FetchTransactionData extends TransactionEvent {
  const FetchTransactionData();
}

/// Event to add a new transaction
class AddTransactionEvent extends TransactionEvent {
  final TransactionEntity transaction;

  const AddTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

/// Event to refresh transaction data
class RefreshTransactionData extends TransactionEvent {
  const RefreshTransactionData();
}

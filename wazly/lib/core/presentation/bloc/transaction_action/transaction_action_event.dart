part of 'transaction_action_bloc.dart';

abstract class TransactionActionEvent extends Equatable {
  const TransactionActionEvent();

  @override
  List<Object?> get props => [];
}

class SubmitDebt extends TransactionActionEvent {
  final AddDebtParams params;

  const SubmitDebt(this.params);

  @override
  List<Object?> get props => [params];
}

class SubmitPayment extends TransactionActionEvent {
  final AddPaymentParams params;

  const SubmitPayment(this.params);

  @override
  List<Object?> get props => [params];
}

class SubmitTreasuryFlow extends TransactionActionEvent {
  final AffectTreasuryParams params;

  const SubmitTreasuryFlow(this.params);

  @override
  List<Object?> get props => [params];
}

class DeleteTransactionEvent extends TransactionActionEvent {
  final String transactionId;

  const DeleteTransactionEvent(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class EditTransactionEvent extends TransactionActionEvent {
  final String oldTransactionId;
  final TransactionActionEvent newAction;

  const EditTransactionEvent({
    required this.oldTransactionId,
    required this.newAction,
  });

  @override
  List<Object?> get props => [oldTransactionId, newAction];
}

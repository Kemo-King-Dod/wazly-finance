part of 'transaction_action_bloc.dart';

abstract class TransactionActionState extends Equatable {
  const TransactionActionState();

  @override
  List<Object?> get props => [];
}

class TransactionActionInitial extends TransactionActionState {}

class TransactionActionSubmitting extends TransactionActionState {}

class TransactionActionSuccess extends TransactionActionState {}

class TransactionActionError extends TransactionActionState {
  final String message;

  const TransactionActionError(this.message);

  @override
  List<Object?> get props => [message];
}

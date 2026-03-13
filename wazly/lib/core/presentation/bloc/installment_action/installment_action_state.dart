part of 'installment_action_bloc.dart';

abstract class InstallmentActionState extends Equatable {
  const InstallmentActionState();

  @override
  List<Object?> get props => [];
}

class InstallmentActionInitial extends InstallmentActionState {}

class InstallmentActionSubmitting extends InstallmentActionState {}

class InstallmentActionSuccess extends InstallmentActionState {}

class InstallmentActionError extends InstallmentActionState {
  final String message;

  const InstallmentActionError(this.message);

  @override
  List<Object?> get props => [message];
}

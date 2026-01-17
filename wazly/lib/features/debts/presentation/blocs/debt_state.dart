import 'package:equatable/equatable.dart';

abstract class DebtState extends Equatable {
  const DebtState();

  @override
  List<Object?> get props => [];
}

class DebtInitial extends DebtState {
  const DebtInitial();
}

class DebtLoading extends DebtState {
  const DebtLoading();
}

class DebtSuccess extends DebtState {
  final String message;
  const DebtSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class DebtError extends DebtState {
  final String message;
  const DebtError(this.message);

  @override
  List<Object?> get props => [message];
}

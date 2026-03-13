part of 'person_action_bloc.dart';

abstract class PersonActionState extends Equatable {
  const PersonActionState();

  @override
  List<Object?> get props => [];
}

class PersonActionInitial extends PersonActionState {}

class PersonActionSubmitting extends PersonActionState {}

class PersonActionSuccess extends PersonActionState {}

class PersonActionError extends PersonActionState {
  final String message;

  const PersonActionError(this.message);

  @override
  List<Object?> get props => [message];
}

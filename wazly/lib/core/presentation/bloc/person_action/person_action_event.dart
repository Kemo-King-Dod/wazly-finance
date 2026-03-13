part of 'person_action_bloc.dart';

abstract class PersonActionEvent extends Equatable {
  const PersonActionEvent();

  @override
  List<Object?> get props => [];
}

class DeletePersonEvent extends PersonActionEvent {
  final String personId;

  const DeletePersonEvent(this.personId);

  @override
  List<Object?> get props => [personId];
}

class UpdatePersonEvent extends PersonActionEvent {
  final Person person;

  const UpdatePersonEvent(this.person);

  @override
  List<Object?> get props => [person];
}

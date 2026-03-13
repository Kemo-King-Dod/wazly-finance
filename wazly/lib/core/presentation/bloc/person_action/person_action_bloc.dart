import 'package:equatable/equatable.dart';
import 'package:wazly/core/domain/entities/person.dart';
import 'package:wazly/core/domain/usecases/delete_person.dart';
import 'package:wazly/core/domain/usecases/update_person.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'person_action_event.dart';
part 'person_action_state.dart';

class PersonActionBloc extends Bloc<PersonActionEvent, PersonActionState> {
  final DeletePerson deletePerson;
  final UpdatePerson updatePerson;

  PersonActionBloc({required this.deletePerson, required this.updatePerson})
    : super(PersonActionInitial()) {
    on<DeletePersonEvent>(_onDeletePerson);
    on<UpdatePersonEvent>(_onUpdatePerson);
  }

  Future<void> _onDeletePerson(
    DeletePersonEvent event,
    Emitter<PersonActionState> emit,
  ) async {
    emit(PersonActionSubmitting());
    final result = await deletePerson(
      DeletePersonParams(personId: event.personId),
    );
    result.fold(
      (failure) => emit(PersonActionError(failure.message)),
      (_) => emit(PersonActionSuccess()),
    );
  }

  Future<void> _onUpdatePerson(
    UpdatePersonEvent event,
    Emitter<PersonActionState> emit,
  ) async {
    emit(PersonActionSubmitting());
    final result = await updatePerson(
      UpdatePersonParams(person: event.person),
    );
    result.fold(
      (failure) => emit(PersonActionError(failure.message)),
      (_) => emit(PersonActionSuccess()),
    );
  }
}

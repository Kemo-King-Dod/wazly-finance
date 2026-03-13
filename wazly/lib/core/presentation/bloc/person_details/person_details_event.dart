part of 'person_details_bloc.dart';

abstract class PersonDetailsEvent extends Equatable {
  const PersonDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPersonDetails extends PersonDetailsEvent {
  final String personId;

  const LoadPersonDetails(this.personId);

  @override
  List<Object?> get props => [personId];
}

class _InternalRefreshPersonDetails extends PersonDetailsEvent {
  final String personId;

  const _InternalRefreshPersonDetails(this.personId);

  @override
  List<Object?> get props => [personId];
}

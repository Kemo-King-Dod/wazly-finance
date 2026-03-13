part of 'people_bloc.dart';

abstract class PeopleEvent extends Equatable {
  const PeopleEvent();

  @override
  List<Object?> get props => [];
}

class LoadPeople extends PeopleEvent {
  const LoadPeople();
}

class _InternalRefreshPeople extends PeopleEvent {
  const _InternalRefreshPeople();
}

class SearchPeople extends PeopleEvent {
  final String query;

  const SearchPeople(this.query);

  @override
  List<Object?> get props => [query];
}

part of 'people_bloc.dart';

abstract class PeopleState extends Equatable {
  const PeopleState();

  @override
  List<Object?> get props => [];
}

class PeopleInitial extends PeopleState {}

class PeopleLoading extends PeopleState {}

class PeopleLoaded extends PeopleState {
  final List<PersonWithBalance> fullList;
  final List<PersonWithBalance> filteredList;
  final String searchQuery;

  const PeopleLoaded({
    required this.fullList,
    required this.filteredList,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [fullList, filteredList, searchQuery];
}

class PeopleError extends PeopleState {
  final String message;

  const PeopleError({required this.message});

  @override
  List<Object?> get props => [message];
}

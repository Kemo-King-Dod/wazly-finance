part of 'person_details_bloc.dart';

abstract class PersonDetailsState extends Equatable {
  const PersonDetailsState();

  @override
  List<Object?> get props => [];
}

class PersonDetailsInitial extends PersonDetailsState {}

class PersonDetailsLoading extends PersonDetailsState {}

class PersonDetailsLoaded extends PersonDetailsState {
  final Person person;
  final int netBalanceInCents;
  final List<Transaction> transactions;
  final List<InstallmentPlan> installmentPlans;

  const PersonDetailsLoaded({
    required this.person,
    required this.netBalanceInCents,
    required this.transactions,
    required this.installmentPlans,
  });

  @override
  List<Object?> get props => [
    person,
    netBalanceInCents,
    transactions,
    installmentPlans,
  ];
}

class PersonDetailsError extends PersonDetailsState {
  final String message;

  const PersonDetailsError({required this.message});

  @override
  List<Object?> get props => [message];
}

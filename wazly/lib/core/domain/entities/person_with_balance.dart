import 'package:equatable/equatable.dart';
import 'person.dart';

class PersonWithBalance extends Equatable {
  final Person person;
  final int netBalanceInCents;

  const PersonWithBalance({
    required this.person,
    required this.netBalanceInCents,
  });

  @override
  List<Object?> get props => [person, netBalanceInCents];
}

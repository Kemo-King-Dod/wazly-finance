import 'package:equatable/equatable.dart';

/// Entity representing a person/contact for debt tracking
class AccountEntity extends Equatable {
  final String id;
  final String name;
  final String phone;

  const AccountEntity({required this.id, required this.name, this.phone = ''});

  @override
  List<Object?> get props => [id, name, phone];
}

import 'package:equatable/equatable.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/entities/account_filter.dart';
import '../../domain/entities/account_sort.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class FetchAccounts extends AccountEvent {
  const FetchAccounts();
}

class AddAccountEvent extends AccountEvent {
  final AccountEntity account;

  const AddAccountEvent(this.account);

  @override
  List<Object?> get props => [account];
}

class DeleteAccountEvent extends AccountEvent {
  final String accountId;

  const DeleteAccountEvent(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class SearchAccounts extends AccountEvent {
  final String query;
  final AccountFilter filter;
  final AccountSort sortType;

  const SearchAccounts({
    required this.query,
    required this.filter,
    required this.sortType,
  });

  @override
  List<Object?> get props => [query, filter, sortType];
}

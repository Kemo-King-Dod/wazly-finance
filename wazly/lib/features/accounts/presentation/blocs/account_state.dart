import 'package:equatable/equatable.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/entities/account_filter.dart';
import '../../domain/entities/account_sort.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {
  const AccountInitial();
}

class AccountLoading extends AccountState {
  const AccountLoading();
}

class AccountAccountsLoading extends AccountState {
  const AccountAccountsLoading();
}

class AccountAddingAccount extends AccountState {
  const AccountAddingAccount();
}

class AccountAccountsLoaded extends AccountState {
  final List<AccountEntity> accounts; // Filtered/sorted accounts
  final List<AccountEntity> allAccounts; // All accounts (unfiltered)
  final double totalBalance;
  final double debtAssets;
  final double debtLiabilities;
  final String searchQuery;
  final AccountFilter filter;
  final AccountSort currentSort;

  const AccountAccountsLoaded({
    required this.accounts,
    required this.allAccounts,
    required this.totalBalance,
    required this.debtAssets,
    required this.debtLiabilities,
    this.searchQuery = '',
    this.filter = AccountFilter.all,
    this.currentSort = AccountSort.recent,
  });

  @override
  List<Object?> get props => [
    accounts,
    allAccounts,
    totalBalance,
    debtAssets,
    debtLiabilities,
    searchQuery,
    filter,
    currentSort,
  ];
}

class AccountAccountAdded extends AccountState {
  const AccountAccountAdded();
}

class AccountError extends AccountState {
  final String message;

  const AccountError(this.message);

  @override
  List<Object?> get props => [message];
}

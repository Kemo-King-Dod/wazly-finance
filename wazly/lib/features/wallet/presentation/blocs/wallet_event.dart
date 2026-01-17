import 'package:equatable/equatable.dart';
import '../../domain/entities/account_sort.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/entities/time_filter.dart';
import '../../domain/entities/account_filter.dart';

/// Base class for all Wallet events
abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch wallet data (transactions and calculate balance)
class FetchWalletData extends WalletEvent {
  const FetchWalletData();
}

/// Event to add a new transaction
class AddTransactionEvent extends WalletEvent {
  final TransactionEntity transaction;

  const AddTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

/// Event to refresh wallet data
class RefreshWalletData extends WalletEvent {
  const RefreshWalletData();
}

/// Event to fetch analytics data
class FetchAnalyticsData extends WalletEvent {
  final TimeFilter filter;

  const FetchAnalyticsData(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Event to fetch all accounts
class FetchAccounts extends WalletEvent {
  const FetchAccounts();
}

/// Event to add a new account
class AddAccountEvent extends WalletEvent {
  final AccountEntity account;

  const AddAccountEvent(this.account);

  @override
  List<Object?> get props => [account];
}

/// Event to delete an account
class DeleteAccountEvent extends WalletEvent {
  final String accountId;

  const DeleteAccountEvent(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Event to search and filter accounts
class SearchAccounts extends WalletEvent {
  final String query;
  final AccountFilter filter;
  final AccountSort sortType;

  const SearchAccounts({
    this.query = '',
    this.filter = AccountFilter.all,
    this.sortType = AccountSort.name,
  });

  @override
  List<Object?> get props => [query, filter, sortType];
}

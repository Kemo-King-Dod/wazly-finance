import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/entities/account_filter.dart';
import '../../domain/entities/account_sort.dart';
import '../../domain/usecases/get_accounts_usecase.dart';
import '../../domain/usecases/add_account_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/get_account_balance_usecase.dart';
import '../../../wallet/domain/usecases/calculate_net_worth_usecase.dart';
import 'account_event.dart';
import 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final GetAccountsUseCase getAccountsUseCase;
  final AddAccountUseCase addAccountUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final CalculateNetWorthUseCase calculateNetWorthUseCase;
  final GetAccountBalanceUseCase getAccountBalanceUseCase;

  AccountBloc({
    required this.getAccountsUseCase,
    required this.addAccountUseCase,
    required this.deleteAccountUseCase,
    required this.calculateNetWorthUseCase,
    required this.getAccountBalanceUseCase,
  }) : super(const AccountInitial()) {
    on<FetchAccounts>(_onFetchAccounts);
    on<AddAccountEvent>(_onAddAccount);
    on<DeleteAccountEvent>(_onDeleteAccount);
    on<SearchAccounts>(_onSearchAccounts);
  }

  Future<void> _onFetchAccounts(
    FetchAccounts event,
    Emitter<AccountState> emit,
  ) async {
    emit(const AccountAccountsLoading());

    final result = await getAccountsUseCase(const NoParams());
    final netWorthResult = await calculateNetWorthUseCase(const NoParams());

    result.fold((failure) => emit(AccountError(failure.message)), (accounts) {
      netWorthResult.fold((failure) => emit(AccountError(failure.message)), (
        netWorth,
      ) {
        emit(
          AccountAccountsLoaded(
            accounts: accounts,
            totalBalance: netWorth.vaultBalance,
            debtAssets: netWorth.debtAssets,
            debtLiabilities: netWorth.debtLiabilities,
          ),
        );
      });
    });
  }

  Future<void> _onAddAccount(
    AddAccountEvent event,
    Emitter<AccountState> emit,
  ) async {
    emit(const AccountAddingAccount());

    final result = await addAccountUseCase(
      AddAccountParams(account: event.account),
    );

    result.fold((failure) => emit(AccountError(failure.message)), (_) {
      emit(const AccountAccountAdded());
      add(const FetchAccounts());
    });
  }

  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<AccountState> emit,
  ) async {
    final result = await deleteAccountUseCase(event.accountId);

    result.fold(
      (failure) => emit(AccountError(failure.message)),
      (_) => add(const FetchAccounts()),
    );
  }

  Future<void> _onSearchAccounts(
    SearchAccounts event,
    Emitter<AccountState> emit,
  ) async {
    final currentState = state;
    if (currentState is AccountAccountsLoaded ||
        currentState is AccountAccountsLoading) {
      final allAccountsResult = await getAccountsUseCase(const NoParams());

      await allAccountsResult.fold(
        (failure) async => emit(AccountError(failure.message)),
        (accounts) async {
          List<AccountEntity> filteredAccounts = accounts.where((account) {
            final nameMatch = account.name.toLowerCase().contains(
              event.query.toLowerCase(),
            );
            final phoneMatch = account.phone.contains(event.query);
            return nameMatch || phoneMatch;
          }).toList();

          final accountWithBalances = <AccountEntity, AccountBalance>{};
          final filteredWithStatus = <AccountEntity>[];

          for (final account in filteredAccounts) {
            final balanceResult = await getAccountBalanceUseCase(
              AccountBalanceParams(accountId: account.id),
            );
            final balance = balanceResult.fold(
              (_) => const AccountBalance(debtAssets: 0, debtLiabilities: 0),
              (b) => b,
            );
            accountWithBalances[account] = balance;

            bool matchesStatus = false;
            switch (event.filter) {
              case AccountFilter.owedToMe:
                matchesStatus = balance.debtAssets > 0;
                break;
              case AccountFilter.iOwe:
                matchesStatus = balance.debtLiabilities > 0;
                break;
              case AccountFilter.settled:
                matchesStatus =
                    balance.debtAssets == 0 && balance.debtLiabilities == 0;
                break;
              case AccountFilter.all:
                matchesStatus = true;
                break;
            }

            if (matchesStatus) {
              filteredWithStatus.add(account);
            }
          }

          filteredWithStatus.sort((a, b) {
            final balanceA = accountWithBalances[a]!;
            final balanceB = accountWithBalances[b]!;

            switch (event.sortType) {
              case AccountSort.name:
                return a.name.toLowerCase().compareTo(b.name.toLowerCase());
              case AccountSort.balance:
                final totalDebtA =
                    balanceA.debtAssets + balanceA.debtLiabilities;
                final totalDebtB =
                    balanceB.debtAssets + balanceB.debtLiabilities;
                return totalDebtB.compareTo(totalDebtA);
              case AccountSort.recent:
                if (balanceA.lastActivity == null) return 1;
                if (balanceB.lastActivity == null) return -1;
                return balanceB.lastActivity!.compareTo(balanceA.lastActivity!);
              case AccountSort.dueDate:
                if (balanceA.nextDueDate == null) return 1;
                if (balanceB.nextDueDate == null) return -1;
                return balanceA.nextDueDate!.compareTo(balanceB.nextDueDate!);
            }
          });

          filteredAccounts = filteredWithStatus;

          final netWorthResult = await calculateNetWorthUseCase(
            const NoParams(),
          );
          netWorthResult.fold(
            (failure) => emit(AccountError(failure.message)),
            (netWorth) => emit(
              AccountAccountsLoaded(
                accounts: filteredAccounts,
                totalBalance: netWorth.vaultBalance,
                debtAssets: netWorth.debtAssets,
                debtLiabilities: netWorth.debtLiabilities,
                searchQuery: event.query,
                filter: event.filter,
                currentSort: event.sortType,
              ),
            ),
          );
        },
      );
    }
  }
}

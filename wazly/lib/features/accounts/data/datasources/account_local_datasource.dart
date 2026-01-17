import 'package:hive/hive.dart';
import '../models/account_model.dart';

abstract class AccountLocalDataSource {
  /// Get all accounts from local storage
  Future<List<AccountModel>> getAccounts();

  /// Get an account by ID
  Future<AccountModel> getAccountById(String id);

  /// Add a new account
  Future<void> addAccount(AccountModel account);

  /// Update an existing account
  Future<void> updateAccount(AccountModel account);

  /// Delete an account
  Future<void> deleteAccount(String id);
}

class AccountLocalDataSourceImpl implements AccountLocalDataSource {
  static const String _accountsBoxName = 'accounts';
  late Box<AccountModel> _accountsBox;

  Future<void> init() async {
    _accountsBox = await Hive.openBox<AccountModel>(_accountsBoxName);
  }

  @override
  Future<List<AccountModel>> getAccounts() async {
    return _accountsBox.values.toList();
  }

  @override
  Future<AccountModel> getAccountById(String id) async {
    final account = _accountsBox.get(id);
    if (account == null) {
      throw Exception('Account with id $id not found');
    }
    return account;
  }

  @override
  Future<void> addAccount(AccountModel account) async {
    await _accountsBox.put(account.id, account);
  }

  @override
  Future<void> updateAccount(AccountModel account) async {
    if (!_accountsBox.containsKey(account.id)) {
      throw Exception('Account with id ${account.id} not found');
    }
    await _accountsBox.put(account.id, account);
  }

  @override
  Future<void> deleteAccount(String id) async {
    if (!_accountsBox.containsKey(id)) {
      throw Exception('Account with id $id not found');
    }
    await _accountsBox.delete(id);
  }
}

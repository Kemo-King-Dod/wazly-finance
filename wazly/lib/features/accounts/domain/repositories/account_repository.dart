import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/account_entity.dart';

abstract class AccountRepository {
  /// Get all accounts
  Future<Either<Failure, List<AccountEntity>>> getAccounts();

  /// Get account by ID
  Future<Either<Failure, AccountEntity>> getAccountById(String id);

  /// Add a new account
  Future<Either<Failure, void>> addAccount(AccountEntity account);

  /// Update an existing account
  Future<Either<Failure, void>> updateAccount(AccountEntity account);

  /// Delete an account
  Future<Either<Failure, void>> deleteAccount(String id);
}

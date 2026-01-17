import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_local_datasource.dart';
import '../models/account_model.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountLocalDataSource localDataSource;

  AccountRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<AccountEntity>>> getAccounts() async {
    try {
      final accounts = await localDataSource.getAccounts();
      return Right(accounts.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get accounts: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AccountEntity>> getAccountById(String id) async {
    try {
      final account = await localDataSource.getAccountById(id);
      return Right(account.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to get account: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> addAccount(AccountEntity account) async {
    try {
      final model = AccountModel.fromEntity(account);
      await localDataSource.addAccount(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to add account: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateAccount(AccountEntity account) async {
    try {
      final model = AccountModel.fromEntity(account);
      await localDataSource.updateAccount(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to update account: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String id) async {
    try {
      await localDataSource.deleteAccount(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete account: ${e.toString()}'));
    }
  }
}

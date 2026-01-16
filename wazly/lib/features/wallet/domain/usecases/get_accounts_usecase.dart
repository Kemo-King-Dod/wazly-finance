import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/account_entity.dart';
import '../repositories/wallet_repository.dart';

/// Use case for getting all accounts
class GetAccountsUseCase implements UseCase<List<AccountEntity>, NoParams> {
  final WalletRepository repository;

  GetAccountsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AccountEntity>>> call(NoParams params) async {
    return await repository.getAccounts();
  }
}

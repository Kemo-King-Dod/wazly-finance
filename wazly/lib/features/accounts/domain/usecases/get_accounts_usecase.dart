import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../features/accounts/domain/entities/account_entity.dart';
import '../repositories/account_repository.dart';

/// Use case for getting all accounts
class GetAccountsUseCase implements UseCase<List<AccountEntity>, NoParams> {
  final AccountRepository repository;

  GetAccountsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AccountEntity>>> call(NoParams params) async {
    return await repository.getAccounts();
  }
}

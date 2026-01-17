import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/account_repository.dart';

class DeleteAccountUseCase implements UseCase<void, String> {
  final AccountRepository repository;

  DeleteAccountUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String accountId) async {
    return await repository.deleteAccount(accountId);
  }
}

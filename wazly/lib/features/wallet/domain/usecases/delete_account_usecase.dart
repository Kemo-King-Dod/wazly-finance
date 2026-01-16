import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/wallet_repository.dart';

class DeleteAccountUseCase implements UseCase<void, String> {
  final WalletRepository repository;

  DeleteAccountUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String accountId) async {
    return await repository.deleteAccount(accountId);
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/wallet_repository.dart';

/// Use case for getting all transactions
class GetTransactionsUseCase
    implements UseCase<List<TransactionEntity>, NoParams> {
  final WalletRepository repository;

  GetTransactionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(NoParams params) async {
    return await repository.getTransactions();
  }
}

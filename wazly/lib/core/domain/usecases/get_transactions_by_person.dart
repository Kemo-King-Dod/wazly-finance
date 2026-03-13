import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../../usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsByPersonParams {
  final String personId;

  const GetTransactionsByPersonParams({required this.personId});
}

class GetTransactionsByPerson
    implements UseCase<List<Transaction>, GetTransactionsByPersonParams> {
  final TransactionRepository repository;

  GetTransactionsByPerson(this.repository);

  @override
  Future<Either<Failure, List<Transaction>>> call(
    GetTransactionsByPersonParams params,
  ) async {
    return await repository.getTransactionsByPerson(params.personId);
  }
}

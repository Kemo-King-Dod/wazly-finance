import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  // Queries
  Future<Either<Failure, List<Transaction>>> getTransactionsByPerson(
    String personId,
  );
  Future<Either<Failure, List<Transaction>>> getRecentTransactions(int limit);

  Future<Either<Failure, Transaction>> getTransactionById(String id);

  // Note: Aggregation Queries delegated to PersonRepository.
  // Mutations
  Future<Either<Failure, void>> addTransaction(Transaction transaction);
  Future<Either<Failure, void>> deleteTransactionById(String id);
  Future<Either<Failure, void>> deleteTransactionsByPersonId(String personId);
}

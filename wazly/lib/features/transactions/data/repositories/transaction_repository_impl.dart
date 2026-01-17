import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/audit_log_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_model.dart';
import '../models/audit_log_model.dart';

/// Implementation of TransactionRepository
/// Bridges the data layer (LocalDataSource) with the domain layer
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions() async {
    try {
      final transactions = await localDataSource.getTransactions();
      return Right(transactions.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get transactions: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransactionById(
    String id,
  ) async {
    try {
      final transaction = await localDataSource.getTransactionById(id);
      return Right(transaction.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to get transaction: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await localDataSource.addTransaction(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to add transaction: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await localDataSource.updateTransaction(model);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Failed to update transaction: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      await localDataSource.deleteTransaction(id);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Failed to delete transaction: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateTransactionWithAudit({
    required TransactionEntity oldTransaction,
    required TransactionEntity newTransaction,
    required String reason,
  }) async {
    try {
      // Create audit log entry
      final auditLog = AuditLogModel(
        id: const Uuid().v4(),
        transactionId: newTransaction.id,
        oldAmount: oldTransaction.amount,
        newAmount: newTransaction.amount,
        reason: reason,
        timestamp: DateTime.now(),
      );

      // Update the transaction
      final model = TransactionModel.fromEntity(newTransaction);
      await localDataSource.updateTransaction(model);

      // Save the audit log
      await localDataSource.addAuditLog(auditLog);

      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          'Failed to update transaction with audit: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<AuditLogEntity>>> getAuditLogs() async {
    try {
      final auditLogs = await localDataSource.getAuditLogs();
      return Right(auditLogs.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get audit logs: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<AuditLogEntity>>> getAuditLogsForTransaction(
    String transactionId,
  ) async {
    try {
      final auditLogs = await localDataSource.getAuditLogsForTransaction(
        transactionId,
      );
      return Right(auditLogs.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(
        CacheFailure(
          'Failed to get audit logs for transaction: ${e.toString()}',
        ),
      );
    }
  }
}

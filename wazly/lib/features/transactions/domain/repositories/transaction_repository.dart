import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';
import '../entities/audit_log_entity.dart';

abstract class TransactionRepository {
  /// Get all transactions
  Future<Either<Failure, List<TransactionEntity>>> getTransactions();

  /// Get transaction by ID
  Future<Either<Failure, TransactionEntity>> getTransactionById(String id);

  /// Add a new transaction
  Future<Either<Failure, void>> addTransaction(TransactionEntity transaction);

  /// Update an existing transaction
  Future<Either<Failure, void>> updateTransaction(
    TransactionEntity transaction,
  );

  /// Update transaction with audit log (requires reason)
  Future<Either<Failure, void>> updateTransactionWithAudit({
    required TransactionEntity oldTransaction,
    required TransactionEntity newTransaction,
    required String reason,
  });

  /// Delete a transaction
  Future<Either<Failure, void>> deleteTransaction(String id);

  /// Get all audit logs
  Future<Either<Failure, List<AuditLogEntity>>> getAuditLogs();

  /// Get audit logs for a specific transaction
  Future<Either<Failure, List<AuditLogEntity>>> getAuditLogsForTransaction(
    String transactionId,
  );
}

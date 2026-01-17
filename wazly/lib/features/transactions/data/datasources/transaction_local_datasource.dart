import 'package:hive/hive.dart';
import '../models/transaction_model.dart';
import '../models/audit_log_model.dart';

/// Abstract class defining the contract for local data operations
abstract class TransactionLocalDataSource {
  /// Get all transactions from local storage
  Future<List<TransactionModel>> getTransactions();

  /// Get a transaction by ID
  Future<TransactionModel> getTransactionById(String id);

  /// Add a new transaction
  Future<void> addTransaction(TransactionModel transaction);

  /// Update an existing transaction
  Future<void> updateTransaction(TransactionModel transaction);

  /// Delete a transaction
  Future<void> deleteTransaction(String id);

  /// Get all audit logs
  Future<List<AuditLogModel>> getAuditLogs();

  /// Get audit logs for a specific transaction
  Future<List<AuditLogModel>> getAuditLogsForTransaction(String transactionId);

  /// Add an audit log entry
  Future<void> addAuditLog(AuditLogModel auditLog);
}

/// Implementation of WalletLocalDataSource using Hive
class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  static const String _transactionsBoxName = 'transactions';
  static const String _auditLogsBoxName = 'audit_logs';

  late Box<TransactionModel> _transactionsBox;
  late Box<AuditLogModel> _auditLogsBox;

  /// Initialize Hive boxes
  Future<void> init() async {
    _transactionsBox = await Hive.openBox<TransactionModel>(
      _transactionsBoxName,
    );
    _auditLogsBox = await Hive.openBox<AuditLogModel>(_auditLogsBoxName);
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    try {
      return _transactionsBox.values.toList();
    } catch (e) {
      throw Exception('Failed to get transactions: $e');
    }
  }

  @override
  Future<TransactionModel> getTransactionById(String id) async {
    try {
      final transaction = _transactionsBox.get(id);
      if (transaction == null) {
        throw Exception('Transaction with id $id not found');
      }
      return transaction;
    } catch (e) {
      throw Exception('Failed to get transaction: $e');
    }
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _transactionsBox.put(transaction.id, transaction);
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      if (!_transactionsBox.containsKey(transaction.id)) {
        throw Exception('Transaction with id ${transaction.id} not found');
      }
      await _transactionsBox.put(transaction.id, transaction);
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      if (!_transactionsBox.containsKey(id)) {
        throw Exception('Transaction with id $id not found');
      }
      await _transactionsBox.delete(id);
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  @override
  Future<List<AuditLogModel>> getAuditLogs() async {
    try {
      return _auditLogsBox.values.toList();
    } catch (e) {
      throw Exception('Failed to get audit logs: $e');
    }
  }

  @override
  Future<List<AuditLogModel>> getAuditLogsForTransaction(
    String transactionId,
  ) async {
    try {
      return _auditLogsBox.values
          .where((log) => log.transactionId == transactionId)
          .toList();
    } catch (e) {
      throw Exception('Failed to get audit logs for transaction: $e');
    }
  }

  @override
  Future<void> addAuditLog(AuditLogModel auditLog) async {
    try {
      await _auditLogsBox.put(auditLog.id, auditLog);
    } catch (e) {
      throw Exception('Failed to add audit log: $e');
    }
  }

  /// Close all boxes
  Future<void> close() async {
    await _transactionsBox.close();
    await _auditLogsBox.close();
  }

  /// Clear all data (useful for testing)
  Future<void> clearAll() async {
    await _transactionsBox.clear();
    await _auditLogsBox.clear();
  }
}

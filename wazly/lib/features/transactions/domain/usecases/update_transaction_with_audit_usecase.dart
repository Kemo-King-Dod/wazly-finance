import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Parameters for updating a transaction with audit log
class UpdateTransactionWithAuditParams extends Equatable {
  final TransactionEntity oldTransaction;
  final TransactionEntity newTransaction;
  final String reason;

  const UpdateTransactionWithAuditParams({
    required this.oldTransaction,
    required this.newTransaction,
    required this.reason,
  });

  @override
  List<Object?> get props => [oldTransaction, newTransaction, reason];
}

/// Use case for updating a transaction with mandatory audit log
class UpdateTransactionWithAuditUseCase
    implements UseCase<void, UpdateTransactionWithAuditParams> {
  final TransactionRepository repository;

  UpdateTransactionWithAuditUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(
    UpdateTransactionWithAuditParams params,
  ) async {
    // Validate: Reason must not be empty
    if (params.reason.trim().isEmpty) {
      return const Left(ValidationFailure('Modification reason is required'));
    }

    // Validate: Transactions must have the same ID
    if (params.oldTransaction.id != params.newTransaction.id) {
      return const Left(ValidationFailure('Transaction IDs must match'));
    }

    // Update the transaction with the reason
    final updatedTransaction = TransactionEntity(
      id: params.newTransaction.id,
      amount: params.newTransaction.amount,
      category: params.newTransaction.category,
      date: params.newTransaction.date,
      description: params.newTransaction.description,
      isIncome: params.newTransaction.isIncome,
      isDebt: params.newTransaction.isDebt,
      accountId: params.newTransaction.accountId,
      linkedAccountId: params.newTransaction.linkedAccountId,
      debtStatus: params.newTransaction.debtStatus,
      lastModifiedReason: params.reason,
    );

    // Call repository to update transaction and create audit log
    return await repository.updateTransactionWithAudit(
      oldTransaction: params.oldTransaction,
      newTransaction: updatedTransaction,
      reason: params.reason,
    );
  }
}

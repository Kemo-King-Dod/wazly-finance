import 'package:equatable/equatable.dart';
import 'debt_status.dart';

class TransactionEntity extends Equatable {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String description;
  final bool isIncome;
  final bool isDebt;
  final String accountId;

  /// Optional: Links transaction to a person/account (for debts)
  final String? linkedAccountId;

  /// Optional: Status of debt (open, partial, settled)
  final DebtStatus? debtStatus;

  /// Optional: Due date for debt repayment
  final DateTime? dueDate;

  /// Whether to send notification reminder for this debt
  final bool hasNotification;

  /// Whether this debt has been fully settled
  final bool isSettled;

  /// Optional: Reason for last modification (for audit log)
  final String? lastModifiedReason;

  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    required this.isIncome,
    required this.isDebt,
    required this.accountId,
    this.linkedAccountId,
    this.debtStatus,
    this.dueDate,
    this.hasNotification = false,
    this.isSettled = false,
    this.lastModifiedReason,
  });

  @override
  List<Object?> get props => [
    id,
    amount,
    category,
    date,
    description,
    isIncome,
    isDebt,
    accountId,
    linkedAccountId,
    debtStatus,
    dueDate,
    hasNotification,
    isSettled,
    lastModifiedReason,
  ];
}

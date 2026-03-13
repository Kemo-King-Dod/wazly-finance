import 'package:equatable/equatable.dart';
import 'transaction_enums.dart';

class InstallmentPlan extends Equatable {
  final String id;
  final String personId;
  final String originalTransactionId; // The debt this plan belongs to
  final DebtDirection
  direction; // Needed to know if I am paying them or they are paying me
  final int totalAmountInCents; // Always positive
  final String title; // E.g., "Car Loan Repayment"
  final DateTime createdAt;
  final bool isCompleted;

  InstallmentPlan({
    required this.id,
    required this.personId,
    required this.originalTransactionId,
    required this.direction,
    required this.totalAmountInCents,
    required this.title,
    required this.createdAt,
    required this.isCompleted,
  }) {
    validate();
  }

  /// Validates the domain constraints for the installment plan.
  /// Throws [ArgumentError] if the validation fails.
  void validate() {
    if (totalAmountInCents <= 0) {
      throw ArgumentError('Total amount must be greater than zero');
    }
  }

  @override
  List<Object?> get props => [
    id,
    personId,
    originalTransactionId,
    direction,
    totalAmountInCents,
    title,
    createdAt,
    isCompleted,
  ];
}

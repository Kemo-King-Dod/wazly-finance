import 'package:equatable/equatable.dart';

class InstallmentItem extends Equatable {
  final String id;
  final String planId; // Links back to InstallmentPlan
  final int amountInCents;
  final DateTime dueDate;
  final bool isPaid;
  final DateTime? paidDate;
  final int?
  notificationId; // Links to local notification system ID for reminders

  InstallmentItem({
    required this.id,
    required this.planId,
    required this.amountInCents,
    required this.dueDate,
    required this.isPaid,
    this.paidDate,
    this.notificationId,
  }) {
    validate();
  }

  /// Validates the domain constraints for the installment item.
  /// Throws [ArgumentError] if the validation fails.
  void validate() {
    if (amountInCents <= 0) {
      throw ArgumentError('Installment item amount must be greater than zero');
    }
  }

  @override
  List<Object?> get props => [
    id,
    planId,
    amountInCents,
    dueDate,
    isPaid,
    paidDate,
    notificationId,
  ];
}

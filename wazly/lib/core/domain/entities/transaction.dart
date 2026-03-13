import 'package:equatable/equatable.dart';
import 'transaction_enums.dart';

class Transaction extends Equatable {
  final String id;

  /// The absolute value of the transaction in cents. Must always be positive.
  /// The actual financial effect is determined by combining [amountInCents] with [type] and [direction].
  final int amountInCents;
  final TransactionType type;

  // Applies only if type is 'debt' or 'payment'
  final DebtDirection? direction;

  final String description;
  final DateTime date;
  final String? personId; // Null if it's a general treasuryIn/treasuryOut

  Transaction({
    required this.id,
    required this.amountInCents,
    required this.type,
    this.direction,
    required this.description,
    required this.date,
    this.personId,
  }) {
    validate();
  }

  /// Validates the domain constraints for the transaction.
  /// Throws [ArgumentError] if the validation fails.
  void validate() {
    if (amountInCents < 0) {
      throw ArgumentError('Transaction amount must be positive');
    }

    final bool isDebtOrPayment =
        type == TransactionType.debt || type == TransactionType.payment;
    if (isDebtOrPayment && direction == null) {
      throw ArgumentError(
        'Debt and Payment transactions must have a direction.',
      );
    }
    if (!isDebtOrPayment && direction != null) {
      throw ArgumentError('Treasury flows must not have a direction.');
    }
  }

  /// Calculates the delta for the Person's net balance based on this transaction.
  /// Positive: They owe me more (my asset increases)
  /// Negative: I owe them more (my liability increases)
  int signedAmountForPerson() {
    if (type == TransactionType.debt) {
      return direction == DebtDirection.theyOweMe
          ? amountInCents
          : -amountInCents;
    } else if (type == TransactionType.payment) {
      // If it's a payment, the balances move in the opposite direction of the original debt
      return direction == DebtDirection.theyOweMe
          ? -amountInCents
          : amountInCents;
    }
    return 0; // treasuryIn and treasuryOut do not affect Person balances
  }

  /// Calculates the delta for the global Treasury balance based on this transaction.
  int signedAmountForTreasury() {
    if (type == TransactionType.treasuryIn) {
      return amountInCents;
    } else if (type == TransactionType.treasuryOut) {
      return -amountInCents;
    } else if (type == TransactionType.payment) {
      // If they are paying me, treasury increases. If I pay them, treasury decreases.
      return direction == DebtDirection.theyOweMe
          ? amountInCents
          : -amountInCents;
    }
    // Debt creation purely records liability; it does not touch the treasury.
    return 0;
  }

  @override
  List<Object?> get props => [
    id,
    amountInCents,
    type,
    direction,
    description,
    date,
    personId,
  ];
}

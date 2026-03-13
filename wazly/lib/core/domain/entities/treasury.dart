import 'package:equatable/equatable.dart';
import 'transaction.dart';

class Treasury extends Equatable {
  final int
  balanceInCents; // The current net balance in cents (can be positive or negative)
  final String currency; // E.g., 'LYD', fixed for the app based on requirements

  const Treasury({required this.balanceInCents, required this.currency});

  // Business logic: Add or subtract from treasury (returns new instance for immutability)
  Treasury copyWith({int? balanceInCents, String? currency}) {
    return Treasury(
      balanceInCents: balanceInCents ?? this.balanceInCents,
      currency: currency ?? this.currency,
    );
  }

  /// Mutates the treasury balance immutably based on a transaction's domain rules.
  Treasury applyTransaction(Transaction tx) {
    return copyWith(
      balanceInCents: balanceInCents + tx.signedAmountForTreasury(),
    );
  }

  @override
  List<Object?> get props => [balanceInCents, currency];
}

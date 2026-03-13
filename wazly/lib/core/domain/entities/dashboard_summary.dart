import 'package:equatable/equatable.dart';
import 'treasury.dart';
import 'person_with_balance.dart';
import 'transaction.dart';

class DashboardSummary extends Equatable {
  final Treasury treasury;
  final List<PersonWithBalance> activeDebts;
  final List<Transaction> recentTransactions;

  const DashboardSummary({
    required this.treasury,
    required this.activeDebts,
    required this.recentTransactions,
  });

  @override
  List<Object?> get props => [treasury, activeDebts, recentTransactions];
}

import 'package:equatable/equatable.dart';

/// Result of net worth calculation
class NetWorthResult extends Equatable {
  final double vaultBalance;
  final double debtAssets;
  final double debtLiabilities;

  const NetWorthResult({
    required this.vaultBalance,
    required this.debtAssets,
    required this.debtLiabilities,
  });

  double get totalNetWorth => vaultBalance + debtAssets - debtLiabilities;

  @override
  List<Object?> get props => [vaultBalance, debtAssets, debtLiabilities];
}

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Entity representing category-wise expense data for analytics
class CategoryExpense extends Equatable {
  final String category;
  final double amount;
  final Color color;
  final int transactionCount;

  const CategoryExpense({
    required this.category,
    required this.amount,
    required this.color,
    required this.transactionCount,
  });

  /// Calculate percentage of total
  double getPercentage(double total) {
    if (total == 0) return 0;
    return (amount / total) * 100;
  }

  @override
  List<Object?> get props => [category, amount, color, transactionCount];
}

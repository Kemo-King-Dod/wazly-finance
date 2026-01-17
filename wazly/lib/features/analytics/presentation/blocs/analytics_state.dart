import 'package:equatable/equatable.dart';
import '../../domain/entities/category_expense.dart';
import '../../domain/entities/time_filter.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

class AnalyticsLoaded extends AnalyticsState {
  final List<CategoryExpense> categoryExpenses;
  final double totalIncome;
  final double totalExpenses;
  final TimeFilter currentFilter;
  final double totalBalance;
  final double debtAssets;
  final double debtLiabilities;

  const AnalyticsLoaded({
    required this.categoryExpenses,
    required this.totalIncome,
    required this.totalExpenses,
    required this.currentFilter,
    this.totalBalance = 0,
    this.debtAssets = 0,
    this.debtLiabilities = 0,
  });

  double get netWorth => totalBalance + debtAssets - debtLiabilities;

  @override
  List<Object?> get props => [
    categoryExpenses,
    totalIncome,
    totalExpenses,
    currentFilter,
    totalBalance,
    debtAssets,
    debtLiabilities,
  ];

  AnalyticsLoaded copyWith({
    List<CategoryExpense>? categoryExpenses,
    double? totalIncome,
    double? totalExpenses,
    TimeFilter? currentFilter,
    double? totalBalance,
    double? debtAssets,
    double? debtLiabilities,
  }) {
    return AnalyticsLoaded(
      categoryExpenses: categoryExpenses ?? this.categoryExpenses,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      currentFilter: currentFilter ?? this.currentFilter,
      totalBalance: totalBalance ?? this.totalBalance,
      debtAssets: debtAssets ?? this.debtAssets,
      debtLiabilities: debtLiabilities ?? this.debtLiabilities,
    );
  }
}

class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}

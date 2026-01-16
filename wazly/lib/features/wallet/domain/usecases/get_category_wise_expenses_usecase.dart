import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction_entity.dart';
import '../entities/category_expense.dart';
import '../entities/time_filter.dart';
import '../repositories/wallet_repository.dart';
import '../../../wallet/presentation/widgets/transaction_category.dart';

/// Parameters for GetCategoryWiseExpensesUseCase
class CategoryExpensesParams extends Equatable {
  final TimeFilter filter;

  const CategoryExpensesParams({required this.filter});

  @override
  List<Object?> get props => [filter];
}

/// Use case for getting category-wise expenses for analytics
class GetCategoryWiseExpensesUseCase
    implements UseCase<List<CategoryExpense>, CategoryExpensesParams> {
  final WalletRepository repository;

  GetCategoryWiseExpensesUseCase(this.repository);

  @override
  Future<Either<Failure, List<CategoryExpense>>> call(
    CategoryExpensesParams params,
  ) async {
    try {
      // Get all transactions
      final transactionsResult = await repository.getTransactions();

      return transactionsResult.fold((failure) => Left(failure), (
        transactions,
      ) {
        // Filter transactions based on time filter
        final filteredTransactions = _filterByTime(transactions, params.filter);

        // Group expenses by category
        final categoryExpenses = _groupByCategory(filteredTransactions);

        return Right(categoryExpenses);
      });
    } catch (e) {
      return Left(GeneralFailure('Failed to get category expenses: $e'));
    }
  }

  /// Filter transactions by time period
  List<TransactionEntity> _filterByTime(
    List<TransactionEntity> transactions,
    TimeFilter filter,
  ) {
    final now = DateTime.now();

    switch (filter) {
      case TimeFilter.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return transactions.where((t) {
          return t.date.isAfter(
                startOfMonth.subtract(const Duration(seconds: 1)),
              ) &&
              t.date.isBefore(endOfMonth.add(const Duration(seconds: 1)));
        }).toList();

      case TimeFilter.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        final endOfLastMonth = DateTime(now.year, now.month, 0, 23, 59, 59);
        return transactions.where((t) {
          return t.date.isAfter(
                lastMonth.subtract(const Duration(seconds: 1)),
              ) &&
              t.date.isBefore(endOfLastMonth.add(const Duration(seconds: 1)));
        }).toList();

      case TimeFilter.allTime:
        return transactions;
    }
  }

  /// Group expenses by category
  List<CategoryExpense> _groupByCategory(List<TransactionEntity> transactions) {
    // Filter: Only expenses (not income) and not debts
    final expenses = transactions
        .where((t) => !t.isIncome && !t.isDebt)
        .toList();

    if (expenses.isEmpty) {
      return [];
    }

    // Group by category
    final Map<String, List<TransactionEntity>> grouped = {};
    for (final expense in expenses) {
      if (!grouped.containsKey(expense.category)) {
        grouped[expense.category] = [];
      }
      grouped[expense.category]!.add(expense);
    }

    // Convert to CategoryExpense list
    final List<CategoryExpense> result = [];
    for (final entry in grouped.entries) {
      final category = entry.key;
      final categoryTransactions = entry.value;
      final totalAmount = categoryTransactions.fold<double>(
        0,
        (sum, t) => sum + t.amount,
      );

      // Get color from TransactionCategories
      final categoryData = TransactionCategories.categories.firstWhere(
        (c) => c.name == category,
        orElse: () =>
            TransactionCategories.categories.last, // Default to "Other"
      );

      result.add(
        CategoryExpense(
          category: category,
          amount: totalAmount,
          color: categoryData.color,
          transactionCount: categoryTransactions.length,
        ),
      );
    }

    // Sort by amount (descending)
    result.sort((a, b) => b.amount.compareTo(a.amount));

    return result;
  }
}

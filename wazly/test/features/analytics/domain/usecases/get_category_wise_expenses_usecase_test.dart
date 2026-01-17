import 'package:flutter_test/flutter_test.dart';
import 'package:wazly/features/transactions/domain/entities/transaction_entity.dart';
import 'package:wazly/features/analytics/domain/entities/time_filter.dart';
import 'package:wazly/features/analytics/domain/usecases/get_category_wise_expenses_usecase.dart';
import 'package:wazly/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'get_category_wise_expenses_usecase_test.mocks.dart';

@GenerateMocks([TransactionRepository])
void main() {
  late GetCategoryWiseExpensesUseCase useCase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = GetCategoryWiseExpensesUseCase(mockRepository);
  });

  group('GetCategoryWiseExpensesUseCase', () {
    final testTransactions = [
      TransactionEntity(
        id: '1',
        amount: 300.0,
        category: 'Food',
        date: DateTime.now(),
        description: 'Groceries',
        isIncome: false,
        isDebt: false,
        accountId: 'default',
      ),
      TransactionEntity(
        id: '2',
        amount: 200.0,
        category: 'Food',
        date: DateTime.now(),
        description: 'Restaurant',
        isIncome: false,
        isDebt: false,
        accountId: 'default',
      ),
      TransactionEntity(
        id: '3',
        amount: 150.0,
        category: 'Transport',
        date: DateTime.now(),
        description: 'Taxi',
        isIncome: false,
        isDebt: false,
        accountId: 'default',
      ),
      // Income - should be excluded
      TransactionEntity(
        id: '4',
        amount: 1000.0,
        category: 'Salary',
        date: DateTime.now(),
        description: 'Monthly salary',
        isIncome: true,
        isDebt: false,
        accountId: 'default',
      ),
      // Debt - should be excluded
      TransactionEntity(
        id: '5',
        amount: 500.0,
        category: 'Debt',
        date: DateTime.now(),
        description: 'John owes me',
        isIncome: true,
        isDebt: true,
        accountId: 'default',
      ),
    ];

    test('should group expenses by category correctly', () async {
      // Arrange
      when(
        mockRepository.getTransactions(),
      ).thenAnswer((_) async => Right(testTransactions));

      // Act
      final result = await useCase(
        const CategoryExpensesParams(filter: TimeFilter.allTime),
      );

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Should not return failure'), (
        categoryExpenses,
      ) {
        expect(categoryExpenses.length, 2); // Food and Transport

        // Food should be first (highest amount)
        expect(categoryExpenses[0].category, 'Food');
        expect(categoryExpenses[0].amount, 500.0); // 300 + 200
        expect(categoryExpenses[0].transactionCount, 2);

        // Transport should be second
        expect(categoryExpenses[1].category, 'Transport');
        expect(categoryExpenses[1].amount, 150.0);
        expect(categoryExpenses[1].transactionCount, 1);
      });
    });

    test('should exclude income transactions', () async {
      // Arrange
      when(
        mockRepository.getTransactions(),
      ).thenAnswer((_) async => Right(testTransactions));

      // Act
      final result = await useCase(
        const CategoryExpensesParams(filter: TimeFilter.allTime),
      );

      // Assert
      result.fold((failure) => fail('Should not return failure'), (
        categoryExpenses,
      ) {
        // Should not include "Salary" category
        expect(categoryExpenses.any((c) => c.category == 'Salary'), false);
      });
    });

    test('should exclude debt transactions', () async {
      // Arrange
      when(
        mockRepository.getTransactions(),
      ).thenAnswer((_) async => Right(testTransactions));

      // Act
      final result = await useCase(
        const CategoryExpensesParams(filter: TimeFilter.allTime),
      );

      // Assert
      result.fold((failure) => fail('Should not return failure'), (
        categoryExpenses,
      ) {
        // Should not include "Debt" category
        expect(categoryExpenses.any((c) => c.category == 'Debt'), false);
      });
    });

    test('should return empty list when no expenses', () async {
      // Arrange
      final onlyIncome = [
        TransactionEntity(
          id: '1',
          amount: 1000.0,
          category: 'Salary',
          date: DateTime.now(),
          description: 'Monthly salary',
          isIncome: true,
          isDebt: false,
          accountId: 'default',
        ),
      ];
      when(
        mockRepository.getTransactions(),
      ).thenAnswer((_) async => Right(onlyIncome));

      // Act
      final result = await useCase(
        const CategoryExpensesParams(filter: TimeFilter.allTime),
      );

      // Assert
      result.fold((failure) => fail('Should not return failure'), (
        categoryExpenses,
      ) {
        expect(categoryExpenses.isEmpty, true);
      });
    });

    test('should filter by this month', () async {
      // Arrange
      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month, 15);
      final lastMonth = DateTime(now.year, now.month - 1, 15);

      final transactions = [
        TransactionEntity(
          id: '1',
          amount: 100.0,
          category: 'Food',
          date: thisMonth,
          description: 'This month expense',
          isIncome: false,
          isDebt: false,
          accountId: 'default',
        ),
        TransactionEntity(
          id: '2',
          amount: 200.0,
          category: 'Food',
          date: lastMonth,
          description: 'Last month expense',
          isIncome: false,
          isDebt: false,
          accountId: 'default',
        ),
      ];

      when(
        mockRepository.getTransactions(),
      ).thenAnswer((_) async => Right(transactions));

      // Act
      final result = await useCase(
        const CategoryExpensesParams(filter: TimeFilter.thisMonth),
      );

      // Assert
      result.fold((failure) => fail('Should not return failure'), (
        categoryExpenses,
      ) {
        expect(categoryExpenses.length, 1);
        expect(categoryExpenses[0].amount, 100.0); // Only this month
      });
    });

    test('should sort categories by amount descending', () async {
      // Arrange
      final transactions = [
        TransactionEntity(
          id: '1',
          amount: 50.0,
          category: 'Transport',
          date: DateTime.now(),
          description: 'Bus',
          isIncome: false,
          isDebt: false,
          accountId: 'default',
        ),
        TransactionEntity(
          id: '2',
          amount: 300.0,
          category: 'Food',
          date: DateTime.now(),
          description: 'Groceries',
          isIncome: false,
          isDebt: false,
          accountId: 'default',
        ),
        TransactionEntity(
          id: '3',
          amount: 150.0,
          category: 'Shopping',
          date: DateTime.now(),
          description: 'Clothes',
          isIncome: false,
          isDebt: false,
          accountId: 'default',
        ),
      ];

      when(
        mockRepository.getTransactions(),
      ).thenAnswer((_) async => Right(transactions));

      // Act
      final result = await useCase(
        const CategoryExpensesParams(filter: TimeFilter.allTime),
      );

      // Assert
      result.fold((failure) => fail('Should not return failure'), (
        categoryExpenses,
      ) {
        expect(categoryExpenses[0].category, 'Food'); // 300
        expect(categoryExpenses[1].category, 'Shopping'); // 150
        expect(categoryExpenses[2].category, 'Transport'); // 50
      });
    });
  });
}

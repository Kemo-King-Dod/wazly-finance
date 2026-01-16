import 'package:flutter_test/flutter_test.dart';
import 'package:wazly/features/wallet/domain/entities/transaction_entity.dart';
import 'package:wazly/features/wallet/domain/entities/debt_status.dart';
import 'package:wazly/features/wallet/domain/usecases/balance_calculator.dart';

void main() {
  late BalanceCalculator calculator;

  setUp(() {
    calculator = BalanceCalculator();
  });

  group('BalanceCalculator - Debt Logic', () {
    test('should exclude debt records from balance calculation', () {
      // Arrange
      final transactions = [
        // Regular income
        TransactionEntity(
          id: '1',
          amount: 1000.0,
          category: 'Salary',
          date: DateTime(2024, 1, 1),
          description: 'Monthly salary',
          isIncome: true,
          isDebt: false,
          accountId: 'default',
        ),
        // Debt record (someone owes me) - should NOT affect balance
        TransactionEntity(
          id: '2',
          amount: 500.0,
          category: 'Debt',
          date: DateTime(2024, 1, 2),
          description: 'John owes me',
          isIncome: true,
          isDebt: true,
          accountId: 'default',
          linkedAccountId: 'john',
          debtStatus: DebtStatus.open,
        ),
        // Regular expense
        TransactionEntity(
          id: '3',
          amount: 200.0,
          category: 'Food',
          date: DateTime(2024, 1, 3),
          description: 'Groceries',
          isIncome: false,
          isDebt: false,
          accountId: 'default',
        ),
      ];

      // Act
      final balance = calculator.calculateBalance(transactions);

      // Assert
      // Balance should be: 1000 (income) - 200 (expense) = 800
      // The debt record (500) should NOT be included
      expect(balance, 800.0);
    });

    test(
      'should correctly calculate balance when a debt is partially paid',
      () {
        // Arrange
        final transactions = [
          // Initial balance
          TransactionEntity(
            id: '1',
            amount: 1000.0,
            category: 'Salary',
            date: DateTime(2024, 1, 1),
            description: 'Monthly salary',
            isIncome: true,
            isDebt: false,
            accountId: 'default',
          ),
          // Debt record (John owes me 500) - does NOT affect balance
          TransactionEntity(
            id: '2',
            amount: 500.0,
            category: 'Debt',
            date: DateTime(2024, 1, 2),
            description: 'John owes me',
            isIncome: true,
            isDebt: true,
            accountId: 'default',
            linkedAccountId: 'john',
            debtStatus: DebtStatus.open,
          ),
          // John pays me 200 (partial payment) - this DOES affect balance
          TransactionEntity(
            id: '3',
            amount: 200.0,
            category: 'Debt Payment',
            date: DateTime(2024, 1, 3),
            description: 'John partial payment',
            isIncome: true,
            isDebt: false, // This is a payment, not a debt record
            accountId: 'default',
            linkedAccountId: 'john',
          ),
        ];

        // Act
        final balance = calculator.calculateBalance(transactions);

        // Assert
        // Balance should be: 1000 (salary) + 200 (payment received) = 1200
        // The debt record (500) is excluded
        expect(balance, 1200.0);
      },
    );

    test('should calculate total debt assets correctly', () {
      // Arrange
      final transactions = [
        // Someone owes me 500
        TransactionEntity(
          id: '1',
          amount: 500.0,
          category: 'Debt',
          date: DateTime(2024, 1, 1),
          description: 'John owes me',
          isIncome: true,
          isDebt: true,
          accountId: 'default',
          linkedAccountId: 'john',
          debtStatus: DebtStatus.open,
        ),
        // Someone else owes me 300
        TransactionEntity(
          id: '2',
          amount: 300.0,
          category: 'Debt',
          date: DateTime(2024, 1, 2),
          description: 'Sarah owes me',
          isIncome: true,
          isDebt: true,
          accountId: 'default',
          linkedAccountId: 'sarah',
          debtStatus: DebtStatus.partial,
        ),
      ];

      // Act
      final totalDebtAssets = calculator.calculateTotalDebtAssets(transactions);

      // Assert
      expect(totalDebtAssets, 800.0);
    });

    test('should calculate total debt liabilities correctly', () {
      // Arrange
      final transactions = [
        // I owe someone 400
        TransactionEntity(
          id: '1',
          amount: 400.0,
          category: 'Debt',
          date: DateTime(2024, 1, 1),
          description: 'I owe Mike',
          isIncome: false,
          isDebt: true,
          accountId: 'default',
          linkedAccountId: 'mike',
          debtStatus: DebtStatus.open,
        ),
        // I owe someone else 250
        TransactionEntity(
          id: '2',
          amount: 250.0,
          category: 'Debt',
          date: DateTime(2024, 1, 2),
          description: 'I owe Lisa',
          isIncome: false,
          isDebt: true,
          accountId: 'default',
          linkedAccountId: 'lisa',
          debtStatus: DebtStatus.partial,
        ),
      ];

      // Act
      final totalDebtLiabilities = calculator.calculateTotalDebtLiabilities(
        transactions,
      );

      // Assert
      expect(totalDebtLiabilities, 650.0);
    });
  });

  group('BalanceCalculator - Original Tests', () {
    test('should return positive balance when income exceeds expenses', () {
      final transactions = [
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
        TransactionEntity(
          id: '2',
          amount: 300.0,
          category: 'Groceries',
          date: DateTime.now(),
          description: 'Weekly groceries',
          isIncome: false,
          isDebt: false,
          accountId: 'default',
        ),
      ];

      final balance = calculator.calculateBalance(transactions);
      expect(balance, 700.0);
    });

    test('should return negative balance when expenses exceed income', () {
      final transactions = [
        TransactionEntity(
          id: '1',
          amount: 500.0,
          category: 'Salary',
          date: DateTime.now(),
          description: 'Part-time income',
          isIncome: true,
          isDebt: false,
          accountId: 'default',
        ),
        TransactionEntity(
          id: '2',
          amount: 800.0,
          category: 'Rent',
          date: DateTime.now(),
          description: 'Monthly rent',
          isIncome: false,
          isDebt: false,
          accountId: 'default',
        ),
      ];

      final balance = calculator.calculateBalance(transactions);
      expect(balance, -300.0);
    });

    test('should return zero balance when income equals expenses', () {
      final transactions = [
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
        TransactionEntity(
          id: '2',
          amount: 1000.0,
          category: 'Expenses',
          date: DateTime.now(),
          description: 'Total expenses',
          isIncome: false,
          isDebt: false,
          accountId: 'default',
        ),
      ];

      final balance = calculator.calculateBalance(transactions);
      expect(balance, 0.0);
    });

    test('should handle decimal amounts correctly', () {
      final transactions = [
        TransactionEntity(
          id: '1',
          amount: 1234.56,
          category: 'Salary',
          date: DateTime.now(),
          description: 'Monthly salary',
          isIncome: true,
          isDebt: false,
          accountId: 'default',
        ),
        TransactionEntity(
          id: '2',
          amount: 234.56,
          category: 'Shopping',
          date: DateTime.now(),
          description: 'Online purchase',
          isIncome: false,
          isDebt: false,
          accountId: 'default',
        ),
      ];

      final balance = calculator.calculateBalance(transactions);
      expect(balance, 1000.0);
    });

    test('should return zero for empty transaction list', () {
      final transactions = <TransactionEntity>[];
      final balance = calculator.calculateBalance(transactions);
      expect(balance, 0.0);
    });
  });
}

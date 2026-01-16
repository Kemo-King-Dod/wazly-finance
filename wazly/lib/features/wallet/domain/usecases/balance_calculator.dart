import '../entities/transaction_entity.dart';

/// Calculator for computing the Main Vault balance
///
/// The Main Vault balance represents the user's actual available money.
/// It includes all income and expenses, but EXCLUDES debts unless they are paid.
class BalanceCalculator {
  /// Calculate the Main Vault balance from a list of transactions
  ///
  /// Formula: Total Income - Total Expenses
  ///
  /// IMPORTANT: Transactions marked as `isDebt` are excluded from the calculation
  /// unless they represent actual payments (which would be separate transactions).
  ///
  /// Debt Logic:
  /// - Recording a debt (isDebt=true) does NOT affect the balance
  /// - When a debt is paid (partial or full), a new transaction is created
  ///   which DOES affect the balance
  double calculateBalance(List<TransactionEntity> transactions) {
    double totalIncome = 0.0;
    double totalExpenses = 0.0;

    for (final transaction in transactions) {
      // Skip debt records - they don't affect the Main Vault
      // Only actual payments (separate transactions) affect the balance
      if (transaction.isDebt) {
        continue;
      }

      if (transaction.isIncome) {
        totalIncome += transaction.amount;
      } else {
        totalExpenses += transaction.amount;
      }
    }

    return totalIncome - totalExpenses;
  }

  /// Calculate total debt amount (money owed TO the user - Assets)
  double calculateTotalDebtAssets(List<TransactionEntity> transactions) {
    return transactions
        .where((t) => t.isDebt && t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculate total debt liabilities (money user OWES to others)
  double calculateTotalDebtLiabilities(List<TransactionEntity> transactions) {
    return transactions
        .where((t) => t.isDebt && !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}

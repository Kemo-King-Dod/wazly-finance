import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

/// Category data model for transaction categories
class TransactionCategory {
  final String name;
  final IconData icon;
  final Color color;

  const TransactionCategory({
    required this.name,
    required this.icon,
    required this.color,
  });

  /// Get localized category name
  String getLocalizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (name) {
      case 'Salary':
        return l10n.categorySalary;
      case 'Food':
        return l10n.categoryFood;
      case 'Transport':
        return l10n.categoryTransport;
      case 'Shopping':
        return l10n.categoryShopping;
      case 'Bills':
        return l10n.categoryBills;
      case 'Health':
        return l10n.categoryHealth;
      case 'Entertainment':
        return l10n.categoryEntertainment;
      case 'Education':
        return l10n.categoryEducation;
      case 'Debt':
        return l10n.categoryDebt;
      case 'Other':
      default:
        return l10n.categoryOther;
    }
  }
}

/// Predefined transaction categories
class TransactionCategories {
  static const List<TransactionCategory> categories = [
    TransactionCategory(
      name: 'Salary',
      icon: Icons.account_balance_wallet,
      color: Color(0xFF50C878),
    ),
    TransactionCategory(
      name: 'Food',
      icon: Icons.restaurant,
      color: Color(0xFFFF6B6B),
    ),
    TransactionCategory(
      name: 'Transport',
      icon: Icons.directions_car,
      color: Color(0xFF4ECDC4),
    ),
    TransactionCategory(
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: Color(0xFFFFBE0B),
    ),
    TransactionCategory(
      name: 'Bills',
      icon: Icons.receipt_long,
      color: Color(0xFFFF006E),
    ),
    TransactionCategory(
      name: 'Health',
      icon: Icons.local_hospital,
      color: Color(0xFF8338EC),
    ),
    TransactionCategory(
      name: 'Entertainment',
      icon: Icons.movie,
      color: Color(0xFFFB5607),
    ),
    TransactionCategory(
      name: 'Education',
      icon: Icons.school,
      color: Color(0xFF3A86FF),
    ),
    TransactionCategory(
      name: 'Debt',
      icon: Icons.credit_card,
      color: Color(0xFFFF4E50),
    ),
    TransactionCategory(
      name: 'Other',
      icon: Icons.more_horiz,
      color: Color(0xFF95A5A6),
    ),
  ];
}

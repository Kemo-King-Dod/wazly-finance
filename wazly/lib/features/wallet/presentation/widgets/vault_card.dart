import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'animated_balance_display.dart';

/// Premium vault card displaying the main balance
class VaultCard extends StatelessWidget {
  final double balance;
  final String currency;

  const VaultCard({super.key, required this.balance, this.currency = 'LYD'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.incomeColor.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vault icon and label
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.incomeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppTheme.incomeColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Main Vault',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Animated balance
          AnimatedBalanceDisplay(balance: balance, currency: currency),
          const SizedBox(height: 8),
          // Subtitle
          Text(
            'Total Available Balance',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary.withValues(alpha: 0.8),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

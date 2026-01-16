import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Widget displaying debt statistics summary
class DebtStatisticsCard extends StatelessWidget {
  final double debtAssets;
  final double debtLiabilities;
  final int activeDebtsCount;
  final int upcomingDueDates;

  const DebtStatisticsCard({
    super.key,
    required this.debtAssets,
    required this.debtLiabilities,
    required this.activeDebtsCount,
    required this.upcomingDueDates,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final netPosition = debtAssets - debtLiabilities;
    final isPositive = netPosition >= 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cardColor,
            AppTheme.cardColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.incomeColor.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.incomeColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.incomeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppTheme.incomeColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.debtSummary,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(Icons.info_outline, color: AppTheme.textSecondary, size: 20),
            ],
          ),

          const SizedBox(height: 24),

          // Debt Assets
          _buildStatRow(
            context,
            icon: Icons.arrow_upward_rounded,
            iconColor: AppTheme.incomeColor,
            label: l10n.debtAssets,
            amount: debtAssets,
          ),

          const SizedBox(height: 16),

          // Debt Liabilities
          _buildStatRow(
            context,
            icon: Icons.arrow_downward_rounded,
            iconColor: AppTheme.debtColor,
            label: l10n.debtLiabilities,
            amount: debtLiabilities,
          ),

          const SizedBox(height: 16),

          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.textSecondary.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Net Position
          _buildStatRow(
            context,
            icon: Icons.balance,
            iconColor: isPositive ? AppTheme.incomeColor : AppTheme.debtColor,
            label: l10n.netPosition,
            amount: netPosition.abs(),
            isNet: true,
            isPositive: isPositive,
          ),

          const SizedBox(height: 20),

          // Active Debts and Due Dates
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  context,
                  icon: Icons.receipt_long_rounded,
                  label: l10n.activeDebts,
                  value: activeDebtsCount.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoChip(
                  context,
                  icon: Icons.schedule_rounded,
                  label: l10n.dueThisWeek,
                  value: upcomingDueDates.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required double amount,
    bool isNet = false,
    bool isPositive = true,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          '${isNet && isPositive
              ? '+'
              : isNet && !isPositive
              ? '-'
              : ''}د.ل ${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isNet
                ? (isPositive ? AppTheme.incomeColor : AppTheme.debtColor)
                : AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.textSecondary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

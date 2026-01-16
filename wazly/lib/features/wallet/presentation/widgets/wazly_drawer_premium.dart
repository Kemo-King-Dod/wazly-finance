import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Premium glassmorphism navigation drawer for Wazly
class WazlyDrawerPremium extends StatelessWidget {
  final String currentRoute;
  final double totalBalance;
  final double debtAssets;
  final double debtLiabilities;

  const WazlyDrawerPremium({
    super.key,
    required this.currentRoute,
    required this.totalBalance,
    required this.debtAssets,
    required this.debtLiabilities,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final netWorth = totalBalance + debtAssets - debtLiabilities;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor.withValues(alpha: 0.8),
            border: Border(
              right: BorderSide(
                color: AppTheme.incomeColor.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // User Profile Header
              _buildHeader(context, l10n, netWorth),

              // Navigation Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildNavItem(
                      context,
                      icon: Icons.dashboard_rounded,
                      label: l10n.dashboard,
                      route: '/',
                      isSelected: currentRoute == '/',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.history_rounded,
                      label: l10n.history,
                      route: '/history',
                      isSelected: currentRoute == '/history',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.people_alt_rounded,
                      label: l10n.accounts,
                      route: '/accounts',
                      isSelected: currentRoute == '/accounts',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.pie_chart_rounded,
                      label: l10n.analytics,
                      route: '/analytics',
                      isSelected: currentRoute == '/analytics',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.settings_rounded,
                      label: l10n.settings,
                      route: '/settings',
                      isSelected: currentRoute == '/settings',
                    ),
                  ],
                ),
              ),

              // Debt Summary Footer
              _buildDebtSummary(l10n),

              // Version Info
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Wazly v1.0.0',
                  style: TextStyle(
                    color: AppTheme.textSecondary.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    double netWorth,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.incomeColor,
                      AppTheme.incomeColor.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'User Name',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            l10n.totalNetWorth,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'د.ل ${netWorth.toStringAsFixed(2)}',
            style: TextStyle(
              color: AppTheme.incomeColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.pop(context); // Close drawer
          if (!isSelected) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isSelected
                ? AppTheme.incomeColor.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppTheme.incomeColor
                    : AppTheme.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              if (isSelected) ...[
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.incomeColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDebtSummary(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildDebtItem(l10n.debtAssets, debtAssets, AppTheme.incomeColor),
          const SizedBox(height: 16),
          _buildDebtItem(
            l10n.debtLiabilities,
            debtLiabilities,
            AppTheme.debtColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDebtItem(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        Text(
          'د.ل ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

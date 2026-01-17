import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../transactions/presentation/blocs/transaction_bloc.dart';
import '../../../transactions/presentation/blocs/transaction_state.dart';
import '../../../accounts/presentation/blocs/account_bloc.dart';
import '../../../accounts/presentation/blocs/account_state.dart';
import '../../../analytics/presentation/blocs/analytics_bloc.dart';
import '../../../analytics/presentation/blocs/analytics_state.dart';

/// Premium glassmorphism navigation drawer for Wazly
class WazlyDrawerPremium extends StatefulWidget {
  final String currentRoute;

  const WazlyDrawerPremium({super.key, required this.currentRoute});

  @override
  State<WazlyDrawerPremium> createState() => _WazlyDrawerPremiumState();
}

class _WazlyDrawerPremiumState extends State<WazlyDrawerPremium> {
  // Cache the last known good values to prevent flickering to zero during loading
  static double _lastTotalBalance = 0;
  static double _lastDebtAssets = 0;
  static double _lastDebtLiabilities = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
          child: BlocBuilder<AccountBloc, AccountState>(
            builder: (context, accountState) {
              if (accountState is AccountAccountsLoaded) {
                _lastTotalBalance = accountState.totalBalance;
                _lastDebtAssets = accountState.debtAssets;
                _lastDebtLiabilities = accountState.debtLiabilities;
              }

              return BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, transactionState) {
                  return BlocBuilder<AnalyticsBloc, AnalyticsState>(
                    builder: (context, analyticsState) {
                      // Update cache from analytics state too
                      if (analyticsState is AnalyticsLoaded) {
                        _lastTotalBalance = analyticsState.totalBalance;
                        _lastDebtAssets = analyticsState.debtAssets;
                        _lastDebtLiabilities = analyticsState.debtLiabilities;
                      }

                      // Update cache from transaction state too if it has totals
                      if (transactionState is TransactionLoaded) {
                        _lastTotalBalance = transactionState.totalBalance;
                        _lastDebtAssets = transactionState.debtAssets;
                        _lastDebtLiabilities = transactionState.debtLiabilities;
                      }

                      final netWorth =
                          _lastTotalBalance +
                          _lastDebtAssets -
                          _lastDebtLiabilities;

                      return Column(
                        children: [
                          // User Profile Header & Net Worth Section
                          _buildHeader(context, l10n, netWorth),

                          // Navigation Items
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              children: [
                                _buildNavItem(
                                  context,
                                  icon: Icons.dashboard_rounded,
                                  label: l10n.dashboard,
                                  route: '/',
                                  isSelected: widget.currentRoute == '/',
                                ),
                                _buildNavItem(
                                  context,
                                  icon: Icons.history_rounded,
                                  label: l10n.history,
                                  route: '/history',
                                  isSelected: widget.currentRoute == '/history',
                                ),
                                _buildNavItem(
                                  context,
                                  icon: Icons.people_alt_rounded,
                                  label: l10n.accounts,
                                  route: '/accounts',
                                  isSelected:
                                      widget.currentRoute == '/accounts',
                                ),
                                _buildNavItem(
                                  context,
                                  icon: Icons.pie_chart_rounded,
                                  label: l10n.analytics,
                                  route: '/analytics',
                                  isSelected:
                                      widget.currentRoute == '/analytics',
                                ),
                                _buildNavItem(
                                  context,
                                  icon: Icons.settings_rounded,
                                  label: l10n.settings,
                                  route: '/settings',
                                  isSelected:
                                      widget.currentRoute == '/settings',
                                ),
                              ],
                            ),
                          ),

                          // Debt Summary Footer
                          _buildBreakdownSection(l10n),

                          // Version Info
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Wazly v1.0.1',
                              style: TextStyle(
                                color: AppTheme.textSecondary.withValues(
                                  alpha: 0.5,
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
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
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              'د.ل ${netWorth.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppTheme.incomeColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
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

  Widget _buildBreakdownSection(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.incomeColor.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.totalNetWorth.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          _buildBreakdownItem(
            l10n.vaultBalance,
            _lastTotalBalance,
            AppTheme.textPrimary,
          ),
          const SizedBox(height: 12),
          _buildBreakdownItem(
            l10n.debtAssets,
            _lastDebtAssets,
            AppTheme.incomeColor,
            isAddition: true,
          ),
          const SizedBox(height: 12),
          _buildBreakdownItem(
            l10n.debtLiabilities,
            _lastDebtLiabilities,
            AppTheme.debtColor,
            isSubtraction: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(
    String label,
    double amount,
    Color color, {
    bool isAddition = false,
    bool isSubtraction = false,
  }) {
    String prefix = '';
    if (isAddition) prefix = '+ ';
    if (isSubtraction) prefix = '- ';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        Text(
          '$prefixد.ل ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color.withValues(alpha: 0.9),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

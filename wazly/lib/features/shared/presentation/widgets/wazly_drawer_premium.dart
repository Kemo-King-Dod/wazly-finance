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
import '../../../profile/presentation/blocs/profile_bloc.dart';
import '../../../profile/presentation/blocs/profile_state.dart';
import 'dart:io';

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
                                  icon: Icons.account_balance_wallet_rounded,
                                  label: l10n.accounts,
                                  route: '/accounts',
                                  isSelected:
                                      widget.currentRoute == '/accounts',
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Divider(
                                    color: AppTheme.textSecondary.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
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

                          // Google Sign-in Button at Bottom
                          Container(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.incomeColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        AppTheme.incomeColor.withValues(
                                          alpha: 0.05,
                                        ),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppTheme.incomeColor.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        // TODO: Implement Google Sign-in
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(l10n.comingSoon),
                                            backgroundColor:
                                                AppTheme.incomeColor,
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.g_mobiledata_rounded,
                                              size: 32,
                                              color: AppTheme.incomeColor,
                                            ),
                                            const SizedBox(width: 12),
                                            Flexible(
                                              child: Text(
                                                l10n.signInWithGoogle,
                                                style: const TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Wazly v1.0.1',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary.withValues(
                                      alpha: 0.5,
                                    ),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
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
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        String userName = 'User';
        String? profilePicture;

        if (profileState is ProfileLoaded) {
          userName = profileState.profile.name;
          profilePicture = profileState.profile.profilePicture;
        }

        return GestureDetector(
          onTap: () {
            Navigator.pop(context); // Close drawer
            Navigator.pushNamed(context, '/profile');
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Profile Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient:
                            profilePicture == null ||
                                !File(profilePicture).existsSync()
                            ? LinearGradient(
                                colors: [
                                  AppTheme.incomeColor,
                                  AppTheme.incomeColor.withValues(alpha: 0.6),
                                ],
                              )
                            : null,
                        image:
                            profilePicture != null &&
                                File(profilePicture).existsSync()
                            ? DecorationImage(
                                image: FileImage(File(profilePicture)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child:
                          profilePicture == null ||
                              !File(profilePicture).existsSync()
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.welcomeBack,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            userName,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Edit icon hint
                    Icon(
                      Icons.edit_rounded,
                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
          if (!isSelected) {
            Navigator.pop(context); // Close drawer first
            if (route == '/') {
              // For home, use pushNamedAndRemoveUntil to clear stack
              Navigator.pushNamedAndRemoveUntil(
                context,
                route,
                (route) => false,
              );
            } else {
              // For other routes, use pushNamed to allow back navigation
              Navigator.pushNamed(context, route);
            }
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
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? AppTheme.incomeColor
                        : AppTheme.textSecondary,
                    fontSize: 16,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.incomeColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

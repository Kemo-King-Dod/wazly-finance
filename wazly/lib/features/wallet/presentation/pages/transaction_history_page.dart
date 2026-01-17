import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../blocs/wallet_bloc.dart';
import '../blocs/wallet_event.dart';
import '../blocs/wallet_state.dart';
import '../widgets/wazly_drawer_premium.dart';
import '../widgets/wazly_navigation_rail.dart';
import '../blocs/settings/settings_bloc.dart';
import '../blocs/settings/settings_state.dart';

/// Transaction History page showing all transactions
class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  @override
  void initState() {
    super.initState();
    // Fetch wallet data when page loads
    context.read<WalletBloc>().add(const FetchWalletData());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(l10n.history),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          double totalBalance = 0;
          double debtAssets = 0;
          double debtLiabilities = 0;

          if (state is WalletLoaded) {
            totalBalance = state.totalBalance;
            debtAssets = state.debtAssets;
            debtLiabilities = state.debtLiabilities;
          }

          return WazlyDrawerPremium(
            currentRoute: '/history',
            totalBalance: totalBalance,
            debtAssets: debtAssets,
            debtLiabilities: debtLiabilities,
          );
        },
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          return Row(
            children: [
              if (settingsState.isNavigationRailEnabled)
                WazlyNavigationRail(
                  currentRoute: '/history',
                  onNavigate: (route) {
                    if (route != '/history') {
                      Navigator.pushReplacementNamed(context, route);
                    }
                  },
                ),
              Expanded(
                child: BlocBuilder<WalletBloc, WalletState>(
                  builder: (context, state) {
                    if (state is WalletError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppTheme.debtColor,
                            ),
                            const SizedBox(height: 16),
                            Text(state.message),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.read<WalletBloc>().add(
                                const FetchWalletData(),
                              ),
                              child: Text(l10n.retry),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is WalletLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.incomeColor,
                        ),
                      );
                    }

                    if (state is WalletLoaded) {
                      if (state.allTransactions.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_rounded,
                                size: 80,
                                color: AppTheme.textSecondary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No Transactions Yet',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start adding transactions to see them here',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: state.allTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = state.allTransactions[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color:
                                        (transaction.isIncome
                                                ? AppTheme.incomeColor
                                                : AppTheme.debtColor)
                                            .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    transaction.isIncome
                                        ? Icons.arrow_downward_rounded
                                        : Icons.arrow_upward_rounded,
                                    color: transaction.isIncome
                                        ? AppTheme.incomeColor
                                        : AppTheme.debtColor,
                                  ),
                                ),
                                title: Text(
                                  transaction.category,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  transaction.description,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Text(
                                  '${transaction.isIncome ? '+' : '-'}د.ل ${transaction.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: transaction.isIncome
                                        ? AppTheme.incomeColor
                                        : AppTheme.debtColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

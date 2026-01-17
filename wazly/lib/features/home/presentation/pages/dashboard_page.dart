import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../transactions/presentation/blocs/transaction_bloc.dart';
import '../../../transactions/presentation/blocs/transaction_event.dart';
import '../../../transactions/presentation/blocs/transaction_state.dart';

import '../widgets/vault_card.dart';
import '../../../transactions/presentation/widgets/transaction_list_item.dart';
import '../widgets/dashboard_skeleton.dart';
import '../../../shared/presentation/widgets/wazly_drawer_premium.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../transactions/presentation/pages/add_transaction_page.dart';
import '../../../debts/presentation/pages/add_debt_page.dart';
import '../../../shared/presentation/widgets/wazly_navigation_rail.dart';
import '../../../settings/presentation/blocs/settings_bloc.dart';
import '../../../settings/presentation/blocs/settings_state.dart';

/// Main dashboard page displaying wallet balance and recent transactions
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Fetch transaction data when page loads
    context.read<TransactionBloc>().add(const FetchTransactionData());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(l10n.appTitle),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      drawer: const WazlyDrawerPremium(currentRoute: '/'),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          return Row(
            children: [
              if (settingsState.isNavigationRailEnabled)
                WazlyNavigationRail(
                  currentRoute: '/',
                  onNavigate: (route) {
                    if (route != '/') {
                      Navigator.pushReplacementNamed(context, route);
                    }
                  },
                ),
              Expanded(
                child: BlocBuilder<TransactionBloc, TransactionState>(
                  builder: (context, state) {
                    if (state is TransactionLoading) {
                      return const DashboardSkeleton();
                    }

                    if (state is TransactionError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppTheme.debtColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppTheme.textSecondary),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.read<TransactionBloc>().add(
                                  const FetchTransactionData(),
                                );
                              },
                              icon: const Icon(Icons.refresh),
                              label: Text(l10n.retry),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is TransactionLoaded) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<TransactionBloc>().add(
                            const RefreshTransactionData(),
                          );
                          // Wait a bit for the refresh to complete
                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );
                        },
                        color: AppTheme.incomeColor,
                        backgroundColor: AppTheme.cardColor,
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            // Top padding
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 24),
                            ),
                            // Vault Card
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: VaultCard(balance: state.totalBalance),
                              ),
                            ),
                            // Recent Transactions Header
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  32,
                                  24,
                                  16,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n.recentTransactions,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: AppTheme.textPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    if (state.allTransactions.length > 5)
                                      TextButton(
                                        onPressed: () {
                                          // TODO: Navigate to all transactions
                                        },
                                        child: Text(
                                          l10n.viewAll,
                                          style: TextStyle(
                                            color: AppTheme.incomeColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            // Transactions List or Empty State
                            state.recentTransactions.isEmpty
                                ? SliverFillRemaining(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.receipt_long_outlined,
                                            size: 80,
                                            color: AppTheme.textSecondary
                                                .withAlpha((0.3 * 255).toInt()),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No Transactions Yet',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  color: AppTheme.textSecondary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Tap the + button to add your first transaction',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: AppTheme.textSecondary
                                                      .withAlpha(
                                                        (0.1 * 255).toInt(),
                                                      ),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : SliverPadding(
                                    padding: const EdgeInsets.fromLTRB(
                                      24,
                                      0,
                                      24,
                                      100,
                                    ),
                                    sliver: SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          final transaction =
                                              state.recentTransactions[index];
                                          return TransactionListItem(
                                            transaction: transaction,
                                            onTap: () {
                                              // TODO: Show transaction details
                                            },
                                          );
                                        },
                                        childCount:
                                            state.recentTransactions.length,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      );
                    }

                    // For any other state, show loading
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.incomeColor,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Add Debt Button
              FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddDebtPage()),
                  );
                },
                heroTag: 'addDebt',
                backgroundColor: AppTheme.debtColor,
                icon: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  l10n.addDebt,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Add Transaction Button
              FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddTransactionPage(),
                    ),
                  );
                },
                heroTag: 'addTransaction',
                backgroundColor: AppTheme.incomeColor,
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  l10n.addTransaction,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

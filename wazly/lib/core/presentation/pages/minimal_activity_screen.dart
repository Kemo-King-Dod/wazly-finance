import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wazly/core/domain/entities/transaction.dart';
import 'package:wazly/core/domain/entities/transaction_enums.dart';
import 'package:wazly/core/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:wazly/core/presentation/bloc/people/people_bloc.dart';
import 'package:wazly/core/presentation/bloc/transaction_action/transaction_action_bloc.dart';
import 'package:wazly/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:wazly/core/presentation/pages/minimal_transaction_details_screen.dart';
import 'package:wazly/l10n/app_localizations.dart';
import 'package:wazly/core/presentation/widgets/empty_state_view.dart';
import 'package:wazly/core/presentation/pages/add_transaction_screen.dart';

enum ActivityFilter { all, debts, payments, treasury }

extension ActivityFilterExt on ActivityFilter {
  String displayName(BuildContext context) {
    switch (this) {
      case ActivityFilter.all:
        return AppLocalizations.of(context)!.filterAll;
      case ActivityFilter.debts:
        return AppLocalizations.of(context)!.debtsText;
      case ActivityFilter.payments:
        return AppLocalizations.of(context)!.paymentsText;
      case ActivityFilter.treasury:
        return AppLocalizations.of(context)!.treasuryText;
    }
  }
}

class MinimalActivityScreen extends StatefulWidget {
  MinimalActivityScreen({super.key});

  @override
  State<MinimalActivityScreen> createState() => _MinimalActivityScreenState();
}

class _MinimalActivityScreenState extends State<MinimalActivityScreen> {
  ActivityFilter _currentFilter = ActivityFilter.all;
  final Set<String> _pendingDeletions = {};
  final TextEditingController _searchController = TextEditingController();

  int _lastTxHash = 0;
  String _lastSearchQuery = '';
  ActivityFilter _lastFilter = ActivityFilter.all;
  Set<String> _lastPendingDeletions = {};
  List<Transaction>? _memoizedTxs;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ═══════════ HEADER ═══════════
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.activityTitle,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          AppLocalizations.of(context)!.transactionsHistory,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // ═══════════ CONTENT (TRANSACTIONS LIST) ═══════════
            Expanded(
              child: Column(
                children: [
                  // Search
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _searchController,
                      builder: (context, value, child) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.searchTransactions,
                              hintStyle: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(FluentIcons.search_24_regular,
                                  color: AppTheme.textSecondary, size: 22),
                              suffixIcon: value.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(FluentIcons.dismiss_24_regular,
                                          color: AppTheme.textSecondary, size: 20),
                                      onPressed: () => _searchController.clear(),
                                    )
                                  : null,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 12),

                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: ActivityFilter.values.map((filter) {
                        final isSelected = _currentFilter == filter;
                        return Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _currentFilter = filter),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : AppTheme.surfaceCard,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : AppTheme.borderLight,
                                ),
                              ),
                              child: Text(
                                filter.displayName(context),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 12),

                  // List
                  Expanded(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _searchController,
                      builder: (context, searchValue, child) {
                        final searchQuery = searchValue.text.toLowerCase();
                        return MultiBlocBuilder(
                          builder: (context, dashboardState, peopleState) {
                            if (dashboardState is DashboardLoading ||
                                peopleState is PeopleLoading) {
                              return Center(
                                child: CircularProgressIndicator(
                                    color: Theme.of(context).primaryColor),
                              );
                            }
                            if (dashboardState is DashboardLoaded &&
                                peopleState is PeopleLoaded) {
                              final rawTxs =
                                  dashboardState.summary.recentTransactions;
                              final currentHash =
                                  rawTxs.hashCode ^ peopleState.fullList.hashCode;

                              if (_memoizedTxs != null &&
                                  _lastTxHash == currentHash &&
                                  _lastSearchQuery == searchQuery &&
                                  _lastFilter == _currentFilter &&
                                  _lastPendingDeletions.length ==
                                      _pendingDeletions.length) {
                                return _buildTxList(_memoizedTxs!, peopleState);
                              }

                              List<Transaction> txs = List.of(rawTxs);
                              txs = txs
                                  .where((t) => !_pendingDeletions.contains(t.id))
                                  .toList();

                              if (searchQuery.isNotEmpty) {
                                txs = txs.where((t) {
                                  if (t.description
                                      .toLowerCase()
                                      .contains(searchQuery)) return true;
                                  final amountStr =
                                      (t.amountInCents / 100).toStringAsFixed(2);
                                  if (amountStr.contains(searchQuery)) return true;
                                  if (t.personId != null) {
                                    final personIt = peopleState.fullList
                                        .where((p) => p.person.id == t.personId);
                                    if (personIt.isNotEmpty &&
                                        personIt.first.person.name
                                            .toLowerCase()
                                            .contains(searchQuery)) return true;
                                  }
                                  return false;
                                }).toList();
                              }

                              if (_currentFilter == ActivityFilter.debts) {
                                txs = txs
                                    .where((t) => t.type == TransactionType.debt)
                                    .toList();
                              } else if (_currentFilter == ActivityFilter.payments) {
                                txs = txs
                                    .where((t) => t.type == TransactionType.payment)
                                    .toList();
                              } else if (_currentFilter == ActivityFilter.treasury) {
                                txs = txs
                                    .where((t) =>
                                        t.type == TransactionType.treasuryIn ||
                                        t.type == TransactionType.treasuryOut)
                                    .toList();
                              }

                              _lastTxHash = currentHash;
                              _lastSearchQuery = searchQuery;
                              _lastFilter = _currentFilter;
                              _lastPendingDeletions = Set.from(_pendingDeletions);
                              _memoizedTxs = txs;

                              return _buildTxList(txs, peopleState);
                            }
                            return SizedBox();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTxList(List<Transaction> txs, PeopleLoaded peopleState) {
    if (txs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: EmptyStateView(
          icon: Icon(FluentIcons.receipt_24_regular),
          title: AppLocalizations.of(context)!.emptyActivityTitle,
          subtitle: AppLocalizations.of(context)!.emptyActivitySubtitle,
          actionLabel: AppLocalizations.of(context)!.addTransaction,
          onAction: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransactionScreen()));
          },
        ),
      );
    }

    return ListView.builder(
      key: PageStorageKey('activity_list'),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: txs.length,
      itemBuilder: (context, index) {
        final t = txs[index];
        String title =
            t.description.isNotEmpty ? t.description : 'Transaction';
        String? actualPersonName;
        if (t.type == TransactionType.treasuryIn) {
          title = AppLocalizations.of(context)!.addedFunds;
        } else if (t.type == TransactionType.treasuryOut) {
          title = AppLocalizations.of(context)!.removedFunds;
        } else if (t.personId != null) {
          final personIt = peopleState.fullList
              .where((p) => p.person.id == t.personId);
          if (personIt.isNotEmpty) {
            title = personIt.first.person.name;
            actualPersonName = title;
          }
        }

        IconData iconData;
        Color typeColor;
        int sign = 0;

        switch (t.type) {
          case TransactionType.treasuryIn:
            iconData = FluentIcons.arrow_down_24_regular;
            sign = 1;
            break;
          case TransactionType.treasuryOut:
            iconData = FluentIcons.arrow_up_24_regular;
            sign = -1;
            break;
          case TransactionType.debt:
            iconData = FluentIcons.wallet_24_regular;
            sign = t.direction == DebtDirection.theyOweMe ? 1 : -1;
            break;
          case TransactionType.payment:
            iconData = FluentIcons.payment_24_regular;
            sign = t.direction == DebtDirection.theyOweMe ? 1 : -1;
            break;
        }

        typeColor = sign > 0
            ? AppTheme.incomeColor
            : (sign < 0 ? AppTheme.debtColor : AppTheme.textSecondary);
        final prefix = sign > 0 ? '+' : (sign < 0 ? '-' : '');

        return GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MinimalTransactionDetailsScreen(
                  transaction: t,
                  personName: actualPersonName,
                ),
              ),
            );
            if (result == 'delete' && mounted) {
              setState(() => _pendingDeletions.add(t.id));
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              final snackbar =
                  ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.transactionDeleted),
                  duration: Duration(seconds: 4),
                  action: SnackBarAction(
                    label: AppLocalizations.of(context)!.undo,
                    onPressed: () {
                      if (mounted) {
                        setState(
                            () => _pendingDeletions.remove(t.id));
                      }
                    },
                  ),
                ),
              );
              final reason = await snackbar.closed;
              if (reason != SnackBarClosedReason.action &&
                  _pendingDeletions.contains(t.id)) {
                if (mounted) {
                  context.read<TransactionActionBloc>().add(
                    DeleteTransactionEvent(t.id),
                  );
                  setState(() => _pendingDeletions.remove(t.id));
                }
              }
            }
          },
          child: Container(
            key: ValueKey(t.id),
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              border: Border.all(color: AppTheme.borderLight, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(iconData, color: typeColor, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      SizedBox(height: 3),
                      Text(
                          DateFormat('MMM dd • h:mm a').format(t.date),
                          style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Text(
                  '$prefix${(t.amountInCents / 100).toStringAsFixed(2)} LYD',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: typeColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MultiBlocBuilder extends StatelessWidget {
  final Widget Function(BuildContext, DashboardState, PeopleState) builder;

  MultiBlocBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, dashboardState) {
        return BlocBuilder<PeopleBloc, PeopleState>(
          builder: (context, peopleState) {
            return builder(context, dashboardState, peopleState);
          },
        );
      },
    );
  }
}

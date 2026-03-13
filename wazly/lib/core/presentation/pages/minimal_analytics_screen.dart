import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wazly/core/domain/entities/transaction_enums.dart';
import 'package:wazly/core/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:wazly/core/presentation/bloc/people/people_bloc.dart';
import 'package:wazly/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:wazly/core/presentation/widgets/empty_state_view.dart';
import 'package:wazly/l10n/app_localizations.dart';
import 'package:wazly/core/presentation/pages/add_transaction_screen.dart';

class MinimalAnalyticsScreen extends StatelessWidget {
  MinimalAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ═══════════ HEADER ═══════════
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.analytics,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          AppLocalizations.of(context)!.insightsAndReports,
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

            // ═══════════ CONTENT ═══════════
            Expanded(
              child: MultiBlocBuilder(
                builder: (context, dashboardState, peopleState) {
                  if (dashboardState is DashboardLoading) {
                    return Center(
                      child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
                    );
                  }

                  if (dashboardState is DashboardLoaded && peopleState is PeopleLoaded) {
                    final txs = dashboardState.summary.recentTransactions;
                    final now = DateTime.now();
                    final thisMonth = DateTime(now.year, now.month, 1);

                    // ── Monthly stats ──
                    int incomeThisMonth = 0;
                    int expenseThisMonth = 0;
                    final Map<String, int> categorySpending = {};
                    final Map<String, int> personActivity = {};

                    // ── Last 7 days trend ──
                    final List<int> dailyIn = List.filled(7, 0);
                    final List<int> dailyOut = List.filled(7, 0);
                    final today = DateTime(now.year, now.month, now.day);

                    for (final t in txs) {
                      if (t.date.isAfter(thisMonth)) {
                        if (t.type == TransactionType.treasuryIn) {
                          incomeThisMonth += t.amountInCents;
                        } else if (t.type == TransactionType.treasuryOut) {
                          expenseThisMonth += t.amountInCents;
                        }
                      }

                      if (t.description.isNotEmpty) {
                        final cat = t.description.contains(' - ')
                            ? t.description.split(' - ').first
                            : t.description;
                        if (t.type == TransactionType.treasuryOut) {
                          categorySpending[cat] = (categorySpending[cat] ?? 0) + t.amountInCents;
                        }
                      }

                      if (t.personId != null) {
                        final personIt = peopleState.fullList.where((p) => p.person.id == t.personId);
                        if (personIt.isNotEmpty) {
                          final name = personIt.first.person.name;
                          personActivity[name] = (personActivity[name] ?? 0) + 1;
                        }
                      }

                      final txDay = DateTime(t.date.year, t.date.month, t.date.day);
                      final dayDiff = today.difference(txDay).inDays;
                      if (dayDiff >= 0 && dayDiff < 7) {
                        final idx = 6 - dayDiff; // 0 = 6 days ago, 6 = today
                        if (t.type == TransactionType.treasuryIn) {
                          dailyIn[idx] += t.amountInCents;
                        } else if (t.type == TransactionType.treasuryOut) {
                          dailyOut[idx] += t.amountInCents;
                        }
                      }
                    }

                    final netThisMonth = incomeThisMonth - expenseThisMonth;

                    String? topCategory;
                    int topCategoryAmount = 0;
                    categorySpending.forEach((key, value) {
                      if (value > topCategoryAmount) {
                        topCategory = key;
                        topCategoryAmount = value;
                      }
                    });

                    String? mostActivePerson;
                    int mostActiveCount = 0;
                    personActivity.forEach((key, value) {
                      if (value > mostActiveCount) {
                        mostActivePerson = key;
                        mostActiveCount = value;
                      }
                    });

                    final sortedExpenseCategories = categorySpending.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));

                    int maxDaily = 1;
                    for (int i = 0; i < 7; i++) {
                      if (dailyIn[i] > maxDaily) maxDaily = dailyIn[i];
                      if (dailyOut[i] > maxDaily) maxDaily = dailyOut[i];
                    }

                    return ListView(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 100),
                      children: [
                        // ── Monthly Summary ──
                        _buildSectionLabel(AppLocalizations.of(context)!.thisMonth),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _AnalyticsMiniCard(
                                label: AppLocalizations.of(context)!.income,
                                value: '${(incomeThisMonth / 100).toStringAsFixed(0)} LYD',
                                color: AppTheme.incomeColor,
                                icon: FluentIcons.arrow_down_24_regular,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: _AnalyticsMiniCard(
                                label: AppLocalizations.of(context)!.expense,
                                value: '${(expenseThisMonth / 100).toStringAsFixed(0)} LYD',
                                color: AppTheme.debtColor,
                                icon: FluentIcons.arrow_up_24_regular,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: _AnalyticsMiniCard(
                                label: AppLocalizations.of(context)!.netText,
                                value: '${(netThisMonth / 100).toStringAsFixed(0)} LYD',
                                color: netThisMonth >= 0 ? AppTheme.incomeColor : AppTheme.debtColor,
                                icon: FluentIcons.arrow_sort_24_regular,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // ── Income vs Expense Card ──
                        if (incomeThisMonth > 0 || expenseThisMonth > 0) ...[
                          _buildSectionLabel(AppLocalizations.of(context)!.incomeVsExpense),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceCard,
                              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                              border: Border.all(color: AppTheme.borderLight, width: 1),
                            ),
                            child: Column(
                              children: [
                                _buildComparisonBar(
                                  AppLocalizations.of(context)!.income,
                                  incomeThisMonth,
                                  AppTheme.incomeColor,
                                  incomeThisMonth + expenseThisMonth,
                                ),
                                SizedBox(height: 12),
                                _buildComparisonBar(
                                  AppLocalizations.of(context)!.expense,
                                  expenseThisMonth,
                                  AppTheme.debtColor,
                                  incomeThisMonth + expenseThisMonth,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                        ],

                        // ── Last 7 Days Trend ──
                        _buildSectionLabel(AppLocalizations.of(context)!.last7Days),
                        SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                            border: Border.all(color: AppTheme.borderLight, width: 1),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 120,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: List.generate(7, (i) {
                                    final inH = dailyIn[i] / maxDaily;
                                    final outH = dailyOut[i] / maxDaily;
                                    final dayDate = today.subtract(Duration(days: 6 - i));
                                    final label = DateFormat('E').format(dayDate)[0];
                                    final isToday = i == 6;

                                    return Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Flexible(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: (inH * 90).clamp(2.0, 90.0),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.incomeColor.withValues(alpha: isToday ? 1.0 : 0.5),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                ),
                                                SizedBox(width: 2),
                                                Container(
                                                  width: 8,
                                                  height: (outH * 90).clamp(2.0, 90.0),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.debtColor.withValues(alpha: isToday ? 1.0 : 0.5),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            label,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                                              color: isToday ? Theme.of(context).primaryColor : AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLegendDot(AppTheme.incomeColor, AppLocalizations.of(context)!.income),
                                  SizedBox(width: 16),
                                  _buildLegendDot(AppTheme.debtColor, AppLocalizations.of(context)!.expense),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // ── Insight Cards ──
                        if (topCategory != null || mostActivePerson != null) ...[
                          _buildSectionLabel(AppLocalizations.of(context)!.insights),
                          SizedBox(height: 10),
                          if (topCategory != null) ...[
                            _buildInsightCard(
                              title: AppLocalizations.of(context)!.topSpendingCategory,
                              subtitle: topCategory!,
                              value: '${(topCategoryAmount / 100).toStringAsFixed(0)} LYD',
                              icon: FluentIcons.arrow_trending_24_regular,
                              iconColor: AppTheme.warningColor,
                            ),
                            SizedBox(height: 10),
                          ],
                          if (mostActivePerson != null) ...[
                            _buildInsightCard(
                              title: AppLocalizations.of(context)!.mostActivePerson,
                              subtitle: mostActivePerson!,
                              value: '$mostActiveCount',
                              icon: FluentIcons.person_24_regular,
                              iconColor: Theme.of(context).primaryColor,
                            ),
                            SizedBox(height: 20),
                          ],
                        ],

                        // ── Expense by Category ──
                        if (sortedExpenseCategories.isNotEmpty) ...[
                          _buildSectionLabel(AppLocalizations.of(context)!.expensesByCategory),
                          SizedBox(height: 10),
                          ...sortedExpenseCategories.map((entry) {
                            final percentage = expenseThisMonth > 0 ? entry.value / expenseThisMonth : 0.0;
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceCard,
                                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                                  border: Border.all(color: AppTheme.borderLight, width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            entry.key,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${(entry.value / 100).toStringAsFixed(0)} LYD',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.debtColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: percentage,
                                        minHeight: 6,
                                        backgroundColor: AppTheme.debtColor.withValues(alpha: 0.08),
                                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.debtColor),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${(percentage * 100).toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],

                        if (sortedExpenseCategories.isEmpty &&
                            topCategory == null &&
                            incomeThisMonth == 0 &&
                            expenseThisMonth == 0)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 60),
                            child: EmptyStateView(
                              icon: Icon(FluentIcons.data_trending_24_regular),
                              title: AppLocalizations.of(context)!.emptyAnalyticsTitle,
                              subtitle: AppLocalizations.of(context)!.emptyAnalyticsSubtitle,
                              actionLabel: AppLocalizations.of(context)!.addTransaction,
                              onAction: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransactionScreen()));
                              },
                            ),
                          ),
                      ],
                    );
                  }

                  return SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ───

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildComparisonBar(String label, int amount, Color color, int total) {
    final fraction = total > 0 ? amount / total : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: fraction,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
        Text(
          '${(amount / 100).toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
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
              color: iconColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    )),
                SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    )),
              ],
            ),
          ),
          Text(value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: iconColor,
              )),
        ],
      ),
    );
  }
}

// ─── Analytics Mini Card ───
class _AnalyticsMiniCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  _AnalyticsMiniCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary)),
          SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: color)),
          ),
        ],
      ),
    );
  }
}

// ─── MultiBlocBuilder ───
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

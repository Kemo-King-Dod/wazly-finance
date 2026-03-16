import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wazly/core/domain/entities/transaction_enums.dart';
import 'package:wazly/core/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:wazly/core/presentation/bloc/people/people_bloc.dart';
import 'package:wazly/core/presentation/bloc/settings/settings_cubit.dart';
import 'package:wazly/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:wazly/core/presentation/widgets/empty_state_view.dart';
import 'package:wazly/l10n/app_localizations.dart';
import 'package:wazly/core/presentation/pages/add_transaction_screen.dart';
import 'package:wazly/core/utils/app_formatters.dart';

enum _DateRange { today, thisWeek, thisMonth, thisYear, custom }

class MinimalAnalyticsScreen extends StatefulWidget {
  const MinimalAnalyticsScreen({super.key});

  @override
  State<MinimalAnalyticsScreen> createState() => _MinimalAnalyticsScreenState();
}

class _MinimalAnalyticsScreenState extends State<MinimalAnalyticsScreen> {
  _DateRange _range = _DateRange.thisMonth;
  DateTimeRange? _customRange;

  (DateTime start, DateTime end) _computeRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_range) {
      case _DateRange.today:
        return (today, now);
      case _DateRange.thisWeek:
        final weekday = today.weekday; // Mon=1
        final startOfWeek = today.subtract(Duration(days: weekday - 1));
        return (startOfWeek, now);
      case _DateRange.thisMonth:
        return (DateTime(now.year, now.month, 1), now);
      case _DateRange.thisYear:
        return (DateTime(now.year, 1, 1), now);
      case _DateRange.custom:
        if (_customRange != null) {
          return (_customRange!.start, _customRange!.end);
        }
        return (DateTime(now.year, now.month, 1), now);
    }
  }

  int _trendDayCount() {
    final (start, end) = _computeRange();
    final diff = end.difference(start).inDays + 1;
    return diff.clamp(1, 365);
  }

  String _rangeLabel(AppLocalizations l) {
    switch (_range) {
      case _DateRange.today:
        return l.todayFilter;
      case _DateRange.thisWeek:
        return l.thisWeekFilter;
      case _DateRange.thisMonth:
        return l.thisMonthFilter;
      case _DateRange.thisYear:
        return l.thisYearFilter;
      case _DateRange.custom:
        if (_customRange != null) {
          final f = DateFormat('MMM dd');
          return l.rangeLabel(
            f.format(_customRange!.start),
            f.format(_customRange!.end),
          );
        }
        return l.customRangeFilter;
    }
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: _customRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
    );
    if (picked != null && mounted) {
      setState(() {
        _customRange = picked;
        _range = _DateRange.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ═══════════ HEADER ═══════════
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.analytics,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l.insightsAndReports,
                          style: const TextStyle(
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

            // ═══════════ FILTER CHIPS ═══════════
            const SizedBox(height: 14),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _FilterChip(
                    label: l.todayFilter,
                    isSelected: _range == _DateRange.today,
                    onTap: () => setState(() => _range = _DateRange.today),
                  ),
                  _FilterChip(
                    label: l.thisWeekFilter,
                    isSelected: _range == _DateRange.thisWeek,
                    onTap: () => setState(() => _range = _DateRange.thisWeek),
                  ),
                  _FilterChip(
                    label: l.thisMonthFilter,
                    isSelected: _range == _DateRange.thisMonth,
                    onTap: () => setState(() => _range = _DateRange.thisMonth),
                  ),
                  _FilterChip(
                    label: l.thisYearFilter,
                    isSelected: _range == _DateRange.thisYear,
                    onTap: () => setState(() => _range = _DateRange.thisYear),
                  ),
                  _FilterChip(
                    label: l.customRangeFilter,
                    isSelected: _range == _DateRange.custom,
                    icon: FluentIcons.calendar_24_regular,
                    onTap: _pickCustomRange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ═══════════ CONTENT ═══════════
            Expanded(
              child: MultiBlocBuilder(
                builder: (context, dashboardState, peopleState) {
                  if (dashboardState is DashboardLoading) {
                    return Center(
                      child: CircularProgressIndicator(color: primary),
                    );
                  }

                  if (dashboardState is DashboardLoaded &&
                      peopleState is PeopleLoaded) {
                    final txs = dashboardState.summary.recentTransactions;
                    final (rangeStart, rangeEnd) = _computeRange();

                    int income = 0;
                    int expense = 0;
                    final Map<String, int> categorySpending = {};
                    final Map<String, int> personActivity = {};

                    // Trend data
                    final dayCount = _trendDayCount();
                    final startDay = DateTime(
                        rangeStart.year, rangeStart.month, rangeStart.day);
                    final List<int> dailyIn = List.filled(dayCount, 0);
                    final List<int> dailyOut = List.filled(dayCount, 0);

                    for (final t in txs) {
                      final txDay =
                          DateTime(t.date.year, t.date.month, t.date.day);

                      if (t.date.isAfter(rangeStart) ||
                          txDay == startDay) {
                        if (txDay.isAfter(rangeEnd)) continue;

                        if (t.type == TransactionType.treasuryIn) {
                          income += t.amountInCents;
                        } else if (t.type == TransactionType.treasuryOut) {
                          expense += t.amountInCents;
                        }

                        if (t.description.isNotEmpty) {
                          final cat = t.description.contains(' - ')
                              ? t.description.split(' - ').first
                              : t.description;
                          if (t.type == TransactionType.treasuryOut) {
                            categorySpending[cat] =
                                (categorySpending[cat] ?? 0) + t.amountInCents;
                          }
                        }

                        if (t.personId != null) {
                          final personIt = peopleState.fullList
                              .where((p) => p.person.id == t.personId);
                          if (personIt.isNotEmpty) {
                            final name = personIt.first.person.name;
                            personActivity[name] =
                                (personActivity[name] ?? 0) + 1;
                          }
                        }

                        // Trend bar index
                        final dayDiff = txDay.difference(startDay).inDays;
                        if (dayDiff >= 0 && dayDiff < dayCount) {
                          if (t.type == TransactionType.treasuryIn) {
                            dailyIn[dayDiff] += t.amountInCents;
                          } else if (t.type == TransactionType.treasuryOut) {
                            dailyOut[dayDiff] += t.amountInCents;
                          }
                        }
                      }
                    }

                    final net = income - expense;

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

                    final sortedExpenseCategories =
                        categorySpending.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value));

                    // Compute max for trend bars
                    int maxDaily = 1;
                    for (int i = 0; i < dayCount; i++) {
                      if (dailyIn[i] > maxDaily) maxDaily = dailyIn[i];
                      if (dailyOut[i] > maxDaily) maxDaily = dailyOut[i];
                    }

                    // Decide how many bars to show (max ~14 for readability)
                    final int step = (dayCount / 14).ceil().clamp(1, 365);
                    final int barCount = (dayCount / step).ceil();

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      children: [
                        // ── Summary ──
                        _buildSectionLabel(_rangeLabel(l)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _AnalyticsMiniCard(
                                label: l.income,
                                value:
                                    '${AppFormatters.formatAmount(income / 100).split('.').first} ${context.watch<SettingsCubit>().state.currencyCode}',
                                color: AppTheme.incomeColor,
                                icon: FluentIcons.arrow_down_24_regular,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _AnalyticsMiniCard(
                                label: l.expense,
                                value:
                                    '${AppFormatters.formatAmount(expense / 100).split('.').first} ${context.watch<SettingsCubit>().state.currencyCode}',
                                color: AppTheme.debtColor,
                                icon: FluentIcons.arrow_up_24_regular,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _AnalyticsMiniCard(
                                label: l.netText,
                                value:
                                    '${AppFormatters.formatAmount(net / 100).split('.').first} ${context.watch<SettingsCubit>().state.currencyCode}',
                                color: net >= 0
                                    ? AppTheme.incomeColor
                                    : AppTheme.debtColor,
                                icon: FluentIcons.arrow_sort_24_regular,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Income vs Expense ──
                        if (income > 0 || expense > 0) ...[
                          _buildSectionLabel(l.incomeVsExpense),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceCard,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.cardRadius),
                              border: Border.all(
                                  color: AppTheme.borderLight, width: 1),
                            ),
                            child: Column(
                              children: [
                                _buildComparisonBar(
                                  l.income,
                                  income,
                                  AppTheme.incomeColor,
                                  income + expense,
                                ),
                                const SizedBox(height: 12),
                                _buildComparisonBar(
                                  l.expense,
                                  expense,
                                  AppTheme.debtColor,
                                  income + expense,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // ── Trend Chart ──
                        _buildSectionLabel(l.trendChart),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius:
                                BorderRadius.circular(AppTheme.cardRadius),
                            border: Border.all(
                                color: AppTheme.borderLight, width: 1),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 120,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: List.generate(barCount, (bi) {
                                    // Aggregate bars when step > 1
                                    int barIn = 0;
                                    int barOut = 0;
                                    for (int s = 0; s < step; s++) {
                                      final idx = bi * step + s;
                                      if (idx < dayCount) {
                                        barIn += dailyIn[idx];
                                        barOut += dailyOut[idx];
                                      }
                                    }
                                    final inH =
                                        maxDaily > 0 ? barIn / maxDaily : 0.0;
                                    final outH =
                                        maxDaily > 0 ? barOut / maxDaily : 0.0;
                                    final dayIdx = bi * step;
                                    final barDate =
                                        startDay.add(Duration(days: dayIdx));

                                    String label;
                                    if (dayCount <= 7) {
                                      label =
                                          AppFormatters.formatDate(barDate, 'E')[0];
                                    } else if (dayCount <= 31) {
                                      label = '${barDate.day}';
                                    } else {
                                      label =
                                          AppFormatters.formatDate(barDate, 'MMM')[0];
                                    }

                                    final isLast = bi == barCount - 1;

                                    return Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Flexible(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  width: barCount > 20
                                                      ? 4
                                                      : 8,
                                                  height: (inH * 90)
                                                      .clamp(2.0, 90.0),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.incomeColor
                                                        .withValues(
                                                            alpha: isLast
                                                                ? 1.0
                                                                : 0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width:
                                                        barCount > 20 ? 1 : 2),
                                                Container(
                                                  width: barCount > 20
                                                      ? 4
                                                      : 8,
                                                  height: (outH * 90)
                                                      .clamp(2.0, 90.0),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.debtColor
                                                        .withValues(
                                                            alpha: isLast
                                                                ? 1.0
                                                                : 0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          if (barCount <= 14)
                                            Text(
                                              label,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: isLast
                                                    ? FontWeight.w800
                                                    : FontWeight.w500,
                                                color: isLast
                                                    ? primary
                                                    : AppTheme.textSecondary,
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLegendDot(
                                      AppTheme.incomeColor, l.income),
                                  const SizedBox(width: 16),
                                  _buildLegendDot(
                                      AppTheme.debtColor, l.expense),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Insight Cards ──
                        if (topCategory != null ||
                            mostActivePerson != null) ...[
                          _buildSectionLabel(l.insights),
                          const SizedBox(height: 10),
                          if (topCategory != null) ...[
                            _buildInsightCard(
                              title: l.topSpendingCategory,
                              subtitle: topCategory!,
                              value:
                                  '${AppFormatters.formatAmount(topCategoryAmount / 100).split('.').first} ${context.watch<SettingsCubit>().state.currencyCode}',
                              icon: FluentIcons.arrow_trending_24_regular,
                              iconColor: AppTheme.warningColor,
                            ),
                            const SizedBox(height: 10),
                          ],
                          if (mostActivePerson != null) ...[
                            _buildInsightCard(
                              title: l.mostActivePerson,
                              subtitle: mostActivePerson!,
                              value: '$mostActiveCount',
                              icon: FluentIcons.person_24_regular,
                              iconColor: primary,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ],

                        // ── Expense by Category ──
                        if (sortedExpenseCategories.isNotEmpty) ...[
                          _buildSectionLabel(l.expensesByCategory),
                          const SizedBox(height: 10),
                          ...sortedExpenseCategories.map((entry) {
                            final percentage = expense > 0
                                ? entry.value / expense
                                : 0.0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceCard,
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.cardRadius),
                                  border: Border.all(
                                      color: AppTheme.borderLight, width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            entry.key,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${AppFormatters.formatAmount(entry.value / 100).split('.').first} ${context.watch<SettingsCubit>().state.currencyCode}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.debtColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: percentage,
                                        minHeight: 6,
                                        backgroundColor: AppTheme.debtColor
                                            .withValues(alpha: 0.08),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                AppTheme.debtColor),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${AppFormatters.formatAmount(percentage * 100).split('.').first}%',
                                      style: const TextStyle(
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
                            income == 0 &&
                            expense == 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 60),
                            child: EmptyStateView(
                              icon: const Icon(
                                  FluentIcons.data_trending_24_regular),
                              title: l.emptyAnalyticsTitle,
                              subtitle: l.emptyAnalyticsSubtitle,
                              actionLabel: l.addTransaction,
                              onAction: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            AddTransactionScreen()));
                              },
                            ),
                          ),
                      ],
                    );
                  }

                  return const SizedBox();
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
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildComparisonBar(
      String label, int amount, Color color, int total) {
    final fraction = total > 0 ? amount / total : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 10),
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
        const SizedBox(width: 10),
        Text(
          AppFormatters.formatAmount(amount / 100).split('.').first,
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
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
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
      padding: const EdgeInsets.all(16),
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    )),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
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

// ─── Filter Chip ───
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? primary : AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? primary : AppTheme.borderLight,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 14,
                    color: isSelected ? Colors.white : AppTheme.textSecondary),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
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

  const _AnalyticsMiniCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800, color: color)),
          ),
        ],
      ),
    );
  }
}

// ─── MultiBlocBuilder ───
class MultiBlocBuilder extends StatelessWidget {
  final Widget Function(BuildContext, DashboardState, PeopleState) builder;

  const MultiBlocBuilder({super.key, required this.builder});

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

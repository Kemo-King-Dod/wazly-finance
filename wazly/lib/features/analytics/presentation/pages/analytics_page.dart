import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../shared/presentation/widgets/wazly_drawer_premium.dart';
import '../../../shared/presentation/widgets/wazly_navigation_rail.dart';
import '../../../settings/presentation/blocs/settings_bloc.dart';
import '../../../settings/presentation/blocs/settings_state.dart';
import '../blocs/analytics_bloc.dart';
import '../blocs/analytics_event.dart';
import '../blocs/analytics_state.dart';
import '../../domain/entities/time_filter.dart';

/// Analytics page showing spending insights with pie charts
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    // Fetch analytics data when page loads
    context.read<AnalyticsBloc>().add(
      const FetchAnalyticsData(TimeFilter.thisMonth),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(l10n.analytics),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          // Filter dropdown
          Builder(
            builder: (context) => PopupMenuButton<TimeFilter>(
              icon: const Icon(Icons.filter_list_rounded),
              onSelected: (filter) {
                context.read<AnalyticsBloc>().add(FetchAnalyticsData(filter));
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: TimeFilter.thisMonth,
                  child: Text(TimeFilter.thisMonth.getDisplayName(context)),
                ),
                PopupMenuItem(
                  value: TimeFilter.lastMonth,
                  child: Text(TimeFilter.lastMonth.getDisplayName(context)),
                ),
                PopupMenuItem(
                  value: TimeFilter.allTime,
                  child: Text(TimeFilter.allTime.getDisplayName(context)),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: const WazlyDrawerPremium(currentRoute: '/analytics'),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          return Row(
            children: [
              if (settingsState.isNavigationRailEnabled)
                WazlyNavigationRail(
                  currentRoute: '/analytics',
                  onNavigate: (route) {
                    if (route != '/analytics') {
                      Navigator.pushReplacementNamed(context, route);
                    }
                  },
                ),
              Expanded(
                child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
                  builder: (context, state) {
                    if (state is AnalyticsLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.incomeColor,
                        ),
                      );
                    }

                    if (state is AnalyticsError) {
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
                            ElevatedButton(
                              onPressed: () =>
                                  context.read<AnalyticsBloc>().add(
                                    FetchAnalyticsData(
                                      state is AnalyticsLoaded
                                          ? (state as AnalyticsLoaded)
                                                .currentFilter
                                          : TimeFilter.thisMonth,
                                    ),
                                  ),
                              child: Text(l10n.retry),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is AnalyticsLoaded) {
                      return _buildAnalyticsContent(state);
                    }

                    // Handle initial/fallback states
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: AppTheme.incomeColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Preparing Analytics...',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnalyticsContent(AnalyticsLoaded state) {
    if (state.categoryExpenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline_rounded,
              size: 64,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses for this period',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter indicator
          Text(
            'Showing: ${state.currentFilter.displayName}',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 24),

          // Summary Card
          _buildSummaryCard(state),

          const SizedBox(height: 24),

          // Pie Chart Section
          Text(
            'Expense Breakdown',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPieChart(state),
          const SizedBox(height: 24),

          // Category List
          Text(
            'Categories',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...state.categoryExpenses.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final percentage = category.getPercentage(state.totalExpenses);
            final isSelected = index == _touchedIndex;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: isSelected
                    ? category.color.withValues(alpha: 0.1)
                    : AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _touchedIndex = isSelected ? -1 : index;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? category.color.withValues(alpha: 0.5)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: category.color,
                            shape: BoxShape.circle,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: category.color.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            category.category,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: isSelected
                                ? category.color
                                : AppTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'د.ل ${category.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ], // End of Column children
      ), // End of Column
    ); // End of SingleChildScrollView
  }

  Widget _buildPieChart(AnalyticsLoaded state) {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.incomeColor.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  _touchedIndex = -1;
                  return;
                }
                _touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 2,
          centerSpaceRadius: 80,
          sections: state.categoryExpenses.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final isTouched = index == _touchedIndex;
            final fontSize = isTouched ? 16.0 : 14.0;
            final radius = isTouched ? 70.0 : 60.0;
            final percentage = category.getPercentage(state.totalExpenses);

            return PieChartSectionData(
              color: category.color,
              value: category.amount,
              title: '${percentage.toStringAsFixed(1)}%',
              radius: radius,
              titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
              badgeWidget: isTouched ? _buildBadge(category.category) : null,
              badgePositionPercentageOffset: 1.3,
            );
          }).toList(),
        ),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.incomeColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSummaryCard(AnalyticsLoaded state) {
    final net = state.totalIncome - state.totalExpenses;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.incomeColor.withValues(alpha: 0.1),
            AppTheme.cardColor,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.incomeColor.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${state.currentFilter.displayName} Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Income',
                  state.totalIncome,
                  AppTheme.incomeColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  'Total Expenses',
                  state.totalExpenses,
                  AppTheme.debtColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppTheme.textSecondary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${net >= 0 ? '+' : ''}د.ل ${net.toStringAsFixed(2)}',
                style: TextStyle(
                  color: net >= 0 ? AppTheme.incomeColor : AppTheme.debtColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'د.ل ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

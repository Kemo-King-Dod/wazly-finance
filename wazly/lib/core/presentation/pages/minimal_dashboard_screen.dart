import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wazly/core/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:wazly/core/presentation/bloc/transaction_action/transaction_action_bloc.dart';
import 'package:wazly/core/presentation/pages/minimal_people_screen.dart';
import 'package:wazly/core/theme/app_theme.dart';
import 'package:wazly/core/domain/entities/transaction_enums.dart';
import 'package:wazly/core/domain/entities/person_with_balance.dart';
import 'package:wazly/core/presentation/widgets/stat_card.dart';
import 'package:wazly/core/presentation/pages/minimal_transaction_details_screen.dart';
import 'package:wazly/core/presentation/pages/minimal_settings_screen.dart';
import 'package:wazly/core/presentation/pages/theme_screen.dart';
import 'package:wazly/core/presentation/pages/categories/categories_screen.dart';
import 'package:wazly/core/presentation/pages/add_transaction_screen.dart';
import 'package:wazly/core/presentation/pages/security_screen.dart';
import 'package:wazly/core/presentation/pages/about_screen.dart';
import 'package:wazly/core/presentation/widgets/empty_state_view.dart';
import 'package:wazly/l10n/app_localizations.dart';

class MinimalDashboardScreen extends StatefulWidget {
  MinimalDashboardScreen({super.key});

  @override
  State<MinimalDashboardScreen> createState() => _MinimalDashboardScreenState();
}

class _MinimalDashboardScreenState extends State<MinimalDashboardScreen> {
  final Set<String> _pendingDeletions = {};
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppLocalizations.of(context)!.goodMorning;
    if (hour < 17) return AppLocalizations.of(context)!.goodAfternoon;
    return AppLocalizations.of(context)!.goodEvening;
  }

  IconData _iconForType(TransactionType type) {
    switch (type) {
      case TransactionType.treasuryIn:
        return FluentIcons.arrow_download_24_regular;
      case TransactionType.treasuryOut:
        return FluentIcons.arrow_upload_24_regular;
      case TransactionType.debt:
        return FluentIcons.wallet_24_regular;
      case TransactionType.payment:
        return FluentIcons.money_24_regular;
    }
  }

  Color _colorForType(TransactionType type) {
    switch (type) {
      case TransactionType.treasuryIn:
        return AppTheme.incomeColor;
      case TransactionType.treasuryOut:
        return AppTheme.debtColor;
      case TransactionType.debt:
        return AppTheme.warningColor;
      case TransactionType.payment:
        return Color(0xFF3B82F6);
    }
  }

  Widget _buildDrawer(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final primary = Theme.of(context).primaryColor;

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/logo/wazlyLogo.png',
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wazly',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l.aboutSubtitle,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Divider(color: AppTheme.borderLight, height: 28),
            ),

            // ── General Section ──
            _DrawerSectionLabel(l.settings),
            _DrawerTile(
              icon: FluentIcons.settings_24_regular,
              label: l.settings,
              onTap: () => _navigateFromDrawer(context, MinimalSettingsScreen()),
            ),
            _DrawerTile(
              icon: FluentIcons.color_24_regular,
              label: l.theme,
              onTap: () => _navigateFromDrawer(context, ThemeScreen()),
            ),
            _DrawerTile(
              icon: FluentIcons.grid_24_regular,
              label: l.categories,
              onTap: () => _navigateFromDrawer(context, CategoriesScreen()),
            ),

            const SizedBox(height: 8),

            // ── Data & Security Section ──
            _DrawerSectionLabel(l.security),
            _DrawerTile(
              icon: FluentIcons.shield_lock_24_regular,
              label: l.security,
              onTap: () => _navigateFromDrawer(context, SecurityScreen()),
            ),
            _DrawerTile(
              icon: FluentIcons.cloud_sync_24_regular,
              label: l.backupAndRestore,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  l.comingSoon,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: primary),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.comingSoon)),
                );
              },
            ),

            const Spacer(),

            // ── Footer ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Divider(color: AppTheme.borderLight, height: 1),
            ),
            _DrawerTile(
              icon: FluentIcons.info_24_regular,
              label: l.about,
              onTap: () => _navigateFromDrawer(context, AboutScreen()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Text(
                'v1.0.0 Beta',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary.withValues(alpha: 0.45),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateFromDrawer(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.backgroundColor,
      drawer: _buildDrawer(context),
      body: BlocListener<TransactionActionBloc, TransactionActionState>(
        listener: (context, state) {
          if (state is TransactionActionSubmitting) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.submitting),
                duration: Duration(milliseconds: 500),
              ),
            );
          } else if (state is TransactionActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.success),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is TransactionActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.errorPrefix(state.message)),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading || state is DashboardInitial) {
              return Center(
                child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
              );
            }

            if (state is DashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FluentIcons.error_circle_24_regular, size: 48, color: AppTheme.debtColor),
                    SizedBox(height: 12),
                    Text(AppLocalizations.of(context)!.errorPrefix(state.message),
                        style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              );
            }

            if (state is DashboardLoaded) {
              final summary = state.summary;
              final treasury = summary.treasury;
              final debts = summary.activeDebts;
              final txs = summary.recentTransactions;

              // --- Compute stats (logic preserved exactly) ---
              int netMovementToday = 0;
              int totalIn7Days = 0;
              int totalOut7Days = 0;
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final sevenDaysAgo = now.subtract(Duration(days: 7));

              for (final t in txs) {
                if (t.date.isAfter(today)) {
                  final signedAmount = t.signedAmountForTreasury();
                  netMovementToday += signedAmount;
                }

                if (t.date.isAfter(sevenDaysAgo)) {
                  final signedAmount = t.signedAmountForTreasury();
                  if (signedAmount > 0) {
                    totalIn7Days += signedAmount;
                  } else if (signedAmount < 0) {
                    totalOut7Days += signedAmount.abs();
                  }
                }
              }

              final thirtyDaysAgo = now.subtract(Duration(days: 30));
              int overdueCount = 0;
              for (final d in debts) {
                if (d.netBalanceInCents > 0 && d.person.updatedAt.isBefore(thirtyDaysAgo)) {
                  overdueCount++;
                }
              }

              PersonWithBalance? highestExposure;
              for (final d in debts) {
                if (d.netBalanceInCents > 0) {
                  if (highestExposure == null ||
                      d.netBalanceInCents > highestExposure.netBalanceInCents) {
                    highestExposure = d;
                  }
                }
              }

              final bool hasActivityToday = txs.any((t) => t.date.isAfter(today));

              return CustomScrollView(
                key: PageStorageKey('dashboard_list'),
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ═══════════ HEADER ═══════════
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 60, 20, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _scaffoldKey.currentState?.openDrawer(),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.borderLight, width: 1),
                              ),
                              child: Icon(
                                FluentIcons.navigation_24_regular,
                                color: AppTheme.textPrimary,
                                size: 24,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(context),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Wazly',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ═══════════ BALANCE CARD ═══════════
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Container(
                        padding: EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.25),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.totalBalanceText,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 10),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${(treasury.balanceInCents / 100).toStringAsFixed(2)} LYD',
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              AppLocalizations.of(context)!.availableFunds,
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ═══════════ ADD TRANSACTION ACTION ═══════════
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransactionScreen()));
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FluentIcons.add_circle_24_regular, color: Colors.white, size: 22),
                              SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.addTransaction,
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ═══════════ 3 STAT MINI CARDS ═══════════
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              title: AppLocalizations.of(context)!.income7d,
                              value:
                                  '+${(totalIn7Days / 100).toStringAsFixed(0)}',
                              icon: FluentIcons.arrow_down_24_regular,
                              iconColor: AppTheme.incomeColor,
                              valueColor: AppTheme.incomeColor,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              title: AppLocalizations.of(context)!.expense7d,
                              value:
                                  '-${(totalOut7Days / 100).toStringAsFixed(0)}',
                              icon: FluentIcons.arrow_up_24_regular,
                              iconColor: AppTheme.debtColor,
                              valueColor: AppTheme.debtColor,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              title: AppLocalizations.of(context)!.netToday,
                              value:
                                  (netMovementToday / 100).toStringAsFixed(0),
                              icon: FluentIcons.arrow_sort_24_regular,
                              iconColor: Theme.of(context).primaryColor,
                              valueColor: netMovementToday >= 0
                                  ? AppTheme.incomeColor
                                  : AppTheme.debtColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ═══════════ SMART INDICATORS ═══════════
                  if (overdueCount > 0 || highestExposure != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Column(
                          children: [
                            if (overdueCount > 0)
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MinimalPeopleScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  padding: EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppTheme.debtColor.withValues(alpha: 0.06),
                                    borderRadius:
                                        BorderRadius.circular(AppTheme.cardRadius),
                                    border: Border.all(
                                      color: AppTheme.debtColor.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: AppTheme.debtColor.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          FluentIcons.warning_24_regular,
                                          color: AppTheme.debtColor,
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          '$overdueCount ${AppLocalizations.of(context)!.peopleOverdue}',
                                          style: TextStyle(
                                            color: Colors.red.shade800,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        FluentIcons.chevron_right_24_regular,
                                        color: Colors.red.shade400,
                                        size: 22,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (highestExposure != null)
                              Container(
                                padding: EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppTheme.warningColor.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                                  border: Border.all(
                                    color: AppTheme.warningColor.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: AppTheme.warningColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        FluentIcons.arrow_trending_24_regular,
                                        color: AppTheme.warningColor,
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!.highestExposure,
                                            style: TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            highestExposure.person.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '+${(highestExposure.netBalanceInCents / 100).toStringAsFixed(0)} LYD',
                                      style: TextStyle(
                                        color: AppTheme.warningColor,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                  // ═══════════ TOP ACTIVE DEBTS ═══════════
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 28, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.topActiveDebts,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (debts.length > 3)
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.viewAll,
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  if (debts.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppTheme.lightSurfaceVariant,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  FluentIcons.people_24_regular,
                                  size: 24,
                                  color: AppTheme.textSecondary.withValues(alpha: 0.5),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                  AppLocalizations.of(context)!.noActiveDebtsYet,
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Container(
                          decoration: AppTheme.sectionCardDecoration,
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: List.generate(
                              debts.length > 3 ? 3 : debts.length,
                              (index) {
                                final d = debts[index];
                                final amountColor = d.netBalanceInCents > 0
                                    ? AppTheme.incomeColor
                                    : (d.netBalanceInCents < 0
                                        ? AppTheme.debtColor
                                        : AppTheme.textSecondary);
                                final prefix = d.netBalanceInCents > 0 ? '+' : '';

                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text(
                                            d.person.name.isNotEmpty
                                                ? d.person.name[0].toUpperCase()
                                                : '?',
                                            style: TextStyle(
                                              color: Theme.of(context).primaryColor,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              d.person.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                            Text(
                                                AppLocalizations.of(context)!.netBalanceText,
                                              style: TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '$prefix${(d.netBalanceInCents / 100).toStringAsFixed(2)} LYD',
                                        style: TextStyle(
                                          color: amountColor,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                  // ═══════════ RECENT TRANSACTIONS ═══════════
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 28, 20, 10),
                      child: Text(
                        AppLocalizations.of(context)!.recentTransactions,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  if (!hasActivityToday && txs.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: EmptyStateView(
                          icon: Icon(FluentIcons.receipt_24_regular),
                          title: AppLocalizations.of(context)!.emptyDashboardTitle,
                          subtitle: AppLocalizations.of(context)!.emptyDashboardSubtitle,
                          actionLabel: AppLocalizations.of(context)!.addFirstTransaction,
                          onAction: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransactionScreen()));
                          },
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final filteredTxs = txs
                                .where((t) => !_pendingDeletions.contains(t.id))
                                .take(5)
                                .toList();

                            if (index >= filteredTxs.length) return null;
                            final t = filteredTxs[index];

                            final signedAmount = t.signedAmountForTreasury();
                            final amountColor = signedAmount > 0
                                ? AppTheme.incomeColor
                                : (signedAmount < 0
                                    ? AppTheme.debtColor
                                    : AppTheme.textSecondary);
                            final prefix = signedAmount > 0 ? '+' : '';
                            final txIcon = _iconForType(t.type);
                            final txColor = _colorForType(t.type);

                            return GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MinimalTransactionDetailsScreen(transaction: t),
                                  ),
                                );

                                if (result == 'delete' && mounted) {
                                  setState(() => _pendingDeletions.add(t.id));
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  final snackbar = ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(AppLocalizations.of(context)!.transactionDeleted),
                                      duration: Duration(seconds: 4),
                                      action: SnackBarAction(
                                        label: AppLocalizations.of(context)!.undo,
                                        onPressed: () {
                                          if (mounted) {
                                            setState(
                                              () => _pendingDeletions.remove(t.id),
                                            );
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
                                      setState(
                                        () => _pendingDeletions.remove(t.id),
                                      );
                                    }
                                  }
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceCard,
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.cardRadius),
                                  border: Border.all(
                                    color: AppTheme.borderLight,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Icon
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: txColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(txIcon, color: txColor, size: 20),
                                    ),
                                    SizedBox(width: 12),
                                    // Title + date
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.description.isEmpty
                                                ? 'Transaction'
                                                : t.description,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: AppTheme.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            DateFormat('MMM dd, yyyy').format(t.date),
                                            style: TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Amount
                                    Text(
                                      '$prefix${(signedAmount / 100).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: amountColor,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: txs
                              .where((t) => !_pendingDeletions.contains(t.id))
                              .take(5)
                              .length,
                        ),
                      ),
                    ),
                ],
              );
            }

            return SizedBox();
          },
        ),
      ),
    );
  }
}

class _DrawerSectionLabel extends StatelessWidget {
  final String label;
  const _DrawerSectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary.withValues(alpha: 0.5),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 22, color: AppTheme.textSecondary),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

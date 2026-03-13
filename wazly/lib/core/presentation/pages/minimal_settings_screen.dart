import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wazly/core/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:wazly/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wazly/core/data/local/services/backup_restore_service.dart';
import 'package:wazly/core/presentation/pages/categories/categories_screen.dart';
import 'package:wazly/core/presentation/bloc/settings/settings_cubit.dart';
import 'package:wazly/core/presentation/bloc/settings/settings_state.dart';
import 'package:wazly/l10n/app_localizations.dart';
import 'package:wazly/core/presentation/bloc/people/people_bloc.dart';
import 'package:wazly/core/data/local/database/app_database.dart';
import 'package:wazly/core/presentation/widgets/custom_selector_bottom_sheet.dart';
import 'package:wazly/core/data/local/services/notification_service.dart' as wazly_notif;
import 'package:wazly/main.dart'; // For sl (GetIt)

class MinimalSettingsScreen extends StatefulWidget {
  MinimalSettingsScreen({super.key});

  @override
  State<MinimalSettingsScreen> createState() => _MinimalSettingsScreenState();
}

class _MinimalSettingsScreenState extends State<MinimalSettingsScreen> {
  bool _enableInstallments = true;
  bool _darkMode = false;

  String? _lastBackupDate;
  int? _lastBackupSize;
  String? _appVersion = '2.0.0 (Minimal)';
  String? _buildNumber = '42';

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    final prefs = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _lastBackupDate = prefs.getString('last_backup_date');
        _lastBackupSize = prefs.getInt('last_backup_size');
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    }
  }

  void _showImportResult(BackupResult result) {
    if (!mounted) return;
    final success = result.status == ImportStatus.success;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? AppLocalizations.of(context)!.backupRestoredSuccess
              : AppLocalizations.of(context)!.restoreFailed(result.status.name),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        title: Text(AppLocalizations.of(context)!.resetAllData),
        content: Text(
          AppLocalizations.of(context)!.resetAllDataConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Clear the database tables and reset treasury 
                await sl<AppDatabase>().clearDatabase();
                
                // Refresh dashboard and people lists to reflect empty state
                if (mounted) {
                  context.read<DashboardBloc>().add(LoadDashboard());
                  context.read<PeopleBloc>().add(LoadPeople());

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.dataResetSuccess),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.dataResetFailed(e.toString())),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.resetData),
          ),
        ],
      ),
    );
  }

  // --- Section Header ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4, top: 28, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppTheme.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  // --- Card Row Item ---
  Widget _buildSettingsRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  // --- Card Row Switch Item ---
  Widget _buildSettingsSwitchRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, SettingsState state) {
    final _languageItems = const [
      SelectorItem(label: 'English', value: 'en', leadingIcon: '🇺🇸'),
      SelectorItem(label: 'العربية (Arabic)', value: 'ar', leadingIcon: '🇸🇦'),
    ];

    CustomSelectorBottomSheet.show(
      context: context,
      title: AppLocalizations.of(context)!.selectYourLanguage,
      type: SelectorType.language,
      items: _languageItems,
      selectedValue: state.languageCode,
      onSelected: (val) {
        context.read<SettingsCubit>().updateLanguage(val);
      },
    );
  }

  void _showCurrencyPicker(BuildContext context, SettingsState state) {
    final l10n = AppLocalizations.of(context)!;
    final _countryItems = [
      SelectorItem(label: l10n.countryLibya, value: 'LY', leadingIcon: '🇱🇾', badgeText: 'LYD'),
      SelectorItem(label: l10n.countryEgypt, value: 'EG', leadingIcon: '🇪🇬', badgeText: 'EGP'),
      SelectorItem(label: l10n.countryUAE, value: 'AE', leadingIcon: '🇦🇪', badgeText: 'AED'),
      SelectorItem(label: l10n.countrySaudiArabia, value: 'SA', leadingIcon: '🇸🇦', badgeText: 'SAR'),
      SelectorItem(label: l10n.countryUS, value: 'US', leadingIcon: '🇺🇸', badgeText: 'USD'),
      SelectorItem(label: l10n.countryUK, value: 'GB', leadingIcon: '🇬🇧', badgeText: 'GBP'),
      SelectorItem(label: l10n.countryEurozone, value: 'EU', leadingIcon: '🇪🇺', badgeText: 'EUR'),
      SelectorItem(label: l10n.countryIndia, value: 'IN', leadingIcon: '🇮🇳', badgeText: 'INR'),
    ];

    // Find the country code linked specifically to the current currency code or fallback empty
    String? matchedCountryValue;
    try {
      final match = _countryItems.firstWhere((c) => c.badgeText == state.currencyCode);
      matchedCountryValue = match.value;
    } catch (_) {}

    CustomSelectorBottomSheet.show(
      context: context,
      title: l10n.selectYourCountry,
      type: SelectorType.country,
      items: _countryItems,
      selectedValue: matchedCountryValue ?? '',
      onSelected: (val) {
        final selectedCItem = _countryItems.firstWhere((c) => c.value == val);
        context.read<SettingsCubit>().updateCurrency(selectedCItem.badgeText!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        elevation: 0,
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, dashboardState) {
          int txCount = 0;
          if (dashboardState is DashboardLoaded) {
            txCount = dashboardState.summary.recentTransactions.length;
          }

          return ListView(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
            children: [
              // ═══════════════ APP SECTION ═══════════════
              _buildSectionTitle(AppLocalizations.of(context)!.appAndPreferences),
              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, settingsState) {
                  return Container(
                    decoration: AppTheme.sectionCardDecoration,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        _buildSettingsRow(
                          icon: FluentIcons.local_language_24_regular,
                          iconBg: Color(0xFF0284C7).withValues(alpha: 0.1),
                          iconColor: Color(0xFF0284C7),
                          title: AppLocalizations.of(context)!.language,
                          trailing: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.lightSurfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              settingsState.languageCode.toUpperCase(),
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          onTap: () => _showLanguagePicker(context, settingsState),
                        ),
                        _buildSettingsRow(
                          icon: FluentIcons.currency_dollar_euro_24_regular,
                          iconBg: AppTheme.incomeColor.withValues(alpha: 0.1),
                          iconColor: AppTheme.incomeColor,
                          title: AppLocalizations.of(context)!.currency,
                          trailing: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.lightSurfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              settingsState.currencyCode,
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          onTap: () => _showCurrencyPicker(context, settingsState),
                        ),
                    _buildSettingsRow(
                      icon: FluentIcons.grid_24_regular,
                      iconBg: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      iconColor: Theme.of(context).primaryColor,
                      title: AppLocalizations.of(context)!.manageCategories,
                      trailing: Icon(
                        FluentIcons.chevron_right_24_regular,
                        color: AppTheme.textSecondary,
                        size: 22,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoriesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildSettingsRow(
                      icon: FluentIcons.text_sort_ascending_24_regular,
                      iconBg: AppTheme.warningColor.withValues(alpha: 0.1),
                      iconColor: AppTheme.warningColor,
                      title: AppLocalizations.of(context)!.enableInstallments,
                      trailing: Switch(
                        value: _enableInstallments,
                        activeThumbColor: Theme.of(context).primaryColor,
                        onChanged: (val) => setState(() => _enableInstallments = val),
                      ),
                    ),
                    _buildSettingsRow(
                      icon: FluentIcons.dark_theme_24_regular,
                      iconBg: Color(0xFF334155).withValues(alpha: 0.1),
                      iconColor: Color(0xFF334155),
                      title: AppLocalizations.of(context)!.darkMode,
                      trailing: Switch(
                        value: _darkMode,
                        activeThumbColor: Theme.of(context).primaryColor,
                        onChanged: (val) => setState(() => _darkMode = val),
                      ),
                    ),
                      ],
                    ),
                  );
                }
              ),

              // ═══════════════ REMINDERS SECTION ═══════════════
              _buildSectionTitle(AppLocalizations.of(context)!.reminders),
              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, s) {
                  return Column(
                    children: [

                      // ── Daily reminder card ──────────────────────
                      Container(
                        decoration: AppTheme.sectionCardDecoration,
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            // Toggle row
                            _buildSettingsSwitchRow(
                              icon: FluentIcons.alert_24_regular,
                              iconBg: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              iconColor: Theme.of(context).primaryColor,
                              title: AppLocalizations.of(context)!.dailyActivitySummary,
                              subtitle: AppLocalizations.of(context)!.dailyActivitySubtitle,
                              value: s.dailyRemindersEnabled,
                              onChanged: (val) async {
                                context.read<SettingsCubit>().toggleDailyReminders(val);
                                await _applyDailyReminder(val, s);
                              },
                            ),
                            if (s.dailyRemindersEnabled) ...[
                              Divider(height: 1, color: AppTheme.borderLight),
                              // Time picker row
                              _buildTimePickerRow(
                                hour: s.dailyReminderHour,
                                minute: s.dailyReminderMinute,
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay(
                                        hour: s.dailyReminderHour,
                                        minute: s.dailyReminderMinute),
                                  );
                                  if (!mounted || picked == null) return;
                                  await context.read<SettingsCubit>()
                                      .updateDailyTime(picked.hour, picked.minute);
                                  await _applyDailyReminder(
                                      true,
                                      context.read<SettingsCubit>().state);
                                },
                              ),
                              Divider(height: 1, color: AppTheme.borderLight),
                              // Weekday chips
                              _buildWeekdayChips(
                                selected: s.dailyActiveDays,
                                multiSelect: true,
                                onToggle: (day) async {
                                  final newDays =
                                      Set<int>.from(s.dailyActiveDays);
                                  if (newDays.contains(day)) {
                                    if (newDays.length > 1) newDays.remove(day);
                                  } else {
                                    newDays.add(day);
                                  }
                                  await context
                                      .read<SettingsCubit>()
                                      .updateDailyActiveDays(newDays);
                                  await _applyDailyReminder(
                                      true,
                                      context.read<SettingsCubit>().state);
                                },
                              ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(height: 8),

                      // ── Weekly review card ───────────────────────
                      Container(
                        decoration: AppTheme.sectionCardDecoration,
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            _buildSettingsSwitchRow(
                              icon: FluentIcons.calendar_month_24_regular,
                              iconBg: AppTheme.debtColor.withValues(alpha: 0.1),
                              iconColor: AppTheme.debtColor,
                              title: AppLocalizations.of(context)!.weeklyReview,
                              subtitle: AppLocalizations.of(context)!.weeklyReviewSubtitle,
                              value: s.weeklyReviewEnabled,
                              onChanged: (val) async {
                                context.read<SettingsCubit>().toggleWeeklyReview(val);
                                await _applyWeeklyReminder(val, s);
                              },
                            ),
                            if (s.weeklyReviewEnabled) ...[
                              Divider(height: 1, color: AppTheme.borderLight),
                              // Day picker (single select)
                              _buildWeekdayChips(
                                selected: {s.weeklyReminderDay},
                                multiSelect: false,
                                onToggle: (day) async {
                                  await context
                                      .read<SettingsCubit>()
                                      .updateWeeklyDay(day);
                                  await _applyWeeklyReminder(
                                      true,
                                      context.read<SettingsCubit>().state);
                                },
                              ),
                              Divider(height: 1, color: AppTheme.borderLight),
                              // Time picker
                              _buildTimePickerRow(
                                hour: s.weeklyReminderHour,
                                minute: s.weeklyReminderMinute,
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay(
                                        hour: s.weeklyReminderHour,
                                        minute: s.weeklyReminderMinute),
                                  );
                                  if (!mounted || picked == null) return;
                                  await context.read<SettingsCubit>()
                                      .updateWeeklyTime(
                                          picked.hour, picked.minute);
                                  await _applyWeeklyReminder(
                                      true,
                                      context.read<SettingsCubit>().state);
                                },
                              ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(height: 8),

                      // ── Test notification buttons ──────────────
                      Container(
                        decoration: AppTheme.sectionCardDecoration,
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            // Instant test
                            InkWell(
                              onTap: () async {
                                await wazly_notif.NotificationService()
                                    .sendTestNotification();
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!.testNotificationSent),
                                    backgroundColor: Theme.of(context).primaryColor,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36, height: 36,
                                      decoration: BoxDecoration(
                                        color: AppTheme.incomeColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(FluentIcons.send_24_regular, color: AppTheme.incomeColor, size: 18),
                                    ),
                                    SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(AppLocalizations.of(context)!.testNotification,
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                                          Text(AppLocalizations.of(context)!.testNotificationSubtitle,
                                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                        ],
                                      ),
                                    ),
                                    Icon(FluentIcons.chevron_right_24_regular, color: AppTheme.textSecondary, size: 20),
                                  ],
                                ),
                              ),
                            ),

                            Divider(height: 1, color: AppTheme.borderLight),

                            // 1-minute scheduled test (debug)
                            InkWell(
                              onTap: () async {
                                final debugInfo = await wazly_notif
                                    .NotificationService()
                                    .scheduleTestIn1Minute();
                                if (!mounted) return;
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Row(
                                      children: [
                                        Icon(FluentIcons.bug_24_regular,
                                            color: AppTheme.debtColor, size: 22),
                                        SizedBox(width: 8),
                                        Text(AppLocalizations.of(context)!.scheduleDebugTitle,
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                    content: SingleChildScrollView(
                                      child: SelectableText(
                                        debugInfo,
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                          color: AppTheme.textPrimary,
                                          height: 1.6,
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(AppLocalizations.of(context)!.done),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36, height: 36,
                                      decoration: BoxDecoration(
                                        color: AppTheme.debtColor.withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(FluentIcons.timer_24_regular,
                                          color: AppTheme.debtColor, size: 18),
                                    ),
                                    SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(AppLocalizations.of(context)!.scheduledTestTitle,
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                                          Text(AppLocalizations.of(context)!.scheduledTestSubtitle,
                                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                        ],
                                      ),
                                    ),
                                    Icon(FluentIcons.chevron_right_24_regular, color: AppTheme.textSecondary, size: 20),
                                  ],
                                ),
                              ),
                            ),

                            Divider(height: 1, color: AppTheme.borderLight),

                            // MIUI / Battery optimization guidance
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Row(
                                      children: [
                                        Icon(FluentIcons.phone_24_regular,
                                            color: Colors.orange.shade700, size: 22),
                                        SizedBox(width: 8),
                                        Text(AppLocalizations.of(context)!.miuiSettingsTitle,
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(AppLocalizations.of(context)!.miuiInstructions,
                                              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                                          SizedBox(height: 12),
                                          _miuiStep('1', 'الإعدادات ← التطبيقات ← Wazly ← توفير البطارية\nاختر: بدون قيود'),
                                          _miuiStep('2', 'الإعدادات ← البطارية والأداء ← التشغيل التلقائي\nفعّل التشغيل التلقائي لـ Wazly'),
                                          _miuiStep('3', 'الإعدادات ← التطبيقات ← Wazly ← الإشعارات\nتأكد أن جميع أنواع الإشعارات مفعّلة'),
                                          _miuiStep('4', 'الإعدادات ← التطبيقات ← Wazly ← الأذونات\nفعّل: التنبيهات أو الأذونات الأخرى المتعلقة بالمنبه'),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(AppLocalizations.of(context)!.done),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36, height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(FluentIcons.phone_24_regular,
                                          color: Colors.orange.shade700, size: 18),
                                    ),
                                    SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(AppLocalizations.of(context)!.miuiSettingsTitle,
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                                          Text(AppLocalizations.of(context)!.miuiSettingsSubtitle,
                                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                        ],
                                      ),
                                    ),
                                    Icon(FluentIcons.info_24_regular,
                                        color: AppTheme.textSecondary, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  );
                },
              ),

              // ═══════════════ DATA SECTION ═══════════════
              _buildSectionTitle(AppLocalizations.of(context)!.dataAndBackup),
              Container(
                decoration: AppTheme.sectionCardDecoration,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _buildSettingsRow(
                      icon: FluentIcons.cloud_arrow_down_24_regular,
                      iconBg: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      iconColor: Theme.of(context).primaryColor,
                      title: AppLocalizations.of(context)!.exportData,
                      trailing: Icon(
                        FluentIcons.chevron_right_24_regular,
                        color: AppTheme.textSecondary,
                        size: 22,
                      ),
                      onTap: () async {
                        final service = sl<BackupRestoreService>();
                        final success = await service.exportBackup();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? AppLocalizations.of(context)!.backupExportedSuccessfully
                                    : AppLocalizations.of(context)!.exportCancelledOrFailed,
                              ),
                              backgroundColor: success ? Colors.green : null,
                            ),
                          );
                          if (success) _loadMetadata();
                        }
                      },
                    ),
                    if (_lastBackupDate != null && _lastBackupSize != null)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 66, vertical: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${AppLocalizations.of(context)!.lastBackup}: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(_lastBackupDate!))}',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '${(_lastBackupSize! / 1024).toStringAsFixed(1)} KB',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    _buildSettingsRow(
                      icon: FluentIcons.cloud_arrow_up_24_regular,
                      iconBg: AppTheme.incomeColor.withValues(alpha: 0.1),
                      iconColor: AppTheme.incomeColor,
                      title: AppLocalizations.of(context)!.importBackup,
                      trailing: Icon(
                        FluentIcons.chevron_right_24_regular,
                        color: AppTheme.textSecondary,
                        size: 22,
                      ),
                      onTap: () async {
                        final service = sl<BackupRestoreService>();
                        final result = await service.importBackup();

                        if (result.status == ImportStatus.cancelled && mounted) {
                          return;
                        }

                        if (result.status == ImportStatus.schemaMismatch ||
                            result.status == ImportStatus.checksumInvalid) {
                          if (mounted) {
                            showDialog(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                                ),
                                title: Text(AppLocalizations.of(context)!.warningValidationFailed),
                                content: Text(
                                  result.status == ImportStatus.schemaMismatch
                                      ? AppLocalizations.of(context)!.schemaMismatch
                                      : AppLocalizations.of(context)!.corruptedBackup,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogContext),
                                    child: Text(AppLocalizations.of(context)!.cancel),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(dialogContext);
                                      final forceResult = await service.importBackup(
                                        force: true,
                                        filePath: result.filePath,
                                      );
                                      _showImportResult(forceResult);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: Text(AppLocalizations.of(context)!.forceImport),
                                  ),
                                ],
                              ),
                            );
                          }
                        } else {
                          if (mounted) {
                            _showImportResult(result);
                          }
                        }
                      },
                    ),
                    _buildSettingsRow(
                      icon: FluentIcons.receipt_24_regular,
                      iconBg: AppTheme.lightSurfaceVariant,
                      iconColor: AppTheme.textSecondary,
                      title: AppLocalizations.of(context)!.recentTransactions,
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.lightSurfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          txCount.toString(),
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ═══════════════ DANGER SECTION ═══════════════
              _buildSectionTitle(AppLocalizations.of(context)!.dangerZone),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.debtColor.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  border: Border.all(
                    color: AppTheme.debtColor.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildSettingsRow(
                  icon: FluentIcons.delete_24_regular,
                  iconBg: AppTheme.debtColor.withValues(alpha: 0.12),
                  iconColor: AppTheme.debtColor,
                  title: AppLocalizations.of(context)!.resetAllData,
                  trailing: Icon(
                    FluentIcons.chevron_right_24_regular,
                    color: AppTheme.debtColor,
                    size: 22,
                  ),
                  onTap: _showResetConfirmation,
                ),
              ),

              // ═══════════════ ABOUT SECTION ═══════════════
              _buildSectionTitle(AppLocalizations.of(context)!.about),
              Container(
                decoration: AppTheme.sectionCardDecoration,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _buildSettingsRow(
                      icon: FluentIcons.info_24_regular,
                      iconBg: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      iconColor: Theme.of(context).primaryColor,
                      title: AppLocalizations.of(context)!.appVersion,
                      trailing: Text(
                        _appVersion ?? AppLocalizations.of(context)!.unknown,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    _buildSettingsRow(
                      icon: FluentIcons.wrench_24_regular,
                      iconBg: AppTheme.lightSurfaceVariant,
                      iconColor: AppTheme.textSecondary,
                      title: AppLocalizations.of(context)!.buildNumber,
                      trailing: Text(
                        _buildNumber ?? AppLocalizations.of(context)!.unknown,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    _buildSettingsRow(
                      icon: FluentIcons.heart_24_regular,
                      iconBg: AppTheme.debtColor.withValues(alpha: 0.1),
                      iconColor: AppTheme.debtColor,
                      title: AppLocalizations.of(context)!.developer,
                      trailing: Text(
                        AppLocalizations.of(context)!.developerText,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ────────────────────────────────────────────
  // Reminder scheduling helpers
  // ────────────────────────────────────────────

  Future<void> _applyDailyReminder(bool enabled, SettingsState s) async {
    final service = wazly_notif.NotificationService();
    if (enabled && s.dailyActiveDays.isNotEmpty) {
      await service.requestPermissions();
      await service.scheduleDailyReminders(
        baseId: 1001,
        title: AppLocalizations.of(context)!.dailyReminderNotifTitle,
        body: AppLocalizations.of(context)!.dailyReminderNotifBody,
        hour: s.dailyReminderHour,
        minute: s.dailyReminderMinute,
        weekdays: s.dailyActiveDays,
      );
    } else {
      // Cancel all 7 daily slots
      for (int i = 0; i < 7; i++) {
        await service.cancelReminder(1001 + i);
      }
    }
  }

  Future<void> _applyWeeklyReminder(bool enabled, SettingsState s) async {
    final service = wazly_notif.NotificationService();
    if (enabled) {
      await service.requestPermissions();
      await service.scheduleWeeklyReminder(
        id: 1010,
        title: AppLocalizations.of(context)!.weeklyReminderNotifTitle,
        body: AppLocalizations.of(context)!.weeklyReminderNotifBody,
        weekday: s.weeklyReminderDay,
        hour: s.weeklyReminderHour,
        minute: s.weeklyReminderMinute,
      );
    } else {
      await service.cancelReminder(1010);
    }
  }

  // ────────────────────────────────────────────
  // UI helper builders
  // ────────────────────────────────────────────

  Widget _miuiStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                num,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTimePickerRow({
    required int hour,
    required int minute,
    required VoidCallback onTap,
  }) {
    final formatted =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(FluentIcons.clock_24_regular,
                  color: Theme.of(context).primaryColor, size: 18),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.reminderTime,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary),
              ),
            ),
            Text(
              formatted,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor),
            ),
            SizedBox(width: 6),
            Icon(FluentIcons.chevron_right_24_regular,
                color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayChips({
    required Set<int> selected,
    required bool multiSelect,
    required void Function(int day) onToggle,
  }) {
    // Short day labels: Mon=1 … Sun=7
    final isAr =
        AppLocalizations.of(context)!.localeName == 'ar';
    final labels = isAr
        ? ['', 'إث', 'ثل', 'أر', 'خم', 'جم', 'سب', 'أح']
        : ['', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final day = i + 1; // 1=Mon … 7=Sun
          final isActive = selected.contains(day);
          return GestureDetector(
            onTap: () => onToggle(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context).primaryColor
                    : AppTheme.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive
                      ? Theme.of(context).primaryColor
                      : AppTheme.borderLight,
                ),
              ),
              child: Center(
                child: Text(
                  labels[day],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

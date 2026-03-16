import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wazly/core/data/local/database/app_database.dart';
import 'package:wazly/core/data/local/services/backup_restore_service.dart';
import 'package:wazly/core/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:wazly/core/presentation/bloc/people/people_bloc.dart';
import 'package:wazly/core/theme/app_theme.dart';
import 'package:wazly/l10n/app_localizations.dart';
import 'package:wazly/main.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  String? _lastBackupDate;
  int? _lastBackupSize;
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _lastBackupDate = prefs.getString('last_backup_date');
        _lastBackupSize = prefs.getInt('last_backup_size');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          l.backupAndRestore,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        elevation: 0,
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // ── Status card ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(FluentIcons.cloud_checkmark_24_regular,
                    size: 40, color: Colors.white70),
                const SizedBox(height: 12),
                Text(
                  l.dataAndBackup,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                if (_lastBackupDate != null)
                  Text(
                    '${l.lastBackup}: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(_lastBackupDate!))}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  )
                else
                  Text(
                    l.noBackupYet,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                if (_lastBackupSize != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${(_lastBackupSize! / 1024).toStringAsFixed(1)} KB',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Export ──
          _ActionCard(
            icon: FluentIcons.cloud_arrow_down_24_regular,
            iconColor: primary,
            title: l.exportData,
            subtitle: l.exportDataSubtitle,
            isLoading: _isExporting,
            onTap: _handleExport,
          ),

          const SizedBox(height: 12),

          // ── Import ──
          _ActionCard(
            icon: FluentIcons.cloud_arrow_up_24_regular,
            iconColor: AppTheme.incomeColor,
            title: l.importBackup,
            subtitle: l.importBackupSubtitle,
            isLoading: _isImporting,
            onTap: _handleImport,
          ),

          const SizedBox(height: 32),

          // ── Danger zone ──
          Text(
            l.dangerZone,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.debtColor,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.debtColor.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              border: Border.all(
                color: AppTheme.debtColor.withValues(alpha: 0.15),
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              onTap: _showResetConfirmation,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.debtColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(FluentIcons.delete_24_regular,
                          color: AppTheme.debtColor, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.resetAllData,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.debtColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l.resetAllDataSubtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(FluentIcons.chevron_right_24_regular,
                        color: AppTheme.debtColor, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);
    try {
      final service = sl<BackupRestoreService>();
      final success = await service.exportBackup();
      if (!mounted) return;
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
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _handleImport() async {
    final l = AppLocalizations.of(context)!;
    setState(() => _isImporting = true);
    try {
      final service = sl<BackupRestoreService>();
      final result = await service.importBackup();

      if (!mounted) return;
      if (result.status == ImportStatus.cancelled) return;

      if (result.status == ImportStatus.schemaMismatch ||
          result.status == ImportStatus.checksumInvalid) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            ),
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            title: Text(l.warningValidationFailed),
            content: Text(
              result.status == ImportStatus.schemaMismatch
                  ? l.schemaMismatch
                  : l.corruptedBackup,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  final forceResult = await service.importBackup(
                    force: true,
                    filePath: result.filePath,
                  );
                  if (!mounted) return;
                  _showImportResult(forceResult);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(l.forceImport),
              ),
            ],
          ),
        );
      } else {
        _showImportResult(result);
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  void _showImportResult(BackupResult result) {
    if (!mounted) return;
    final success = result.status == ImportStatus.success;
    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? l.backupRestoredSuccess : l.restoreFailed(result.status.name),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
    if (success) {
      context.read<DashboardBloc>().add(LoadDashboard());
      context.read<PeopleBloc>().add(LoadPeople());
    }
  }

  void _showResetConfirmation() {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        title: Text(l.resetAllData),
        content: Text(l.resetAllDataConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await sl<AppDatabase>().clearDatabase();
                if (!mounted) return;
                context.read<DashboardBloc>().add(LoadDashboard());
                context.read<PeopleBloc>().add(LoadPeople());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.dataResetSuccess),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.dataResetFailed(e.toString())),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l.resetData),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.sectionCardDecoration,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: isLoading
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: iconColor,
                        ),
                      )
                    : Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(FluentIcons.chevron_right_24_regular,
                  color: AppTheme.textSecondary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wazly/core/theme/app_theme.dart';
import 'package:wazly/core/data/local/services/notification_service.dart';
import 'package:wazly/core/presentation/bloc/person_action/person_action_bloc.dart';
import 'package:wazly/core/domain/entities/person.dart';
import 'package:wazly/l10n/app_localizations.dart';

class ReminderBottomSheet extends StatefulWidget {
  final Person person;
  final VoidCallback onDismiss;

  const ReminderBottomSheet({
    super.key,
    required this.person,
    required this.onDismiss,
  });

  @override
  State<ReminderBottomSheet> createState() => _ReminderBottomSheetState();
}

class _ReminderBottomSheetState extends State<ReminderBottomSheet> {
  int _selectedPreset = -1; // -1 = none, 0/3/7/14 = preset days, -2 = custom
  DateTime? _customDate;
  TimeOfDay _customTime = const TimeOfDay(hour: 9, minute: 0);

  DateTime get _computedReminderDate {
    if (_selectedPreset == -2 && _customDate != null) {
      return DateTime(
        _customDate!.year,
        _customDate!.month,
        _customDate!.day,
        _customTime.hour,
        _customTime.minute,
      );
    }
    return DateTime.now().add(Duration(days: _selectedPreset));
  }

  bool get _canSave =>
      _selectedPreset == 0 ||
      (_selectedPreset > 0) ||
      (_selectedPreset == -2 && _customDate != null);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final primary = Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          Icon(FluentIcons.alert_24_regular, size: 32, color: primary),
          const SizedBox(height: 12),

          Text(
            l.setAReminderTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.setAReminderSubtitle(widget.person.name),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 24),

          // ── Presets ──
          _buildPreset(days: 3, label: l.in3Days),
          const SizedBox(height: 8),
          _buildPreset(days: 7, label: l.in1Week),
          const SizedBox(height: 8),
          _buildPreset(days: 14, label: l.in2Weeks),

          const SizedBox(height: 8),

          // ── Custom date ──
          _buildCustomDateOption(l, primary),

          const SizedBox(height: 8),

          // ── No reminder ──
          _buildPreset(days: 0, label: l.noReminderSkip),

          const SizedBox(height: 24),

          // ── Save button ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _canSave ? _saveReminder : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.borderLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                l.done,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreset({required int days, required String label}) {
    final isSelected = _selectedPreset == days;
    final primary = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: () => setState(() => _selectedPreset = days),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: 0.1)
              : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primary : AppTheme.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? primary : AppTheme.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(FluentIcons.checkmark_circle_24_filled,
                  color: primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDateOption(AppLocalizations l, Color primary) {
    final isSelected = _selectedPreset == -2;

    return GestureDetector(
      onTap: () async {
        setState(() => _selectedPreset = -2);
        await _pickDate();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: 0.1)
              : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primary : AppTheme.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.customDate,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? primary : AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(FluentIcons.checkmark_circle_24_filled,
                      color: primary, size: 20),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  // Date chip
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Row(
                          children: [
                            Icon(FluentIcons.calendar_24_regular,
                                size: 18, color: primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _customDate != null
                                    ? DateFormat('MMM dd, yyyy')
                                        .format(_customDate!)
                                    : l.selectDate,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _customDate != null
                                      ? AppTheme.textPrimary
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Time chip
                  GestureDetector(
                    onTap: _pickTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: Row(
                        children: [
                          Icon(FluentIcons.clock_24_regular,
                              size: 18, color: primary),
                          const SizedBox(width: 8),
                          Text(
                            '${_customTime.hour.toString().padLeft(2, '0')}:${_customTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _customDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() => _customDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _customTime,
    );
    if (picked != null && mounted) {
      setState(() => _customTime = picked);
    }
  }

  Future<void> _saveReminder() async {
    if (_selectedPreset == 0) {
      widget.onDismiss();
      return;
    }

    final l = AppLocalizations.of(context)!;
    final service = NotificationService();
    await service.requestPermissions();

    final reminderDate = _computedReminderDate;
    final notifId = widget.person.id.hashCode.abs() % 100000;

    final result = await service.scheduleOneTimeReminder(
      id: notifId,
      title: l.debtReminderTitle,
      body: l.debtReminderBody(widget.person.name),
      scheduledDate: reminderDate,
    );

    // If exact alarm permission is missing, guide the user to grant it.
    // The reminder was still scheduled (inexact fallback), but we inform the user
    // that for reliable delivery they should enable "Alarms & reminders".
    if (result.exactPermissionMissing && mounted) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Icon(FluentIcons.alert_24_regular, color: Theme.of(context).primaryColor, size: 22),
              const SizedBox(width: 10),
              Expanded(child: Text(AppLocalizations.of(context)!.enableExactReminders, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
            ],
          ),
          content: Text(
            AppLocalizations.of(context)!.exactRemindersExplanation,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.later),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await service.ensureExactAlarmPermissionIfNeeded();
              },
              child: Text(AppLocalizations.of(context)!.openSettings, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }

    final updatedPerson = widget.person.copyWith(
      nextReminderDate: () => reminderDate,
    );

    if (!mounted) return;
    context.read<PersonActionBloc>().add(UpdatePersonEvent(updatedPerson));
    widget.onDismiss();
  }
}

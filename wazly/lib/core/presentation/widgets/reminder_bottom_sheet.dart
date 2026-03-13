import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  int _selectedDays = 0; // 0 = no reminder

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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

          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(FluentIcons.alert_24_regular,
                size: 32, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            l.setAReminderTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            l.setAReminderSubtitle(widget.person.name),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),

          // Options
          _buildOption(days: 3, label: l.in3Days),
          const SizedBox(height: 12),
          _buildOption(days: 7, label: l.in1Week),
          const SizedBox(height: 12),
          _buildOption(days: 14, label: l.in2Weeks),
          const SizedBox(height: 12),
          _buildOption(days: 0, label: l.noReminderSkip),

          const SizedBox(height: 32),

          // Done Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saveReminder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                l.done,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({required int days, required String label}) {
    final isSelected = _selectedDays == days;
    return GestureDetector(
      onTap: () => setState(() => _selectedDays = days),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : AppTheme.borderLight,
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
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : AppTheme.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(FluentIcons.checkmark_circle_24_filled,
                  color: Theme.of(context).primaryColor, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _saveReminder() async {
    if (_selectedDays > 0) {
      final l = AppLocalizations.of(context)!;
      final service = NotificationService();
      await service.requestPermissions();

      final reminderDate =
          DateTime.now().add(Duration(days: _selectedDays));
      final notifId = widget.person.id.hashCode.abs() % 100000;

      await service.scheduleOneTimeReminder(
        id: notifId,
        title: l.debtReminderTitle,
        body: l.debtReminderBody(widget.person.name),
        scheduledDate: reminderDate,
      );

      final updatedPerson = widget.person.copyWith(
        nextReminderDate: () => reminderDate,
      );

      if (!mounted) return;
      context.read<PersonActionBloc>().add(UpdatePersonEvent(updatedPerson));
    }

    widget.onDismiss();
  }
}

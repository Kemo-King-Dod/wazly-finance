import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:wazly/core/presentation/bloc/settings/settings_cubit.dart';
import 'package:wazly/core/domain/entities/transaction.dart';
import 'package:wazly/core/domain/entities/transaction_enums.dart';
import 'package:wazly/core/theme/app_theme.dart';

import 'package:wazly/core/presentation/pages/minimal_edit_transaction_bottom_sheet.dart';
import 'package:wazly/l10n/app_localizations.dart';
import 'package:wazly/core/utils/app_formatters.dart';

class MinimalTransactionDetailsScreen extends StatefulWidget {
  final Transaction transaction;
  final String? personName;

  const MinimalTransactionDetailsScreen({
    super.key,
    required this.transaction,
    this.personName,
  });

  @override
  State<MinimalTransactionDetailsScreen> createState() =>
      _MinimalTransactionDetailsScreenState();
}

class _MinimalTransactionDetailsScreenState
    extends State<MinimalTransactionDetailsScreen> {
  late Transaction _transaction;

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLocalizations.of(context)!.deleteTransactionTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          AppLocalizations.of(context)!.deleteTxWarning,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, 'delete'); // Return to parent with action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.debtColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine title
    String title = _transaction.description.isNotEmpty
        ? _transaction.description
        : AppLocalizations.of(context)!.transactionTitle;

    if (_transaction.type == TransactionType.treasuryIn) {
      title = AppLocalizations.of(context)!.addedFundsTitle;
    } else if (_transaction.type == TransactionType.treasuryOut) {
      title = AppLocalizations.of(context)!.removedFundsTitle;
    } else if (widget.personName != null) {
      title = widget.personName!;
    }

    // Determine icon and colors
    IconData iconData = FluentIcons.receipt_24_regular;
    Color iconColor = AppTheme.textSecondary;
    int sign = 0;

    if (_transaction.type == TransactionType.treasuryIn) {
      iconData = FluentIcons.arrow_down_24_regular;
      sign = 1;
    } else if (_transaction.type == TransactionType.treasuryOut) {
      iconData = FluentIcons.arrow_up_24_regular;
      sign = -1;
    } else if (_transaction.type == TransactionType.debt) {
      iconData = FluentIcons.money_off_24_regular;
      sign = _transaction.direction == DebtDirection.theyOweMe ? 1 : -1;
    } else if (_transaction.type == TransactionType.payment) {
      iconData = FluentIcons.money_24_regular;
      sign = _transaction.direction == DebtDirection.theyOweMe ? 1 : -1;
    }

    Color amountColor = AppTheme.textSecondary;
    String prefix = '';
    if (sign > 0) {
      amountColor = Colors.green;
      prefix = '+';
      iconColor = Colors.green;
    } else if (sign < 0) {
      amountColor = Colors.red;
      prefix = '-';
      iconColor = Colors.red;
    }

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
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: const Icon(FluentIcons.arrow_left_24_regular,
                          size: 18, color: AppTheme.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.transactionDetails,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: iconColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(iconData, color: iconColor, size: 28),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$prefix${AppFormatters.formatAmountInCents(_transaction.amountInCents)} ${context.watch<SettingsCubit>().state.currencyCode}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: amountColor,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: Column(
                        children: [
                          if (widget.personName != null)
                            _DetailRow(
                              label: AppLocalizations.of(context)!.personLabel,
                              value: widget.personName!,
                              icon: FluentIcons.person_24_regular,
                            ),
                          _DetailRow(
                            label: AppLocalizations.of(context)!.dateAndTimeLabel,
                            value: AppFormatters.formatDate(_transaction.date, 'MMM dd, yyyy • h:mm a'),
                            icon: FluentIcons.calendar_24_regular,
                          ),
                          _DetailRow(
                            label: AppLocalizations.of(context)!.typeLabel,
                            value: _transaction.type.name.toUpperCase(),
                            icon: FluentIcons.tag_24_regular,
                          ),
                          _DetailRow(
                            label: AppLocalizations.of(context)!.transactionId,
                            value: '#${_transaction.id.substring(0, 8)}',
                            icon: FluentIcons.fingerprint_24_regular,
                          ),
                          _DetailRow(
                            label: AppLocalizations.of(context)!.descriptionText,
                            value: _transaction.description.isEmpty
                                ? AppLocalizations.of(context)!.notAvailable
                                : _transaction.description,
                            icon: FluentIcons.note_24_regular,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ═══════════ ACTIONS ═══════════
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      onTap: () async {
                        final updatedTx = await showModalBottomSheet<Transaction>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => MinimalEditTransactionBottomSheet(
                            transaction: _transaction,
                          ),
                        );
                        if (updatedTx != null) {
                          setState(() => _transaction = updatedTx);
                        }
                      },
                      label: AppLocalizations.of(context)!.edit,
                      icon: FluentIcons.edit_24_regular,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      onTap: () => _showDeleteConfirmation(context),
                      label: AppLocalizations.of(context)!.delete,
                      icon: FluentIcons.delete_24_regular,
                      color: AppTheme.debtColor,
                      isOutlined: true,
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
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: AppTheme.textSecondary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: AppTheme.borderLight),
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;
  final Color color;
  final bool isOutlined;

  const _ActionButton({
    required this.onTap,
    required this.label,
    required this.icon,
    required this.color,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(14),
          border: isOutlined ? Border.all(color: color.withValues(alpha: 0.3)) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isOutlined ? color : Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isOutlined ? color : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:intl/intl.dart';
import 'package:wazly/core/domain/entities/transaction.dart';
import 'package:wazly/core/domain/entities/transaction_enums.dart';
import 'package:wazly/core/theme/app_theme.dart';

import 'package:wazly/core/presentation/pages/minimal_edit_transaction_bottom_sheet.dart';
import 'package:wazly/l10n/app_localizations.dart';

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
        title: Text(AppLocalizations.of(context)!.deleteTransactionTitle),
        content: const Text(
          'This action cannot be undone. It will affect balances immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, 'delete'); // Return to parent with action
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
        : 'Transaction';
    if (_transaction.type == TransactionType.treasuryIn) {
      title = 'Added funds';
    } else if (_transaction.type == TransactionType.treasuryOut) {
      title = 'Removed funds';
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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.transactionDetails),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              backgroundColor: iconColor.withValues(alpha: 0.1),
              radius: 40,
              child: Icon(iconData, color: iconColor, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              '$prefix${(_transaction.amountInCents / 100).toStringAsFixed(2)} LYD',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (widget.personName != null) ...[
                      _DetailRow(label: AppLocalizations.of(context)!.personLabel, value: widget.personName!),
                      const Divider(),
                    ],
                    _DetailRow(
                      label: AppLocalizations.of(context)!.dateAndTimeLabel,
                      value: DateFormat(
                        'MMM dd, yyyy • h:mm a',
                      ).format(_transaction.date),
                    ),
                    const Divider(),
                    _DetailRow(
                      label: AppLocalizations.of(context)!.descriptionText,
                      value: _transaction.description.isEmpty
                          ? AppLocalizations.of(context)!.notAvailable
                          : _transaction.description,
                    ),
                    const Divider(),
                    _DetailRow(label: AppLocalizations.of(context)!.transactionId, value: _transaction.id),
                    const Divider(),
                    _DetailRow(
                      label: AppLocalizations.of(context)!.typeLabel,
                      value: _transaction.type.name.toUpperCase(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final updatedTx = await showModalBottomSheet<Transaction>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          child: MinimalEditTransactionBottomSheet(
                            transaction: _transaction,
                          ),
                        ),
                      );

                      if (updatedTx != null) {
                        setState(() {
                          _transaction = updatedTx;
                        });
                      }
                    },
                    icon: const Icon(FluentIcons.edit_24_regular),
                    label: Text(AppLocalizations.of(context)!.edit),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteConfirmation(context),
                    icon: const Icon(FluentIcons.delete_24_regular, color: Colors.red),
                    label: Text(
                      AppLocalizations.of(context)!.delete,
                      style: const TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
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

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

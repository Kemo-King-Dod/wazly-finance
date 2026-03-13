import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:wazly/l10n/app_localizations.dart';
import 'package:wazly/core/presentation/bloc/person_details/person_details_bloc.dart';
import 'package:wazly/core/presentation/bloc/transaction_action/transaction_action_bloc.dart';
import 'package:wazly/core/presentation/bloc/person_action/person_action_bloc.dart';
import 'package:wazly/core/theme/app_theme.dart';
import 'package:wazly/core/domain/entities/transaction_enums.dart';

import 'package:wazly/core/presentation/pages/minimal_transaction_details_screen.dart';
import 'package:wazly/core/presentation/pages/add_debt_payment_screen.dart';
import 'package:wazly/core/presentation/widgets/reminder_bottom_sheet.dart';
import 'package:wazly/core/data/local/services/notification_service.dart';

import 'package:share_plus/share_plus.dart';
import 'package:wazly/core/utils/pdf_generator.dart';

class MinimalPersonDetailsScreen extends StatefulWidget {
  final String personId;

  const MinimalPersonDetailsScreen({super.key, required this.personId});

  @override
  State<MinimalPersonDetailsScreen> createState() =>
      _MinimalPersonDetailsScreenState();
}

class _MinimalPersonDetailsScreenState
    extends State<MinimalPersonDetailsScreen> {
  final Set<String> _pendingDeletions = {};

  Future<void> _launchPhone(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri url = Uri(scheme: 'tel', path: cleanPhone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchWhatsApp(String phone, {String? message}) async {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '+218${cleanPhone.substring(1)}';
    } else if (!cleanPhone.startsWith('+')) {
      cleanPhone = '+$cleanPhone';
    }
    
    Uri url;
    if (message != null) {
      final encodedMessage = Uri.encodeComponent(message);
      url = Uri.parse('https://wa.me/$cleanPhone?text=$encodedMessage');
    } else {
      url = Uri.parse('https://wa.me/$cleanPhone');
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.debtDashboard, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(FluentIcons.delete_24_regular, color: Colors.redAccent),
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.deletePerson),
                  content: Text(
                    AppLocalizations.of(context)!.deletePersonConfirm,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        context.read<PersonActionBloc>().add(
                          DeletePersonEvent(widget.personId),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.delete,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocListener<PersonActionBloc, PersonActionState>(
        listener: (context, state) {
          if (state is PersonActionSuccess) {
            Navigator.pop(context);
          } else if (state is PersonActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: BlocBuilder<PersonDetailsBloc, PersonDetailsState>(
          builder: (context, state) {
            if (state is PersonDetailsLoading || state is PersonDetailsInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PersonDetailsError) {
              return Center(child: Text(AppLocalizations.of(context)!.errorPrefix(state.message)));
            }

            if (state is PersonDetailsLoaded) {
              final person = state.person;
              final netBalance = state.netBalanceInCents;
              final transactions = state.transactions.where((t) => !_pendingDeletions.contains(t.id)).toList();
              final installments = state.installmentPlans;

              // Compute Summaries
              int totalDebtCents = 0;
              int totalPaidCents = 0;
              int paymentCount = 0;
              DateTime? lastTxDate;

              for (final t in transactions) {
                if (t.type == TransactionType.debt) {
                  totalDebtCents += t.amountInCents;
                } else if (t.type == TransactionType.payment) {
                  totalPaidCents += t.amountInCents;
                  paymentCount++;
                }

                if (lastTxDate == null || t.date.isAfter(lastTxDate)) {
                  lastTxDate = t.date;
                }
              }

              final int avgPaymentCents = paymentCount > 0 ? (totalPaidCents ~/ paymentCount) : 0;
              final num remainingAbs = (netBalance / 100).abs();

              // Status Badge Logic
              String statusText = AppLocalizations.of(context)!.settled;
              Color statusColor = Colors.grey;
              Color statusBg = Colors.grey.shade100;

              if (netBalance > 0) {
                statusText = AppLocalizations.of(context)!.owesYou;
                statusColor = AppTheme.incomeColor;
                statusBg = AppTheme.incomeColor.withAlpha(25);
              } else if (netBalance < 0) {
                statusText = AppLocalizations.of(context)!.youOwe;
                statusColor = AppTheme.debtColor;
                statusBg = AppTheme.debtColor.withAlpha(25);
              }

              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                children: [
                  // --- 1. HERO HEADER ---
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Theme.of(context).primaryColor.withAlpha(25),
                          child: Text(
                            person.name.isNotEmpty ? person.name[0].toUpperCase() : AppLocalizations.of(context)!.debt,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          person.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (person.phoneNumber != null && person.phoneNumber!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              person.phoneNumber!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${remainingAbs.toStringAsFixed(2)} LYD',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: netBalance == 0 ? AppTheme.textPrimary : statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- 2. SUMMARY CARDS ---
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          AppLocalizations.of(context)!.totalDebt,
                          totalDebtCents,
                          Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          AppLocalizations.of(context)!.totalPaid,
                          totalPaidCents,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          AppLocalizations.of(context)!.remaining,
                          netBalance.abs(),
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- 3. QUICK ACTIONS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickAction(
                        context,
                        icon: FluentIcons.money_off_24_regular,
                        label: AppLocalizations.of(context)!.addDebt,
                        color: Colors.red,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddDebtPaymentScreen(
                                person: person,
                                initialMode: DebtPaymentMode.debt,
                              ),
                            ),
                          );
                        },
                      ),
                      _buildQuickAction(
                        context,
                        icon: FluentIcons.money_24_regular,
                        label: AppLocalizations.of(context)!.payment,
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddDebtPaymentScreen(
                                person: person,
                                initialMode: DebtPaymentMode.payment,
                              ),
                            ),
                          );
                        },
                      ),
                      _buildQuickAction(
                        context,
                        icon: FluentIcons.call_24_regular,
                        label: AppLocalizations.of(context)!.call,
                        color: Colors.blue,
                        isDisabled: person.phoneNumber == null || person.phoneNumber!.isEmpty,
                        onTap: () {
                          if (person.phoneNumber != null && person.phoneNumber!.isNotEmpty) {
                            _launchPhone(person.phoneNumber!);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.noPhoneNumberAvailable, textAlign: TextAlign.center), duration: const Duration(seconds: 2), behavior: SnackBarBehavior.floating),
                            );
                          }
                        },
                      ),
                      _buildQuickAction(
                        context,
                        icon: FluentIcons.share_24_regular,
                        label: AppLocalizations.of(context)!.shareReport,
                        color: Colors.purple,
                        onTap: () async {
                          try {
                            // Show a quick snackbar while generating
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.generatingReport), duration: const Duration(seconds: 1)),
                            );
                            final pdfPath = await PdfGenerator.generatePersonReport(context, person, state.transactions, netBalance);
                            if (!mounted) return;
                            await Share.shareXFiles(
                              [XFile(pdfPath)],
                              text: 'Wazly Transaction Report for ${person.name}',
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${AppLocalizations.of(context)!.failedToGenerateReport}: $e')),
                            );
                          }
                        },
                      ),
                      _buildQuickAction(
                        context,
                        icon: FluentIcons.alert_24_filled,
                        label: AppLocalizations.of(context)!.remind,
                        color: Colors.orange,
                        isDisabled: person.phoneNumber == null || person.phoneNumber!.isEmpty,
                        onTap: () {
                          if (person.phoneNumber != null && person.phoneNumber!.isNotEmpty) {
                            String message = 'Hello ${person.name}, ';
                            if (netBalance > 0) {
                              message += 'just a friendly reminder about the outstanding balance of ${(netBalance / 100).toStringAsFixed(0)} LYD.';
                            } else if (netBalance < 0) {
                              message += 'I am reaching out regarding my outstanding balance of ${(netBalance.abs() / 100).toStringAsFixed(0)} LYD.';
                            } else {
                              message += 'just saying hi! Our balance is settled.';
                            }
                            _launchWhatsApp(person.phoneNumber!, message: message);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.noPhoneNumberAvailable, textAlign: TextAlign.center), duration: const Duration(seconds: 2), behavior: SnackBarBehavior.floating),
                            );
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // --- 3.5 REMINDER SETTINGS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.remindersSection,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (person.nextReminderDate != null)
                        TextButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (BuildContext bottomSheetContext) => ReminderBottomSheet(
                                person: person,
                                onDismiss: () {
                                  Navigator.pop(bottomSheetContext);
                                  if (!context.mounted) return;
                                  context.read<PersonDetailsBloc>().add(LoadPersonDetails(widget.personId));
                                },
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(AppLocalizations.of(context)!.editButton, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
                        )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: person.nextReminderDate != null
                              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          person.nextReminderDate != null ? FluentIcons.alert_24_filled : FluentIcons.alert_off_24_regular,
                          color: person.nextReminderDate != null ? Theme.of(context).primaryColor : Colors.grey.shade600,
                        ),
                      ),
                      title: Text(
                        person.nextReminderDate != null ? AppLocalizations.of(context)!.activeReminder : AppLocalizations.of(context)!.noReminderSet,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        person.nextReminderDate != null
                            ? AppLocalizations.of(context)!.nextReminder(DateFormat('MMM dd, yyyy').format(person.nextReminderDate!))
                            : AppLocalizations.of(context)!.tapToScheduleReminder,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      trailing: person.nextReminderDate != null
                          ? IconButton(
                              icon: const Icon(FluentIcons.dismiss_circle_24_regular, color: Colors.redAccent),
                              onPressed: () async {
                                final service = NotificationService();
                                final notifId = person.id.hashCode.abs() % 100000;
                                await service.cancelReminder(notifId);
                                
                                final updatedPerson = person.copyWith(
                                  nextReminderDate: () => null,
                                  reminderRepeatType: () => null,
                                );

                                if (!context.mounted) return;
                                context.read<PersonActionBloc>().add(UpdatePersonEvent(updatedPerson));
                                
                                // Also trigger reload immediately
                                context.read<PersonDetailsBloc>().add(LoadPersonDetails(widget.personId));
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppLocalizations.of(context)!.reminderCancelled)),
                                );
                              },
                            )
                          : const Icon(FluentIcons.chevron_right_24_regular, color: AppTheme.borderLight),
                      onTap: person.nextReminderDate == null
                          ? () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (BuildContext bottomSheetContext) => ReminderBottomSheet(
                                  person: person,
                                  onDismiss: () {
                                    Navigator.pop(bottomSheetContext);
                                    if (!context.mounted) return;
                                    context.read<PersonDetailsBloc>().add(LoadPersonDetails(widget.personId));
                                  },
                                ),
                              );
                            }
                          : null,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- 4. INSIGHTS ---
                  Text(
                    AppLocalizations.of(context)!.insights,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Column(
                      children: [
                        _buildInsightRow(AppLocalizations.of(context)!.lastTransaction, lastTxDate != null ? DateFormat('MMM d, yyyy').format(lastTxDate) : AppLocalizations.of(context)!.never),
                        const Divider(height: 24),
                        _buildInsightRow(AppLocalizations.of(context)!.totalTransactions, '${transactions.length}'),
                        const Divider(height: 24),
                        _buildInsightRow(AppLocalizations.of(context)!.averagePayment, '${(avgPaymentCents / 100).toStringAsFixed(2)} LYD'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- 5. TRANSACTION HISTORY ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.history,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (transactions.isNotEmpty)
                        Text(
                          '${transactions.length} ${AppLocalizations.of(context)!.items}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (transactions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                        border: Border.all(color: AppTheme.borderLight, strokeAlign: BorderSide.strokeAlignOutside),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(FluentIcons.history_24_regular, size: 48, color: AppTheme.borderLight),
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context)!.noTransactionsYet,
                              style: const TextStyle(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...transactions.map((t) {
                      final isPayment = t.type == TransactionType.payment;
                      final typeIcon = isPayment ? FluentIcons.arrow_down_24_regular : FluentIcons.arrow_up_24_regular;
                      final typeColor = isPayment ? AppTheme.incomeColor : AppTheme.debtColor;
                      final amountSign = t.signedAmountForPerson() > 0 ? '+' : '';

                      return GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MinimalTransactionDetailsScreen(
                                transaction: t,
                                personName: person.name,
                              ),
                            ),
                          );
                          
                          if (result == 'delete' && mounted) {
                            setState(() => _pendingDeletions.add(t.id));
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            final snackbar = ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.transactionDeleted),
                                action: SnackBarAction(
                                  label: AppLocalizations.of(context)!.undo,
                                  onPressed: () {
                                    if (mounted) setState(() => _pendingDeletions.remove(t.id));
                                  },
                                ),
                              ),
                            );
                            
                            final reason = await snackbar.closed;
                            if (reason != SnackBarClosedReason.action && _pendingDeletions.contains(t.id)) {
                              if (mounted) {
                                context.read<TransactionActionBloc>().add(DeleteTransactionEvent(t.id));
                                setState(() => _pendingDeletions.remove(t.id));
                              }
                            }
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: typeColor.withAlpha(25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(typeIcon, color: typeColor, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isPayment ? AppLocalizations.of(context)!.payment : AppLocalizations.of(context)!.debt,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    if (t.description.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        t.description,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$amountSign${(t.signedAmountForPerson() / 100).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: t.signedAmountForPerson() > 0 ? AppTheme.incomeColor : (t.signedAmountForPerson() < 0 ? AppTheme.debtColor : AppTheme.textPrimary),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('MMM d').format(t.date),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 24),

                  // Installment Plans (Keep old logic mostly intact, but stylized)
                  if (installments.isNotEmpty) ...[
                    Text(
                      AppLocalizations.of(context)!.installmentPlans,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...installments.map(
                      (plan) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan.title.isEmpty ? AppLocalizations.of(context)!.plan : plan.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: plan.isCompleted ? Colors.green.withAlpha(25) : Colors.orange.withAlpha(25),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    plan.isCompleted ? AppLocalizations.of(context)!.completed : AppLocalizations.of(context)!.active,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: plan.isCompleted ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Text(
                              '${(plan.totalAmountInCents / 100).toStringAsFixed(2)} LYD',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 40),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, num cents, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            (cents / 100).toStringAsFixed(0),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap, bool isDisabled = false}) {
    final effectiveIconColor = isDisabled ? AppTheme.textSecondary : color;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDisabled ? AppTheme.borderLight.withAlpha(50) : color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: effectiveIconColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDisabled ? AppTheme.textSecondary : AppTheme.textPrimary,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInsightRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

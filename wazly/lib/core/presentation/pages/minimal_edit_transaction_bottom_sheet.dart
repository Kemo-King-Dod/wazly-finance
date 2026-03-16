import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wazly/core/presentation/bloc/settings/settings_cubit.dart';
import 'package:wazly/core/domain/entities/transaction.dart';
import 'package:wazly/core/domain/entities/transaction_enums.dart';
import 'package:wazly/core/presentation/bloc/people/people_bloc.dart';
import 'package:wazly/core/presentation/bloc/transaction_action/transaction_action_bloc.dart';
import 'package:wazly/core/domain/usecases/add_debt.dart';
import 'package:wazly/core/domain/usecases/add_payment.dart';
import 'package:wazly/core/domain/usecases/affect_treasury.dart';
import 'package:wazly/core/theme/app_theme.dart';
import 'package:wazly/l10n/app_localizations.dart';
import 'package:wazly/core/utils/app_formatters.dart';

class MinimalEditTransactionBottomSheet extends StatefulWidget {
  final Transaction transaction;

  const MinimalEditTransactionBottomSheet({
    super.key,
    required this.transaction,
  });

  @override
  State<MinimalEditTransactionBottomSheet> createState() =>
      _MinimalEditTransactionBottomSheetState();
}

class _MinimalEditTransactionBottomSheetState
    extends State<MinimalEditTransactionBottomSheet> {
  late String? _selectedPersonId;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late DebtDirection _direction;
  late TransactionType _treasuryType;

  bool get isPersonLinked =>
      widget.transaction.type == TransactionType.debt ||
      widget.transaction.type == TransactionType.payment;

  @override
  void initState() {
    super.initState();
    _selectedPersonId = widget.transaction.personId;
    _amountController = TextEditingController(
      text: AppFormatters.formatAmount(widget.transaction.amountInCents / 100),
    );
    _descriptionController = TextEditingController(
      text: widget.transaction.description,
    );
    _direction = widget.transaction.direction ?? DebtDirection.theyOweMe;

    // For treasury context
    _treasuryType = widget.transaction.type;
    if (_treasuryType == TransactionType.debt ||
        _treasuryType == TransactionType.payment) {
      // Fallback for UI if somehow accessed incorrectly
      _treasuryType = TransactionType.treasuryIn;
    }

    _amountController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _amountController.removeListener(_onInputChanged);
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isValid {
    if (isPersonLinked && _selectedPersonId == null) return false;
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return false;
    return true;
  }

  void _submit() {
    if (!_isValid) return;

    final amount = double.parse(_amountController.text);
    final amountInCents = (amount * 100).toInt();

    TransactionActionEvent newAction;

    if (widget.transaction.type == TransactionType.debt) {
      newAction = SubmitDebt(
        AddDebtParams(
          personId: _selectedPersonId!,
          amountInCents: amountInCents,
          direction: _direction,
          description: _descriptionController.text.trim(),
          date: widget.transaction.date, // Preserve original date
        ),
      );
    } else if (widget.transaction.type == TransactionType.payment) {
      newAction = SubmitPayment(
        AddPaymentParams(
          personId: _selectedPersonId!,
          amountInCents: amountInCents,
          direction: _direction,
          description: _descriptionController.text.trim(),
          date: widget.transaction.date, // Preserve original date
        ),
      );
    } else {
      newAction = SubmitTreasuryFlow(
        AffectTreasuryParams(
          amountInCents: amountInCents,
          type: _treasuryType,
          description: _descriptionController.text.trim(),
          date: widget.transaction.date, // Preserve original date
        ),
      );
    }

    context.read<TransactionActionBloc>().add(
      EditTransactionEvent(
        oldTransactionId: widget.transaction.id,
        newAction: newAction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Edit Transaction';
    if (widget.transaction.type == TransactionType.debt) title = 'Edit Debt';
    if (widget.transaction.type == TransactionType.payment) {
      title = 'Edit Payment';
    }
    if (!isPersonLinked) title = 'Edit Treasury Options';

    return BlocListener<TransactionActionBloc, TransactionActionState>(
      listener: (context, state) {
        if (state is TransactionActionSuccess) {
          final updatedTx = Transaction(
            id: widget
                .transaction
                .id, // Keep old ID logically for the UI reference, though backend has a new one. It doesn't matter for the static details page.
            amountInCents: (double.parse(_amountController.text) * 100).toInt(),
            type: widget.transaction.type,
            direction: isPersonLinked ? _direction : null,
            description: _descriptionController.text.trim(),
            date: widget.transaction.date,
            personId: _selectedPersonId,
          );
          Navigator.pop(context, updatedTx);
        }
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (isPersonLinked)
              BlocBuilder<PeopleBloc, PeopleState>(
                builder: (context, state) {
                  if (state is PeopleLoaded) {
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.selectPerson,
                      ),
                      initialValue: _selectedPersonId,
                      items: state.fullList.map((pb) {
                        return DropdownMenuItem(
                          value: pb.person.id,
                          child: Text(pb.person.name),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedPersonId = val),
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
            if (!isPersonLinked)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Text(
                      AppLocalizations.of(context)!.typeLabel,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  _buildTreasuryToggle(),
                ],
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.amountLabel,
                suffixText: context.watch<SettingsCubit>().state.currencyCode,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.descriptionOptionalLabel,
              ),
            ),
            const SizedBox(height: 16),
            if (isPersonLinked)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Text(
                      AppLocalizations.of(context)!.directionLabel,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  _buildDirectionToggle(),
                ],
              ),
            const SizedBox(height: 24),
            BlocBuilder<TransactionActionBloc, TransactionActionState>(
              builder: (context, state) {
                final isSubmitting = state is TransactionActionSubmitting;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state is TransactionActionError)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: (_isValid && !isSubmitting) ? _submit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.indigo.withValues(
                            alpha: 0.3,
                          ),
                          disabledForegroundColor: Colors.white.withValues(
                            alpha: 0.7,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTreasuryToggle() {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTreasurySegment(l.addToTreasury, TransactionType.treasuryIn),
          _buildTreasurySegment(l.removeFromTreasury, TransactionType.treasuryOut),
        ],
      ),
    );
  }

  Widget _buildTreasurySegment(String title, TransactionType type) {
    final isSelected = _treasuryType == type;
    final activeColor = type == TransactionType.treasuryIn 
        ? AppTheme.incomeColor 
        : AppTheme.debtColor;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_treasuryType != type) {
            setState(() {
              _treasuryType = type;
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionToggle() {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildDirectionSegment(l.theyOweMeGive, DebtDirection.theyOweMe),
          _buildDirectionSegment(l.iOweThemReceive, DebtDirection.iOweThem),
        ],
      ),
    );
  }

  Widget _buildDirectionSegment(String title, DebtDirection direction) {
    final isSelected = _direction == direction;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_direction != direction) {
            setState(() {
              _direction = direction;
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

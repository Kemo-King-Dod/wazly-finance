import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wazly/core/presentation/bloc/settings/settings_cubit.dart';
import 'package:wazly/core/domain/entities/person.dart';
import 'package:wazly/core/domain/entities/transaction_enums.dart';
import 'package:wazly/core/presentation/bloc/transaction_action/transaction_action_bloc.dart';
import 'package:wazly/core/theme/app_theme.dart';
import 'package:wazly/l10n/app_localizations.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:wazly/core/data/local/services/notification_service.dart';
import 'package:wazly/core/utils/app_formatters.dart';
import 'package:wazly/core/domain/usecases/add_debt.dart';
import 'package:wazly/core/domain/usecases/add_payment.dart';

enum DebtPaymentMode { debt, payment }

class AddDebtPaymentScreen extends StatefulWidget {
  final Person person;
  final DebtPaymentMode initialMode;

  const AddDebtPaymentScreen({
    super.key,
    required this.person,
    this.initialMode = DebtPaymentMode.debt,
  });

  @override
  State<AddDebtPaymentScreen> createState() => _AddDebtPaymentScreenState();
}

class _AddDebtPaymentScreenState extends State<AddDebtPaymentScreen> {
  late DebtPaymentMode _mode;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Transaction date
  DateTime _selectedDate = DateTime.now();

  // Due date & reminder
  DateTime? _dueDate;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _enableReminder = false;

  // Preset index: 0=3d, 1=7d, 2=14d, 3=custom, null=none
  int? _selectedPreset;

  DebtDirection _direction = DebtDirection.theyOweMe;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
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
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return false;
    return true;
  }

  void _submit() {
    if (!_isValid) return;

    final amount = double.parse(_amountController.text);
    final amountInCents = (amount * 100).toInt();

    switch (_mode) {
      case DebtPaymentMode.debt:
        context.read<TransactionActionBloc>().add(
          SubmitDebt(
            AddDebtParams(
              personId: widget.person.id,
              amountInCents: amountInCents,
              direction: _direction,
              description: _descriptionController.text,
              date: _selectedDate,
            ),
          ),
        );
        break;
      case DebtPaymentMode.payment:
        context.read<TransactionActionBloc>().add(
          SubmitPayment(
            AddPaymentParams(
              personId: widget.person.id,
              amountInCents: amountInCents,
              direction: _direction,
              description: _descriptionController.text,
              date: _selectedDate,
            ),
          ),
        );
        break;
    }
  }

  Future<void> _scheduleReminderIfNeeded() async {
    if (_mode != DebtPaymentMode.debt) return;
    if (_dueDate == null || !_enableReminder) return;

    final reminderAt = DateTime(
      _dueDate!.year,
      _dueDate!.month,
      _dueDate!.day,
      _reminderTime.hour,
      _reminderTime.minute,
    );

    if (reminderAt.isBefore(DateTime.now())) return;

    final int notifId = widget.person.id.hashCode.abs() % 100000;
    final service = NotificationService();
    await service.scheduleOneTimeReminder(
      id: notifId,
      title: AppLocalizations.of(context)!.debtReminderNotifTitle,
      body: AppLocalizations.of(context)!.debtReminderNotifBody,
      scheduledDate: reminderAt,
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (time != null && mounted) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _applyPreset(int daysFromNow) {
    final now = DateTime.now();
    setState(() {
      _dueDate = now.add(Duration(days: daysFromNow));
    });
  }

  Future<void> _pickCustomDueDate() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? tomorrow,
      firstDate: tomorrow, // no past dates
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && mounted) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: BlocListener<TransactionActionBloc, TransactionActionState>(
        listener: (context, state) async {
          if (state is TransactionActionSuccess) {
            await _scheduleReminderIfNeeded();
            if (!mounted) return;
            Navigator.pop(context);
          } else if (state is TransactionActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.debtColor,
              ),
            );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // ═══════════ HEADER ═══════════
              Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                        child: Icon(FluentIcons.arrow_left_24_regular,
                            size: 18, color: AppTheme.textSecondary),
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.person.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            AppLocalizations.of(context)!.manageDebtsAndPayments,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Person avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          widget.person.name.isNotEmpty
                              ? widget.person.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ═══════════ SCROLLABLE FORM ═══════════
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  children: [
                    // ── Pill Toggle ──
                    _buildPillToggle(),
                    SizedBox(height: 24),

                    // ── Amount Card ──
                    _buildSectionCard(
                      icon: FluentIcons.payment_24_regular,
                      iconColor: Theme.of(context).primaryColor,
                      child: TextField(
                        controller: _amountController,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: -1,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          suffixText: context.watch<SettingsCubit>().state.currencyCode,
                          suffixStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    SizedBox(height: 12),

                    // ── Direction Toggle ──
                    _buildDirectionToggle(),
                    SizedBox(height: 12),

                    // ── Transaction Date Card ──
                    GestureDetector(
                      onTap: _pickDate,
                      child: _buildSectionCard(
                        icon: FluentIcons.calendar_24_regular,
                        iconColor: AppTheme.warningColor,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.dateAndTime,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    AppFormatters.formatDate(_selectedDate, 'MMM dd, yyyy • h:mm a'),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
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
                    SizedBox(height: 12),

                    // ── Note Card ──
                    _buildSectionCard(
                      icon: FluentIcons.note_24_regular,
                      iconColor: AppTheme.incomeColor,
                      child: TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.descriptionOptional,
                          hintStyle: TextStyle(color: AppTheme.textSecondary),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: null,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),

                    // ── Due Date & Reminder (debt mode only) ──
                    if (_mode == DebtPaymentMode.debt) ...[
                      SizedBox(height: 12),
                      _buildDueDateSection(),
                    ],

                    SizedBox(height: 28),
                  ],
                ),
              ),

              // ═══════════ SAVE BUTTON ═══════════
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: BlocBuilder<TransactionActionBloc, TransactionActionState>(
                  builder: (context, state) {
                    final isSubmitting = state is TransactionActionSubmitting;
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: (_isValid && !isSubmitting) ? _submit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              Theme.of(context).primaryColor.withValues(alpha: 0.3),
                          disabledForegroundColor:
                              Colors.white.withValues(alpha: 0.7),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isSubmitting
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                AppLocalizations.of(context)!.save,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Due Date & Reminder Section ───
  Widget _buildDueDateSection() {
    final hasDue = _dueDate != null;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: hasDue
              ? Theme.of(context).primaryColor.withValues(alpha: 0.35)
              : AppTheme.borderLight,
          width: hasDue ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.debtColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(FluentIcons.calendar_clock_24_regular,
                      color: AppTheme.debtColor, size: 18),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.dueDateAndReminder,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (hasDue)
                        Text(
                          AppFormatters.formatDate(_dueDate!, 'MMM dd, yyyy'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        Text(
                          AppLocalizations.of(context)!.dueDateOptional,
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary),
                        ),
                    ],
                  ),
                ),
                if (hasDue)
                  GestureDetector(
                    onTap: () => setState(() {
                      _dueDate = null;
                      _selectedPreset = null;
                      _enableReminder = false;
                    }),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.debtColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.clearDueDate,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.debtColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Preset chips
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Row(
              children: [
                _buildPresetChip(AppLocalizations.of(context)!.preset3d, 0, () {
                  setState(() => _selectedPreset = 0);
                  _applyPreset(3);
                }),
                SizedBox(width: 8),
                _buildPresetChip(AppLocalizations.of(context)!.preset7d, 1, () {
                  setState(() => _selectedPreset = 1);
                  _applyPreset(7);
                }),
                SizedBox(width: 8),
                _buildPresetChip(AppLocalizations.of(context)!.preset14d, 2, () {
                  setState(() => _selectedPreset = 2);
                  _applyPreset(14);
                }),
                SizedBox(width: 8),
                _buildPresetChip(AppLocalizations.of(context)!.presetCustom, 3, () async {
                  setState(() => _selectedPreset = 3);
                  await _pickCustomDueDate();
                }),
              ],
            ),
          ),

          // ── Reminder toggle (only if due date set)
          if (hasDue) ...[
            Divider(height: 1, color: AppTheme.borderLight),
            // Enable reminder switch
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Icon(FluentIcons.alert_24_regular,
                      size: 18, color: AppTheme.textSecondary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.enableReminder,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                    Switch.adaptive(
                    value: _enableReminder,
                    onChanged: (v) => setState(() => _enableReminder = v),
                    activeThumbColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),

            // Reminder time picker (only if enabled)
            if (_enableReminder) ...[
              Divider(height: 1, color: AppTheme.borderLight),
              GestureDetector(
                onTap: _pickReminderTime,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Icon(FluentIcons.clock_24_regular,
                          size: 18, color: Theme.of(context).primaryColor),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.reminderTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              _reminderTime.format(context),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(FluentIcons.chevron_right_24_regular,
                          color: AppTheme.textSecondary, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, int index, VoidCallback onTap) {
    final isActive = _selectedPreset == index;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  // ─── Pill Toggle ───
  Widget _buildPillToggle() {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildSegment(AppLocalizations.of(context)!.debtLabel, DebtPaymentMode.debt),
          _buildSegment(AppLocalizations.of(context)!.paymentLabel, DebtPaymentMode.payment),
        ],
      ),
    );
  }

  Widget _buildSegment(String title, DebtPaymentMode mode) {
    final isSelected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_mode != mode) {
            setState(() {
              _mode = mode;
              _direction = DebtDirection.theyOweMe;
              // Reset due date when switching to payment
              if (mode == DebtPaymentMode.payment) {
                _dueDate = null;
                _selectedPreset = null;
                _enableReminder = false;
              }
            });
          }
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
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
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _mode == DebtPaymentMode.debt 
          ? [
              _buildDirectionSegment(l.theyOweMe, DebtDirection.theyOweMe),
              _buildDirectionSegment(l.iOweThem, DebtDirection.iOweThem),
            ]
          : [
              _buildDirectionSegment(l.theyPaidMe, DebtDirection.theyOweMe),
              _buildDirectionSegment(l.iPaidThem, DebtDirection.iOweThem),
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
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
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

  // ─── Section Card ───
  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.borderLight, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

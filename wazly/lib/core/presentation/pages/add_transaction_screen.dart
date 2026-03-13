import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wazly/core/presentation/bloc/transaction_action/transaction_action_bloc.dart';
import 'package:wazly/core/presentation/bloc/categories/categories_bloc.dart';
import 'package:wazly/core/presentation/bloc/categories/categories_event.dart';
import 'package:wazly/core/presentation/bloc/categories/categories_state.dart';
import 'package:wazly/core/domain/entities/transaction_enums.dart';
import 'package:wazly/core/domain/entities/category_entity.dart';
import 'package:wazly/core/domain/usecases/affect_treasury.dart';
import 'package:wazly/core/theme/app_theme.dart';
import 'package:wazly/core/utils/app_icons.dart';
import 'package:wazly/core/presentation/pages/categories/add_category_screen.dart';
import 'package:intl/intl.dart';
import 'package:wazly/l10n/app_localizations.dart';

enum TransactionMode { income, expense }

class AddTransactionScreen extends StatefulWidget {
  AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  TransactionMode _mode = TransactionMode.income;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  CategoryEntity? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onInputChanged);
    context.read<CategoriesBloc>().add(LoadCategoriesEvent(0));
  }

  void _onInputChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _amountController.removeListener(_onInputChanged);
    _amountController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return false;
    if (_selectedCategory == null) return false;
    return true;
  }

  void _submit() {
    if (!_isValid) return;

    final amount = double.parse(_amountController.text);
    final amountInCents = (amount * 100).toInt();

    final note = _descriptionController.text.trim();
    final description = note.isEmpty
        ? _selectedCategory!.name
        : '${_selectedCategory!.name} - $note';

    switch (_mode) {
      case TransactionMode.income:
        context.read<TransactionActionBloc>().add(
          SubmitTreasuryFlow(
            AffectTreasuryParams(
              amountInCents: amountInCents,
              type: TransactionType.treasuryIn,
              description: description,
              date: _selectedDate,
            ),
          ),
        );
        break;
      case TransactionMode.expense:
        context.read<TransactionActionBloc>().add(
          SubmitTreasuryFlow(
            AffectTreasuryParams(
              amountInCents: amountInCents,
              type: TransactionType.treasuryOut,
              description: description,
              date: _selectedDate,
            ),
          ),
        );
        break;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: BlocListener<TransactionActionBloc, TransactionActionState>(
        listener: (context, state) {
          if (state is TransactionActionSuccess) {
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
                            'New Transaction',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Record income or expense',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
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
                          suffixText: 'LYD',
                          suffixStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),

                    // ── Category Card ──
                    BlocBuilder<CategoriesBloc, CategoriesState>(
                      builder: (context, state) {
                        List<CategoryEntity> categories = [];
                        bool isLoading = state is CategoriesLoading;

                        if (state is CategoriesLoaded) {
                          categories = state.categories;
                          if (_selectedCategory != null &&
                              state.type ==
                                  (_mode == TransactionMode.income ? 0 : 1)) {
                            final exists = categories.any(
                              (c) => c.id == _selectedCategory!.id,
                            );
                            if (!exists) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() => _selectedCategory = null);
                                }
                              });
                            }
                          }
                        }

                        return _buildSectionCard(
                          icon: FluentIcons.grid_24_regular,
                          iconColor: AppTheme.warningColor,
                          child: DropdownButtonFormField<CategoryEntity>(
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.category,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            isExpanded: true,
                            value: _selectedCategory,
                            icon: isLoading
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )
                                : Icon(FluentIcons.chevron_down_24_regular),
                            items: [
                              ...categories.map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: Color(category.colorValue)
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                        child: Icon(
                                          AppIcons.getIcon(int.parse(category.iconCode, radix: 16)),
                                          color: Color(category.colorValue),
                                          size: 16,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        category.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              DropdownMenuItem<CategoryEntity>(
                                value: null,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(7),
                                      ),
                                      child: Icon(
                                        FluentIcons.add_24_regular,
                                        color: Theme.of(context).primaryColor,
                                        size: 16,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Add New Category...',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              if (val == null) {
                                final currentType =
                                    _mode == TransactionMode.income ? 0 : 1;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddCategoryScreen(type: currentType),
                                  ),
                                ).then((_) {
                                  if (mounted) {
                                    context.read<CategoriesBloc>().add(
                                      LoadCategoriesEvent(currentType),
                                    );
                                  }
                                });
                                return;
                              }
                              setState(() => _selectedCategory = val);
                            },
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 12),

                    // ── Date Card ──
                    GestureDetector(
                      onTap: _pickDate,
                      child: _buildSectionCard(
                        icon: FluentIcons.calendar_24_regular,
                        iconColor: Color(0xFF3B82F6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date & Time',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    DateFormat('MMM dd, yyyy • h:mm a')
                                        .format(_selectedDate),
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
                          hintText: AppLocalizations.of(context)!.optionalNote,
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
                    SizedBox(height: 28),
                  ],
                ),
              ),

              // ═══════════ SAVE BUTTON ═══════════
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: BlocBuilder<TransactionActionBloc,
                    TransactionActionState>(
                  builder: (context, state) {
                    final isSubmitting = state is TransactionActionSubmitting;
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            (_isValid && !isSubmitting) ? _submit : null,
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
                                'Save Transaction',
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
          _buildSegment('Income', TransactionMode.income),
          _buildSegment('Expense', TransactionMode.expense),
        ],
      ),
    );
  }

  Widget _buildSegment(String title, TransactionMode mode) {
    final isSelected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_mode != mode) {
            setState(() {
              _mode = mode;
              _selectedCategory = null;
              context.read<CategoriesBloc>().add(
                LoadCategoriesEvent(mode == TransactionMode.income ? 0 : 1),
              );
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

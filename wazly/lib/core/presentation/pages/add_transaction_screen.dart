import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wazly/core/presentation/bloc/settings/settings_cubit.dart';
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
import 'package:intl/intl.dart' hide TextDirection;
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

  void _openCategoryPicker() {
    final currentType = _mode == TransactionMode.income ? 0 : 1;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CategoriesBloc>(),
        child: _CategoryBottomSheet(
          type: currentType,
          selected: _selectedCategory,
          onSelected: (cat) {
            setState(() => _selectedCategory = cat);
            Navigator.pop(context);
          },
          onAddNew: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddCategoryScreen(type: currentType),
              ),
            ).then((_) {
              if (mounted) {
                context.read<CategoriesBloc>().add(
                  LoadCategoriesEvent(currentType),
                );
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final primary = Theme.of(context).primaryColor;

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.newTransaction,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l.recordIncomeExpense,
                            style: const TextStyle(
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

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  children: [
                    _buildPillToggle(l),
                    const SizedBox(height: 24),

                    _buildSectionCard(
                      icon: FluentIcons.payment_24_regular,
                      iconColor: primary,
                      child: TextField(
                        controller: _amountController,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
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
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildCategorySelector(l, primary),
                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: _pickDate,
                      child: _buildSectionCard(
                        icon: FluentIcons.calendar_24_regular,
                        iconColor: const Color(0xFF3B82F6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.dateAndTime,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('MMM dd, yyyy • h:mm a')
                                        .format(_selectedDate),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(FluentIcons.chevron_right_24_regular,
                                color: AppTheme.textSecondary, size: 22),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildSectionCard(
                      icon: FluentIcons.note_24_regular,
                      iconColor: AppTheme.incomeColor,
                      child: TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: l.optionalNote,
                          hintStyle:
                              const TextStyle(color: AppTheme.textSecondary),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: null,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              primary.withValues(alpha: 0.3),
                          disabledForegroundColor:
                              Colors.white.withValues(alpha: 0.7),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                l.saveTransaction,
                                style: const TextStyle(
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

  // ─── Category Selector (tap → bottom sheet) ───
  Widget _buildCategorySelector(AppLocalizations l, Color primary) {
    return GestureDetector(
      onTap: _openCategoryPicker,
      child: _buildSectionCard(
        icon: FluentIcons.grid_24_regular,
        iconColor: AppTheme.warningColor,
        child: Row(
          children: [
            Expanded(
              child: _selectedCategory != null
                  ? Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Color(_selectedCategory!.colorValue)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            AppIcons.getIcon(
                                int.parse(_selectedCategory!.iconCode, radix: 16)),
                            color: Color(_selectedCategory!.colorValue),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedCategory!.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      l.selectCategory,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
            ),
            const Icon(FluentIcons.chevron_right_24_regular,
                color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  // ─── Pill Toggle ───
  Widget _buildPillToggle(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildSegment(l.income, TransactionMode.income),
          _buildSegment(l.expense, TransactionMode.expense),
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
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
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
      padding: const EdgeInsets.all(14),
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
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  Category Bottom Sheet
// ═══════════════════════════════════════════════════
class _CategoryBottomSheet extends StatelessWidget {
  final int type;
  final CategoryEntity? selected;
  final ValueChanged<CategoryEntity> onSelected;
  final VoidCallback onAddNew;

  const _CategoryBottomSheet({
    required this.type,
    required this.selected,
    required this.onSelected,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final primary = Theme.of(context).primaryColor;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l.selectCategory,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onAddNew,
                  icon: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(FluentIcons.add_24_regular,
                        size: 18, color: primary),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: BlocBuilder<CategoriesBloc, CategoriesState>(
              builder: (context, state) {
                if (state is CategoriesLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                List<CategoryEntity> categories = [];
                if (state is CategoriesLoaded) {
                  categories = state.categories;
                }

                if (categories.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FluentIcons.grid_24_regular,
                            size: 48,
                            color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text(
                          l.noCategoriesYet,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l.tapToAddCategory,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = selected?.id == cat.id;
                    final catColor = Color(cat.colorValue);

                    return GestureDetector(
                      onTap: () => onSelected(cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? catColor.withValues(alpha: 0.12)
                              : AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? catColor.withValues(alpha: 0.5)
                                : AppTheme.borderLight,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                AppIcons.getIcon(
                                    int.parse(cat.iconCode, radix: 16)),
                                color: catColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                cat.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? catColor
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

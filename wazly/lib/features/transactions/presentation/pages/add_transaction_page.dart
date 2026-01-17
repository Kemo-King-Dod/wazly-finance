import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/transaction_entity.dart';
import '../blocs/transaction_bloc.dart';
import '../blocs/transaction_event.dart';
import '../blocs/transaction_state.dart';
import '../widgets/transaction_category.dart';

/// Page for adding a new transaction
class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isIncome = false;
  int _selectedCategoryIndex = 0;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim();
      final category =
          TransactionCategories.categories[_selectedCategoryIndex].name;

      // Create transaction entity
      final transaction = TransactionEntity(
        id: const Uuid().v4(),
        amount: amount,
        category: category,
        date: DateTime.now(),
        description: description,
        isIncome: _isIncome,
        isDebt: false,
        accountId: 'default', // TODO: Support multiple accounts
      );

      // Add transaction via BLoC
      context.read<TransactionBloc>().add(AddTransactionEvent(transaction));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionLoaded) {
          // Success! Show feedback and navigate back
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.transactionAdded),
              backgroundColor: AppTheme.incomeColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.of(context).pop();
        } else if (state is TransactionError) {
          // Show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.debtColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(l10n.addTransaction),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            final isLoading = state is TransactionAddingTransaction;

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Income/Expense Toggle
                  _buildIncomeExpenseToggle(),
                  const SizedBox(height: 32),

                  // Amount Input
                  _buildAmountInput(),
                  const SizedBox(height: 24),

                  // Description Input
                  _buildDescriptionInput(),
                  const SizedBox(height: 32),

                  // Category Picker
                  _buildCategoryPicker(),
                  const SizedBox(height: 48),

                  // Save Button
                  _buildSaveButton(isLoading),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isIncome
              ? AppTheme.incomeColor.withValues(alpha: 0.3)
              : AppTheme.debtColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleOption(
              context: context,
              label: AppLocalizations.of(context)!.expense,
              icon: Icons.arrow_upward_rounded,
              isSelected: !_isIncome,
              color: AppTheme.debtColor,
              onTap: () => setState(() => _isIncome = false),
            ),
          ),
          Expanded(
            child: _buildToggleOption(
              context: context,
              label: AppLocalizations.of(context)!.income,
              icon: Icons.arrow_downward_rounded,
              isSelected: _isIncome,
              color: AppTheme.incomeColor,
              onTap: () => setState(() => _isIncome = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : AppTheme.textSecondary,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.amount,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: '0.00',
            prefixText: 'د.ل ',
            prefixStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.incomeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.amountRequired;
            }
            if (double.tryParse(value) == null) {
              return l10n.invalidAmount;
            }
            if (double.parse(value) <= 0) {
              return l10n.invalidAmount;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.description,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppTheme.textPrimary),
          decoration: InputDecoration(hintText: l10n.enterDescription),
          maxLength: 100,
        ),
      ],
    );
  }

  Widget _buildCategoryPicker() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.category,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: TransactionCategories.categories.length,
            itemBuilder: (context, index) {
              final category = TransactionCategories.categories[index];
              final isSelected = _selectedCategoryIndex == index;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildCategoryItem(
                  category: category,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedCategoryIndex = index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem({
    required TransactionCategory category,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected
          ? category.color.withValues(alpha: 0.2)
          : AppTheme.cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 80,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? category.color : AppTheme.cardColor,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category.icon,
                color: isSelected ? category.color : AppTheme.textSecondary,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                category.getLocalizedName(context),
                style: TextStyle(
                  color: isSelected ? category.color : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isLoading) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.incomeColor,
          disabledBackgroundColor: AppTheme.incomeColor.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.save,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

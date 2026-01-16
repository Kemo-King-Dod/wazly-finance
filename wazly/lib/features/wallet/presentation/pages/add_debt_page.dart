import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/account_entity.dart';
import '../blocs/wallet_bloc.dart';
import '../blocs/wallet_event.dart';
import '../blocs/wallet_state.dart';

enum DebtType { theyOweMe, iOweThem, settlement }

/// Professional page for adding debts and settlements
class AddDebtPage extends StatefulWidget {
  const AddDebtPage({super.key});

  @override
  State<AddDebtPage> createState() => _AddDebtPageState();
}

class _AddDebtPageState extends State<AddDebtPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();

  AccountEntity? _selectedAccount;
  DebtType _debtType = DebtType.theyOweMe;
  DateTime? _dueDate;
  bool _hasNotification = false;
  List<AccountEntity> _allAccounts = [];
  List<AccountEntity> _filteredAccounts = [];
  bool _showAccountSearch = false;

  @override
  void initState() {
    super.initState();
    // Fetch accounts after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletBloc>().add(const FetchAccounts());
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterAccounts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAccounts = _allAccounts;
      } else {
        _filteredAccounts = _allAccounts
            .where(
              (account) =>
                  account.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (_selectedAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.selectAccount),
            backgroundColor: AppTheme.debtColor,
          ),
        );
        return;
      }

      final amount = double.parse(_amountController.text);
      final notes = _notesController.text.trim();

      // Determine if it's income or expense based on debt type
      bool isIncome;
      if (_debtType == DebtType.theyOweMe) {
        isIncome = false; // Expense: money going out (lending)
      } else if (_debtType == DebtType.iOweThem) {
        isIncome = true; // Income: money coming in (borrowing)
      } else {
        isIncome = false; // Settlement
      }

      final transaction = TransactionEntity(
        id: const Uuid().v4(),
        amount: amount,
        category: 'Debt',
        date: DateTime.now(),
        description: notes.isEmpty ? 'Debt transaction' : notes,
        isIncome: isIncome,
        isDebt: true,
        accountId: 'default',
        linkedAccountId: _selectedAccount!.id,
        dueDate: _dueDate,
        hasNotification: _hasNotification,
        isSettled: _debtType == DebtType.settlement,
      );

      context.read<WalletBloc>().add(AddTransactionEvent(transaction));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state is WalletTransactionAdded) {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.debtAdded),
              backgroundColor: AppTheme.incomeColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.of(context).pop();
        } else if (state is WalletError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.debtColor,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(l10n.addDebt),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            final isLoading = state is WalletAddingTransaction;

            // Load accounts from state
            if (state is WalletAccountsLoaded && _allAccounts.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _allAccounts = state.accounts;
                    _filteredAccounts = state.accounts;
                  });
                }
              });
            }

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Account Selection
                  _buildAccountSelector(l10n),
                  const SizedBox(height: 24),

                  // Debt Type Selector
                  _buildDebtTypeSelector(l10n),
                  const SizedBox(height: 24),

                  // Amount Input
                  _buildAmountInput(l10n),
                  const SizedBox(height: 24),

                  // Due Date Picker
                  _buildDueDatePicker(l10n),
                  const SizedBox(height: 24),

                  // Notification Toggle
                  _buildNotificationToggle(l10n),
                  const SizedBox(height: 24),

                  // Notes Input
                  _buildNotesInput(l10n),
                  const SizedBox(height: 32),

                  // Save Button
                  _buildSaveButton(l10n, isLoading),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAccountSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectAccount,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            setState(() {
              _showAccountSearch = !_showAccountSearch;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _selectedAccount != null
                    ? AppTheme.incomeColor.withValues(alpha: 0.3)
                    : AppTheme.textSecondary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _selectedAccount != null ? Icons.person : Icons.search,
                  color: _selectedAccount != null
                      ? AppTheme.incomeColor
                      : AppTheme.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedAccount?.name ?? l10n.searchAccounts,
                    style: TextStyle(
                      color: _selectedAccount != null
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  _showAccountSearch
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (_showAccountSearch) ...[
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.textSecondary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.search,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: _filterAccounts,
                  ),
                ),
                Flexible(
                  child: _filteredAccounts.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            l10n.noAccounts,
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredAccounts.length,
                          itemBuilder: (context, index) {
                            final account = _filteredAccounts[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.incomeColor
                                    .withValues(alpha: 0.15),
                                child: const Icon(
                                  Icons.person,
                                  color: AppTheme.incomeColor,
                                ),
                              ),
                              title: Text(account.name),
                              onTap: () {
                                setState(() {
                                  _selectedAccount = account;
                                  _showAccountSearch = false;
                                  _searchController.clear();
                                });
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDebtTypeSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.debtType,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDebtTypeOption(
                label: l10n.theyOweMe,
                icon: Icons.arrow_upward_rounded,
                type: DebtType.theyOweMe,
                color: AppTheme.incomeColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDebtTypeOption(
                label: l10n.iOweThem,
                icon: Icons.arrow_downward_rounded,
                type: DebtType.iOweThem,
                color: AppTheme.debtColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDebtTypeOption(
                label: l10n.settlement,
                icon: Icons.check_circle_rounded,
                type: DebtType.settlement,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDebtTypeOption({
    required String label,
    required IconData icon,
    required DebtType type,
    required Color color,
  }) {
    final isSelected = _debtType == type;
    return Material(
      color: isSelected ? color.withValues(alpha: 0.15) : AppTheme.cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => setState(() => _debtType = type),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? color
                  : AppTheme.textSecondary.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : AppTheme.textSecondary,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput(AppLocalizations l10n) {
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
            if (double.tryParse(value) == null || double.parse(value) <= 0) {
              return l10n.invalidAmount;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDueDatePicker(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dueDate,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate:
                  _dueDate ?? DateTime.now().add(const Duration(days: 7)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() => _dueDate = date);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _dueDate != null
                    ? AppTheme.incomeColor.withValues(alpha: 0.3)
                    : AppTheme.textSecondary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: _dueDate != null
                      ? AppTheme.incomeColor
                      : AppTheme.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  _dueDate != null
                      ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                      : l10n.selectCategory,
                  style: TextStyle(
                    color: _dueDate != null
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationToggle(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_rounded,
            color: _hasNotification
                ? AppTheme.incomeColor
                : AppTheme.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.remindMe,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.textPrimary),
            ),
          ),
          Switch(
            value: _hasNotification,
            onChanged: (value) => setState(() => _hasNotification = value),
            activeColor: AppTheme.incomeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesInput(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.notes,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(hintText: l10n.enterNotes),
        ),
      ],
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n, bool isLoading) {
    return SizedBox(
      width: double.infinity,
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
                    l10n.save,
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

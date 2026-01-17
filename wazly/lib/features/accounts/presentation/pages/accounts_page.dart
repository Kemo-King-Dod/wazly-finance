import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../blocs/account_bloc.dart';
import '../blocs/account_event.dart';
import '../blocs/account_state.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/entities/account_filter.dart';
import '../../domain/usecases/get_account_balance_usecase.dart';
import '../../../shared/presentation/widgets/wazly_drawer_premium.dart';
import '../widgets/debt_statistics_card.dart';
import '../../domain/entities/account_sort.dart';
import 'package:intl/intl.dart';
import '../../../shared/presentation/widgets/wazly_navigation_rail.dart';
import '../../../settings/presentation/blocs/settings_bloc.dart';
import '../../../settings/presentation/blocs/settings_state.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

/// Accounts & Debts page showing all people/contacts
class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final _balanceCalculator = sl<GetAccountBalanceUseCase>();

  @override
  void initState() {
    super.initState();
    // Fetch accounts data when page loads
    context.read<AccountBloc>().add(const FetchAccounts());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(l10n.accounts),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const WazlyDrawerPremium(currentRoute: '/accounts'),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton.extended(
          onPressed: () => _showAddAccountDialog(context, l10n),
          backgroundColor: AppTheme.incomeColor,
          icon: const Icon(Icons.person_add_rounded),
          label: Text(l10n.addFirstAccount),
        ),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          return Row(
            children: [
              if (settingsState.isNavigationRailEnabled)
                WazlyNavigationRail(
                  currentRoute: '/accounts',
                  onNavigate: (route) {
                    if (route != '/accounts') {
                      Navigator.pushReplacementNamed(context, route);
                    }
                  },
                ),
              Expanded(
                child: BlocConsumer<AccountBloc, AccountState>(
                  buildWhen: (previous, current) =>
                      current is AccountAccountsLoading ||
                      current is AccountAccountsLoaded ||
                      current is AccountError,
                  listener: (context, state) {
                    if (state is AccountAccountAdded) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.accountAdded),
                          backgroundColor: AppTheme.incomeColor,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else if (state is AccountError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppTheme.debtColor,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is AccountAccountsLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.incomeColor,
                        ),
                      );
                    }

                    if (state is AccountAccountsLoaded) {
                      // Only show empty state if there are NO accounts at all
                      if (state.allAccounts.isEmpty) {
                        return _buildEmptyState(l10n, context);
                      }
                      // Show accounts list with statistics (even if filtered list is empty)
                      return _buildAccountsList(
                        state.accounts,
                        l10n,
                        debtAssets: state.debtAssets,
                        debtLiabilities: state.debtLiabilities,
                        hasNoFilterResults:
                            state.accounts.isEmpty &&
                            state.allAccounts.isNotEmpty,
                      );
                    }

                    if (state is AccountError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppTheme.debtColor,
                            ),
                            const SizedBox(height: 16),
                            Text(state.message),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.read<AccountBloc>().add(
                                const FetchAccounts(),
                              ),
                              child: Text(l10n.retry),
                            ),
                          ],
                        ),
                      );
                    }

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: AppTheme.incomeColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.initializingAccounts,
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 80,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noAccounts,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noData,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showAddAccountDialog(context, l10n),
            icon: const Icon(Icons.person_add_rounded),
            label: Text(l10n.addFirstAccount),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.incomeColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsList(
    List<AccountEntity> accounts,
    AppLocalizations l10n, {
    required double debtAssets,
    required double debtLiabilities,
    bool hasNoFilterResults = false,
  }) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: accounts.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DebtStatisticsCard(
                debtAssets: debtAssets,
                debtLiabilities: debtLiabilities,
                activeDebtsCount: accounts.length,
                upcomingDueDates: 0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: TextField(
                  onChanged: (query) {
                    final currentState = context.read<AccountBloc>().state;
                    final currentFilter = currentState is AccountAccountsLoaded
                        ? currentState.filter
                        : AccountFilter.all;
                    final currentSort = currentState is AccountAccountsLoaded
                        ? currentState.currentSort
                        : AccountSort.recent;
                    context.read<AccountBloc>().add(
                      SearchAccounts(
                        query: query,
                        filter: currentFilter,
                        sortType: currentSort,
                      ),
                    );
                  },
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: l10n.searchAccounts,
                    hintStyle: TextStyle(
                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppTheme.incomeColor,
                    ),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Row(
                  children: AccountFilter.values.map((filter) {
                    final isSelected =
                        (context.watch<AccountBloc>().state
                            is AccountAccountsLoaded)
                        ? (context.watch<AccountBloc>().state
                                      as AccountAccountsLoaded)
                                  .filter ==
                              filter
                        : filter == AccountFilter.all;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_getFilterLabel(filter, l10n)),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            final currentState = context
                                .read<AccountBloc>()
                                .state;
                            final query = currentState is AccountAccountsLoaded
                                ? currentState.searchQuery
                                : '';
                            final sort = currentState is AccountAccountsLoaded
                                ? currentState.currentSort
                                : AccountSort.recent;
                            context.read<AccountBloc>().add(
                              SearchAccounts(
                                query: query,
                                filter: filter,
                                sortType: sort,
                              ),
                            );
                          }
                        },
                        backgroundColor: AppTheme.cardColor,
                        selectedColor: AppTheme.incomeColor.withValues(
                          alpha: 0.2,
                        ),
                        checkmarkColor: AppTheme.incomeColor,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.incomeColor
                              : AppTheme.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.incomeColor
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.accounts,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PopupMenuButton<AccountSort>(
                      icon: const Icon(
                        Icons.sort_rounded,
                        color: AppTheme.incomeColor,
                      ),
                      onSelected: (sort) {
                        final currentState = context.read<AccountBloc>().state;
                        if (currentState is AccountAccountsLoaded) {
                          context.read<AccountBloc>().add(
                            SearchAccounts(
                              query: currentState.searchQuery,
                              filter: currentState.filter,
                              sortType: sort,
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: AccountSort.name,
                          child: Text(l10n.sortByName),
                        ),
                        PopupMenuItem(
                          value: AccountSort.balance,
                          child: Text(l10n.sortByBalance),
                        ),
                        PopupMenuItem(
                          value: AccountSort.recent,
                          child: Text(l10n.sortByRecent),
                        ),
                        PopupMenuItem(
                          value: AccountSort.dueDate,
                          child: Text(l10n.sortByDueDate),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        // Show message if no accounts match the filter
        if (hasNoFilterResults && index == 1) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.filter_list_off_rounded,
                    size: 64,
                    color: AppTheme.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noAccountsMatchFilter,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tryDifferentFilter,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final account = accounts[index - 1];
        return FutureBuilder<AccountBalance>(
          future: _calculateBalance(account.id),
          builder: (context, snapshot) {
            final balance = snapshot.data;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildAccountCard(
                context,
                account,
                l10n,
                debtAssets: balance?.debtAssets ?? 0,
                debtLiabilities: balance?.debtLiabilities ?? 0,
                nextDueDate: balance?.nextDueDate,
              ),
            );
          },
        );
      },
    );
  }

  Future<AccountBalance> _calculateBalance(String accountId) async {
    final result = await _balanceCalculator(
      AccountBalanceParams(accountId: accountId),
    );
    return result.fold(
      (_) => const AccountBalance(debtAssets: 0, debtLiabilities: 0),
      (balance) => balance,
    );
  }

  Widget _buildAccountCard(
    BuildContext context,
    AccountEntity account,
    AppLocalizations l10n, {
    required double debtAssets,
    required double debtLiabilities,
    DateTime? nextDueDate,
  }) {
    final netBalance = debtAssets - debtLiabilities;
    final hasDebt = debtAssets > 0 || debtLiabilities > 0;
    final isOverdue =
        nextDueDate != null && nextDueDate.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            // TODO: Navigate to account details
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                (netBalance >= 0
                                        ? AppTheme.incomeColor
                                        : AppTheme.debtColor)
                                    .withValues(alpha: 0.8),
                                (netBalance >= 0
                                        ? AppTheme.incomeColor
                                        : AppTheme.debtColor)
                                    .withValues(alpha: 0.4),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              account.name.isNotEmpty
                                  ? account.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (hasDebt)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.cardColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.cardColor,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                netBalance >= 0
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                color: netBalance >= 0
                                    ? AppTheme.incomeColor
                                    : AppTheme.debtColor,
                                size: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.name,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (account.phone.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              account.phone,
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        if (account.phone.isNotEmpty)
                          _buildSmallAction(
                            icon: Icons.call_rounded,
                            color: AppTheme.incomeColor,
                            onPressed: () {},
                          ),
                        const SizedBox(width: 8),
                        _buildSmallAction(
                          icon: Icons.more_vert_rounded,
                          color: AppTheme.textSecondary,
                          onPressed: () =>
                              _showAccountOptions(context, account, l10n),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _buildBalanceItem(
                        l10n.debtAssets,
                        debtAssets,
                        AppTheme.incomeColor,
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: AppTheme.textSecondary.withValues(alpha: 0.1),
                      ),
                      _buildBalanceItem(
                        l10n.debtLiabilities,
                        debtLiabilities,
                        AppTheme.debtColor,
                      ),
                    ],
                  ),
                ),
                if (nextDueDate != null && !isOverdue) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.event_note_rounded,
                        size: 14,
                        color: AppTheme.incomeColor.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${l10n.dueDate}: ${DateFormat('yyyy-MM-dd').format(nextDueDate)}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
                if (isOverdue) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.debtColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: AppTheme.debtColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.overdue,
                          style: const TextStyle(
                            color: AppTheme.debtColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('yyyy-MM-dd').format(nextDueDate),
                          style: TextStyle(
                            color: AppTheme.debtColor.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String label, double amount, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'د.ل ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallAction({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 18),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
      ),
    );
  }

  String _getFilterLabel(AccountFilter filter, AppLocalizations l10n) {
    switch (filter) {
      case AccountFilter.all:
        return l10n.filterAll;
      case AccountFilter.owedToMe:
        return l10n.filterOwedToMe;
      case AccountFilter.iOwe:
        return l10n.filterIOwe;
      case AccountFilter.settled:
        return l10n.filterSettled;
    }
  }

  void _showAccountOptions(
    BuildContext context,
    AccountEntity account,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(
              Icons.edit_rounded,
              color: AppTheme.incomeColor,
            ),
            title: Text(l10n.editAccount),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.delete_rounded,
              color: AppTheme.debtColor,
            ),
            title: Text(l10n.deleteAccount),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, account, l10n);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    AccountEntity account,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AccountBloc>().add(DeleteAccountEvent(account.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.debtColor,
            ),
            child: Text(
              l10n.delete,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context, AppLocalizations l10n) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final bloc = context.read<AccountBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Add Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone (Optional)',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final contact = await _pickContact();
                    if (contact != null) {
                      nameController.text = contact['name'] ?? '';
                      phoneController.text = contact['phone'] ?? '';
                    }
                  },
                  icon: const Icon(Icons.contacts_rounded),
                  label: const Text('Pick from Contacts'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: AppTheme.incomeColor.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    foregroundColor: AppTheme.incomeColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                bloc.add(
                  AddAccountEvent(
                    AccountEntity(
                      id: const Uuid().v4(),
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                    ),
                  ),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<Map<String, String>?> _pickContact() async {
    try {
      // Request permission
      final permissionStatus = await Permission.contacts.request();

      if (!permissionStatus.isGranted) {
        return null;
      }

      // Pick a contact
      final contact = await FlutterContacts.openExternalPick();

      if (contact == null) {
        return null;
      }

      // Fetch full contact details including phone numbers
      final fullContact = await FlutterContacts.getContact(contact.id);

      if (fullContact == null) {
        return null;
      }

      // Extract name and phone
      final name = fullContact.displayName;
      final phone = fullContact.phones.isNotEmpty
          ? fullContact.phones.first.number
          : '';

      return {'name': name, 'phone': phone};
    } catch (e) {
      // Handle any errors silently
      return null;
    }
  }
}

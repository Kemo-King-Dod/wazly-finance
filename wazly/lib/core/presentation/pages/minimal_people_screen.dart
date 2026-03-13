import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:wazly/core/presentation/bloc/people/people_bloc.dart';
import 'package:wazly/core/presentation/bloc/person_details/person_details_bloc.dart';
import 'package:wazly/core/presentation/pages/minimal_person_details_screen.dart';
import 'package:wazly/core/presentation/pages/add_debt_payment_screen.dart';
import 'package:wazly/core/theme/app_theme.dart';
import 'package:get_it/get_it.dart';
import 'package:wazly/core/presentation/widgets/empty_state_view.dart';
import 'package:wazly/l10n/app_localizations.dart';
import 'package:wazly/core/domain/usecases/add_person.dart' as usecase;

class MinimalPeopleScreen extends StatefulWidget {
  MinimalPeopleScreen({super.key});

  @override
  State<MinimalPeopleScreen> createState() => _MinimalPeopleScreenState();
}

class _MinimalPeopleScreenState extends State<MinimalPeopleScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final state = context.read<PeopleBloc>().state;
    _searchController = TextEditingController(
      text: state is PeopleLoaded ? state.searchQuery : '',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _importFromContacts() async {
    // Request permission
    final hasPermission = await FlutterContacts.requestPermission();
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.contactPermissionDenied),
          backgroundColor: AppTheme.debtColor,
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.settingsButton,
            textColor: Colors.white,
            onPressed: () => FlutterContacts.openExternalPick(),
          ),
        ),
      );
      return;
    }

    // Open system contact picker
    final contact = await FlutterContacts.openExternalPick();
    if (contact == null || !mounted) return;

    // Fetch full contact to get phone numbers
    final fullContact = await FlutterContacts.getContact(
      contact.id,
      withProperties: true,
    );
    if (fullContact == null || !mounted) return;

    final displayName = fullContact.displayName.isNotEmpty
        ? fullContact.displayName
        : '${fullContact.name.first} ${fullContact.name.last}'.trim();

    if (displayName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.contactHasNoName),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    final phone = fullContact.phones.isNotEmpty
        ? fullContact.phones.first.number
        : null;

    // Create Person
    final addPersonUseCase = GetIt.instance<usecase.AddPerson>();
    final result = await addPersonUseCase.call(
      usecase.AddPersonParams(name: displayName, phoneNumber: phone),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToAddContact),
            backgroundColor: AppTheme.debtColor,
          ),
        );
      },
      (person) {
        context.read<PeopleBloc>().add(LoadPeople());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.personAddedSuccess(person.name)),
            backgroundColor: AppTheme.incomeColor,
          ),
        );
      },
    );
  }

  void _showAddPersonDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        title: Text(
          AppLocalizations.of(context)!.addNewPerson,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.name,
                filled: true,
                fillColor: AppTheme.lightSurfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              autofocus: true,
            ),
            SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.phoneText,
                filled: true,
                fillColor: AppTheme.lightSurfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final addPersonUseCase = GetIt.instance<usecase.AddPerson>();
              await addPersonUseCase.call(
                usecase.AddPersonParams(
                  name: name,
                  phoneNumber: phoneController.text.trim().isEmpty
                      ? null
                      : phoneController.text.trim(),
                ),
              );
              if (context.mounted) {
                context.read<PeopleBloc>().add(LoadPeople());
              }
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: Text(AppLocalizations.of(context)!.add),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: BlocBuilder<PeopleBloc, PeopleState>(
        builder: (context, state) {
          if (state is PeopleLoading || state is PeopleInitial) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
            );
          }

          if (state is PeopleError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FluentIcons.error_circle_24_regular,
                      size: 48, color: AppTheme.debtColor),
                  SizedBox(height: 12),
                  Text(AppLocalizations.of(context)!.errorPrefix(state.message),
                      style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            );
          }

          if (state is PeopleLoaded) {
            final people = state.filteredList;
            final totalOwedToYou = people.fold<int>(
              0,
              (sum, pb) =>
                  pb.netBalanceInCents > 0 ? sum + pb.netBalanceInCents : sum,
            );
            final totalYouOwe = people.fold<int>(
              0,
              (sum, pb) => pb.netBalanceInCents < 0
                  ? sum + pb.netBalanceInCents.abs()
                  : sum,
            );

            return CustomScrollView(
              slivers: [
                // ═══════════ HEADER ═══════════
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 60, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              AppLocalizations.of(context)!.peopleTitle,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              AppLocalizations.of(context)!.trackDebtsAndPayments,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: _showAddPersonDialog,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              FluentIcons.person_add_24_regular,
                              color: Theme.of(context).primaryColor,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ═══════════ SUMMARY CARDS ═══════════
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.incomeColor.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                              border: Border.all(
                                color: AppTheme.incomeColor.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: AppTheme.incomeColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(FluentIcons.arrow_down_24_regular,
                                          color: AppTheme.incomeColor, size: 16),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      AppLocalizations.of(context)!.owedToYouCard,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  '${(totalOwedToYou / 100).toStringAsFixed(0)} LYD',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.incomeColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.debtColor.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                              border: Border.all(
                                color: AppTheme.debtColor.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: AppTheme.debtColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(FluentIcons.arrow_up_24_regular,
                                          color: AppTheme.debtColor, size: 16),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      AppLocalizations.of(context)!.youOweCard,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  '${(totalYouOwe / 100).toStringAsFixed(0)} LYD',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.debtColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ═══════════ QUICK ACTIONS ═══════════
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            icon: FluentIcons.contact_card_24_regular,
                            label: AppLocalizations.of(context)!.importContacts,
                            onTap: _importFromContacts,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _QuickActionButton(
                            icon: FluentIcons.person_add_24_regular,
                            label: AppLocalizations.of(context)!.addNewPerson,
                            onTap: _showAddPersonDialog,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ═══════════ SEARCH ═══════════
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.searchPeople,
                          hintStyle: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(FluentIcons.search_24_regular,
                              color: AppTheme.textSecondary, size: 22),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onChanged: (value) {
                          context.read<PeopleBloc>().add(SearchPeople(value));
                        },
                      ),
                    ),
                  ),
                ),

                // ═══════════ PEOPLE COUNT ═══════════
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
                    child: Text(
                      AppLocalizations.of(context)!.peopleCountPlaceholder(people.length, people.length == 1 ? AppLocalizations.of(context)!.personEntity : AppLocalizations.of(context)!.peopleEntity),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),

                // ═══════════ PEOPLE LIST ═══════════
                if (people.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: EmptyStateView(
                        icon: Icon(FluentIcons.people_24_regular),
                        title: AppLocalizations.of(context)!.emptyPeopleTitle,
                        subtitle: AppLocalizations.of(context)!.emptyPeopleSubtitle,
                        actionLabel: AppLocalizations.of(context)!.addNewPerson,
                        onAction: _showAddPersonDialog,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final pb = people[index];
                          final person = pb.person;
                          final netBalance = pb.netBalanceInCents;

                          final amountColor = netBalance > 0
                              ? AppTheme.incomeColor
                              : (netBalance < 0
                                  ? AppTheme.debtColor
                                  : AppTheme.textSecondary);
                          final prefix = netBalance > 0 ? '+' : '';
                          final statusText = netBalance > 0
                              ? AppLocalizations.of(context)!.owesYou
                              : (netBalance < 0 ? AppLocalizations.of(context)!.youOwe : AppLocalizations.of(context)!.settled);

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BlocProvider<PersonDetailsBloc>(
                                    create: (context) =>
                                        GetIt.instance<PersonDetailsBloc>()
                                          ..add(LoadPersonDetails(person.id)),
                                    child: MinimalPersonDetailsScreen(
                                      personId: person.id,
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 10),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceCard,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.cardRadius),
                                border: Border.all(
                                    color: AppTheme.borderLight, width: 1),
                              ),
                              child: Column(
                                children: [
                                  // Top row: avatar + name + balance
                                  Row(
                                    children: [
                                      // Avatar
                                      Container(
                                        width: 46,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor
                                              .withValues(alpha: 0.08),
                                          borderRadius:
                                              BorderRadius.circular(13),
                                        ),
                                        child: Center(
                                          child: Text(
                                            person.name.isNotEmpty
                                                ? person.name[0].toUpperCase()
                                                : '?',
                                            style: TextStyle(
                                              color: Theme.of(context).primaryColor,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 14),
                                      // Name + status badge
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              person.name,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: amountColor
                                                    .withValues(alpha: 0.08),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                statusText,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: amountColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Balance amount
                                      Text(
                                        '$prefix${(netBalance / 100).toStringAsFixed(2)} LYD',
                                        style: TextStyle(
                                          color: amountColor,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  // Action buttons row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _PersonActionButton(
                                          icon: FluentIcons
                                              .wallet_24_regular,
                                          label: AppLocalizations.of(context)!.addDebt,
                                          color: AppTheme.debtColor,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddDebtPaymentScreen(
                                                  person: person,
                                                  initialMode:
                                                      DebtPaymentMode.debt,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: _PersonActionButton(
                                          icon: FluentIcons.payment_24_regular,
                                          label: AppLocalizations.of(context)!.addPayment,
                                          color: AppTheme.incomeColor,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddDebtPaymentScreen(
                                                  person: person,
                                                  initialMode:
                                                      DebtPaymentMode.payment,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: people.length,
                      ),
                    ),
                  ),
              ],
            );
          }

          return SizedBox();
        },
      ),
    );
  }
}

// ─── Quick Action Button ───
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 18),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Person Action Button (Debt / Payment) ───
class _PersonActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _PersonActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

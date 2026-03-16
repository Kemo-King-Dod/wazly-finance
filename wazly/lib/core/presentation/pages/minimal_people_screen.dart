import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:wazly/core/presentation/bloc/settings/settings_cubit.dart';
import 'package:wazly/core/presentation/bloc/people/people_bloc.dart';
import 'package:wazly/core/presentation/bloc/person_details/person_details_bloc.dart';
import 'package:wazly/core/presentation/pages/minimal_person_details_screen.dart';
import 'package:wazly/core/presentation/pages/add_debt_payment_screen.dart';
import 'package:wazly/core/theme/app_theme.dart';
import 'package:get_it/get_it.dart';
import 'package:wazly/core/presentation/widgets/empty_state_view.dart';
import 'package:wazly/core/utils/app_formatters.dart';
import 'package:wazly/core/presentation/widgets/coach_mark_overlay.dart';
import 'package:wazly/l10n/app_localizations.dart';
import 'package:wazly/core/domain/usecases/add_person.dart' as usecase;
import 'package:wazly/core/domain/entities/person_with_balance.dart';

enum _PeopleFilter { all, owesMe, iOwe, settled }

enum _PeopleSort { highestBalance, recentActivity, alphabetical }

class MinimalPeopleScreen extends StatefulWidget {
  MinimalPeopleScreen({super.key});

  @override
  State<MinimalPeopleScreen> createState() => _MinimalPeopleScreenState();
}

class _MinimalPeopleScreenState extends State<MinimalPeopleScreen> {
  late final TextEditingController _searchController;
  final GlobalKey _addPersonKey = GlobalKey();
  bool _dataReady = false;

  _PeopleFilter _filter = _PeopleFilter.all;
  _PeopleSort _sort = _PeopleSort.highestBalance;

  @override
  void initState() {
    super.initState();
    final state = context.read<PeopleBloc>().state;
    _searchController = TextEditingController(
      text: state is PeopleLoaded ? state.searchQuery : '',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_dataReady) _tryShowCoachMarks();
  }

  void _tryShowCoachMarks() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l = AppLocalizations.of(context)!;
      maybeShowCoachMarks(
        context: context,
        tourId: 'people',
        requiredTabIndex: 1,
        steps: [
          CoachMarkStep(
            targetKey: _addPersonKey,
            text: l.hintAddPerson,
            icon: FluentIcons.person_add_24_regular,
          ),
        ],
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PersonWithBalance> _applyFilterAndSort(List<PersonWithBalance> people) {
    var result = List<PersonWithBalance>.from(people);

    switch (_filter) {
      case _PeopleFilter.all:
        break;
      case _PeopleFilter.owesMe:
        result = result.where((p) => p.netBalanceInCents > 0).toList();
        break;
      case _PeopleFilter.iOwe:
        result = result.where((p) => p.netBalanceInCents < 0).toList();
        break;
      case _PeopleFilter.settled:
        result = result.where((p) => p.netBalanceInCents == 0).toList();
        break;
    }

    switch (_sort) {
      case _PeopleSort.highestBalance:
        result.sort(
            (a, b) => b.netBalanceInCents.abs().compareTo(a.netBalanceInCents.abs()));
        break;
      case _PeopleSort.recentActivity:
        result.sort((a, b) => b.person.updatedAt.compareTo(a.person.updatedAt));
        break;
      case _PeopleSort.alphabetical:
        result.sort((a, b) =>
            a.person.name.toLowerCase().compareTo(b.person.name.toLowerCase()));
        break;
    }

    return result;
  }

  Future<void> _importFromContacts() async {
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

    final contact = await FlutterContacts.openExternalPick();
    if (contact == null || !mounted) return;

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
            content: Text(
                AppLocalizations.of(context)!.personAddedSuccess(person.name)),
            backgroundColor: AppTheme.incomeColor,
          ),
        );
      },
    );
  }

  void _showAddPersonDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final l = AppLocalizations.of(context)!;
    final parentContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        title: Text(
          l.addNewPerson,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: l.name,
                  filled: true,
                  fillColor: AppTheme.lightSurfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: l.phoneText,
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l.cancel),
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
              if (parentContext.mounted) {
                parentContext.read<PeopleBloc>().add(LoadPeople());
              }
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: Text(l.add),
          ),
        ],
      ),
    );
  }

  void _showSortSheet() {
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
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
              const SizedBox(height: 16),
              _SortOption(
                label: l.sortHighestBalance,
                icon: FluentIcons.arrow_sort_down_24_regular,
                isSelected: _sort == _PeopleSort.highestBalance,
                onTap: () {
                  setState(() => _sort = _PeopleSort.highestBalance);
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                label: l.sortRecentActivity,
                icon: FluentIcons.clock_24_regular,
                isSelected: _sort == _PeopleSort.recentActivity,
                onTap: () {
                  setState(() => _sort = _PeopleSort.recentActivity);
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                label: l.sortAlphabetical,
                icon: FluentIcons.text_sort_ascending_24_regular,
                isSelected: _sort == _PeopleSort.alphabetical,
                onTap: () {
                  setState(() => _sort = _PeopleSort.alphabetical);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
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
      body: BlocBuilder<PeopleBloc, PeopleState>(
        builder: (context, state) {
          if (state is PeopleLoading || state is PeopleInitial) {
            return Center(
              child: CircularProgressIndicator(color: primary),
            );
          }

          if (state is PeopleError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FluentIcons.error_circle_24_regular,
                      size: 48, color: AppTheme.debtColor),
                  const SizedBox(height: 12),
                  Text(l.errorPrefix(state.message),
                      style: const TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            );
          }

          if (state is PeopleLoaded) {
            if (!_dataReady) {
              _dataReady = true;
              _tryShowCoachMarks();
            }

            final rawPeople = state.filteredList;
            final people = _applyFilterAndSort(rawPeople);

            final totalOwedToYou = state.fullList.fold<int>(
              0,
              (sum, pb) =>
                  pb.netBalanceInCents > 0 ? sum + pb.netBalanceInCents : sum,
            );
            final totalYouOwe = state.fullList.fold<int>(
              0,
              (sum, pb) => pb.netBalanceInCents < 0
                  ? sum + pb.netBalanceInCents.abs()
                  : sum,
            );

            final filterLabels = {
              _PeopleFilter.all: l.filterAll,
              _PeopleFilter.owesMe: l.filterOwesMe,
              _PeopleFilter.iOwe: l.filterIOwe,
              _PeopleFilter.settled: l.filterSettled,
            };

            return CustomScrollView(
              slivers: [
                // ═══════════ HEADER ═══════════
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.peopleTitle,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l.trackDebtsAndPayments,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _importFromContacts,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceCard,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: AppTheme.borderLight),
                                ),
                                child: Icon(
                                  FluentIcons.contact_card_24_regular,
                                  color: AppTheme.textSecondary,
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: _showAddPersonDialog,
                              child: Container(
                                key: _addPersonKey,
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  FluentIcons.person_add_24_regular,
                                  color: primary,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ═══════════ SUMMARY CARDS ═══════════
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.incomeColor.withValues(alpha: 0.06),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.cardRadius),
                              border: Border.all(
                                color: AppTheme.incomeColor
                                    .withValues(alpha: 0.15),
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
                                        color: AppTheme.incomeColor
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                          FluentIcons.arrow_down_24_regular,
                                          color: AppTheme.incomeColor,
                                          size: 16),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l.owedToYouCard,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${AppFormatters.formatAmount(totalOwedToYou / 100).split('.').first} ${context.watch<SettingsCubit>().state.currencyCode}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.incomeColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.debtColor.withValues(alpha: 0.06),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.cardRadius),
                              border: Border.all(
                                color:
                                    AppTheme.debtColor.withValues(alpha: 0.15),
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
                                        color: AppTheme.debtColor
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                          FluentIcons.arrow_up_24_regular,
                                          color: AppTheme.debtColor,
                                          size: 16),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l.youOweCard,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${AppFormatters.formatAmount(totalYouOwe / 100).split('.').first} ${context.watch<SettingsCubit>().state.currencyCode}',
                                  style: const TextStyle(
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

                // ═══════════ SEARCH + SORT ═══════════
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.borderLight),
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: l.searchPeople,
                                hintStyle: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                                prefixIcon: const Icon(
                                    FluentIcons.search_24_regular,
                                    color: AppTheme.textSecondary,
                                    size: 22),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onChanged: (value) {
                                context
                                    .read<PeopleBloc>()
                                    .add(SearchPeople(value));
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _showSortSheet,
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.borderLight),
                            ),
                            child: const Icon(
                                FluentIcons.arrow_sort_24_regular,
                                color: AppTheme.textSecondary,
                                size: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ═══════════ FILTER CHIPS ═══════════
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 46,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      children: _PeopleFilter.values.map((f) {
                        final isActive = _filter == f;
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _filter = f),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? primary.withValues(alpha: 0.1)
                                    : AppTheme.surfaceCard,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isActive
                                      ? primary.withValues(alpha: 0.4)
                                      : AppTheme.borderLight,
                                ),
                              ),
                              child: Text(
                                filterLabels[f]!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight:
                                      isActive ? FontWeight.w700 : FontWeight.w500,
                                  color: isActive
                                      ? primary
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // ═══════════ PEOPLE COUNT ═══════════
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                    child: Text(
                      l.peopleCountPlaceholder(
                          people.length,
                          people.length == 1
                              ? l.personEntity
                              : l.peopleEntity),
                      style: const TextStyle(
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
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: EmptyStateView(
                        icon: const Icon(FluentIcons.people_24_regular),
                        title: l.emptyPeopleTitle,
                        subtitle: l.emptyPeopleSubtitle,
                        actionLabel: l.addNewPerson,
                        onAction: _showAddPersonDialog,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
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
                              ? l.owesYou
                              : (netBalance < 0
                                  ? l.youOwe
                                  : l.settled);

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
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceCard,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.cardRadius),
                                border: Border.all(
                                    color: AppTheme.borderLight, width: 1),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 46,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          color: primary
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
                                              color: primary,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              person.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                      Text(
                                        '$prefix${AppFormatters.formatAmountInCents(netBalance.abs())} ${context.watch<SettingsCubit>().state.currencyCode}',
                                        style: TextStyle(
                                          color: amountColor,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _PersonActionButton(
                                          icon:
                                              FluentIcons.wallet_24_regular,
                                          label: l.addDebt,
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
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _PersonActionButton(
                                          icon: FluentIcons
                                              .payment_24_regular,
                                          label: l.addPayment,
                                          color: AppTheme.incomeColor,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddDebtPaymentScreen(
                                                  person: person,
                                                  initialMode: DebtPaymentMode
                                                      .payment,
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

          return const SizedBox();
        },
      ),
    );
  }
}

// ─── Sort Option ───
class _SortOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon,
          color: isSelected ? primary : AppTheme.textSecondary, size: 22),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? primary : AppTheme.textPrimary,
        ),
      ),
      trailing: isSelected
          ? Icon(FluentIcons.checkmark_24_filled, color: primary, size: 20)
          : null,
      onTap: onTap,
    );
  }
}

// ─── Person Action Button (Debt / Payment) ───
class _PersonActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PersonActionButton({
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
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

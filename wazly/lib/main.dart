import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wazly/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wazly/core/presentation/bloc/settings/settings_state.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:drift/native.dart';
import 'package:wazly/core/theme/app_theme.dart';

// Core & Drift DB
import 'package:wazly/core/data/local/database/app_database.dart';
import 'package:wazly/core/data/local/database/data_event_bus.dart';
import 'package:wazly/core/data/local/database/drift_unit_of_work.dart';
import 'package:wazly/core/domain/repositories/unit_of_work.dart';
import 'package:wazly/core/data/local/services/backup_restore_service.dart';
import 'package:wazly/core/services/security_service.dart';
import 'package:wazly/core/presentation/widgets/app_lock_wrapper.dart';
import 'package:wazly/core/presentation/bloc/theme/theme_cubit.dart';
import 'package:wazly/core/data/local/services/notification_service.dart';

// Security Auth
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Settings
import 'package:wazly/core/presentation/bloc/settings/settings_cubit.dart';

// Repos
import 'package:wazly/core/data/local/repositories/drift_installment_repository.dart';
import 'package:wazly/core/data/local/repositories/drift_person_repository.dart';
import 'package:wazly/core/data/local/repositories/drift_transaction_repository.dart';
import 'package:wazly/core/data/local/repositories/drift_treasury_repository.dart';
import 'package:wazly/core/data/local/repositories/drift_category_repository.dart';

// UseCases
import 'package:wazly/core/domain/usecases/add_debt.dart';
import 'package:wazly/core/domain/usecases/category_usecases.dart';
import 'package:wazly/core/domain/usecases/add_payment.dart';
import 'package:wazly/core/domain/usecases/add_person.dart';
import 'package:wazly/core/domain/usecases/affect_treasury.dart';
import 'package:wazly/core/domain/usecases/delete_person.dart';
import 'package:wazly/core/domain/usecases/delete_transaction.dart';
import 'package:wazly/core/domain/usecases/get_dashboard_summary.dart';
import 'package:wazly/core/domain/usecases/get_people_with_balances.dart';
import 'package:wazly/core/domain/usecases/get_person_by_id.dart';
import 'package:wazly/core/domain/usecases/get_person_balance.dart';
import 'package:wazly/core/domain/usecases/update_person.dart';
import 'package:wazly/core/domain/usecases/get_transactions_by_person.dart';
import 'package:wazly/core/domain/usecases/get_installment_plans_by_person.dart';
// BLoCs
import 'package:wazly/core/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:wazly/core/presentation/bloc/people/people_bloc.dart';
import 'package:wazly/core/presentation/bloc/person_action/person_action_bloc.dart';
import 'package:wazly/core/presentation/bloc/person_details/person_details_bloc.dart';
import 'package:wazly/core/presentation/bloc/transaction_action/transaction_action_bloc.dart';
import 'package:wazly/core/presentation/bloc/categories/categories_bloc.dart';

// UI
import 'package:wazly/core/presentation/pages/app_shell.dart';
import 'package:wazly/core/presentation/pages/onboarding_screen.dart';
import 'package:wazly/core/presentation/pages/locale_setup_screen.dart';

final sl = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencyInjection();

  // Initialize notifications & timezone before anything runs
  await NotificationService().init();

  final sharedPrefs = sl<SharedPreferences>();
  final hasSeenOnboarding = sharedPrefs.getBool('has_seen_onboarding') ?? false;
  final hasCompletedLocaleSetup =
      sharedPrefs.getBool('has_completed_locale_setup') ?? false;

  runApp(
    WazlyMinimalApp(
      hasSeenOnboarding: hasSeenOnboarding,
      hasCompletedLocaleSetup: hasCompletedLocaleSetup,
    ),
  );
}

Future<void> setupDependencyInjection() async {
  // Security Services
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPrefs);
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<LocalAuthentication>(() => LocalAuthentication());

  // Security
  sl.registerLazySingleton<SecurityService>(
    () => SecurityService(sl(), sl(), sl()),
  );

  // Theme & Settings
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit(sl()));
  sl.registerLazySingleton<SettingsCubit>(() => SettingsCubit(sl()));

  // Setup initial theme inside bloc constructor so it loads synchronously.

  // DB
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'wazly_db_v3.sqlite'));
  final database = AppDatabase(NativeDatabase.createInBackground(file));
  sl.registerLazySingleton<AppDatabase>(() => database);

  final eventBus = DataEventBus();
  sl.registerLazySingleton<DataEventBus>(() => eventBus);

  final unitOfWork = DriftUnitOfWork(database: sl(), eventBus: sl());
  sl.registerLazySingleton<UnitOfWork>(() => unitOfWork);

  sl.registerLazySingleton(
    () => BackupRestoreService(database: sl(), eventBus: sl()),
  );

  // Repos
  sl.registerLazySingleton(() => DriftPersonRepository(sl()));
  sl.registerLazySingleton(() => DriftTransactionRepository(sl()));
  sl.registerLazySingleton(() => DriftTreasuryRepository(sl()));
  sl.registerLazySingleton(() => DriftInstallmentRepository(sl()));
  sl.registerLazySingleton(() => DriftCategoryRepository(sl()));

  // UseCases
  sl.registerLazySingleton(() => CategoryUseCases(sl()));
  sl.registerLazySingleton(() => AddPerson(sl<DriftPersonRepository>()));
  sl.registerLazySingleton(
    () =>
        AddDebt(repository: sl<DriftTransactionRepository>(), unitOfWork: sl()),
  );
  sl.registerLazySingleton(
    () => AddPayment(
      transactionRepository: sl<DriftTransactionRepository>(),
      treasuryRepository: sl<DriftTreasuryRepository>(),
      unitOfWork: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => AffectTreasury(
      transactionRepository: sl<DriftTransactionRepository>(),
      treasuryRepository: sl<DriftTreasuryRepository>(),
      unitOfWork: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => DeleteTransaction(
      transactionRepository: sl<DriftTransactionRepository>(),
      treasuryRepository: sl<DriftTreasuryRepository>(),
      unitOfWork: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => DeletePerson(
      personRepository: sl<DriftPersonRepository>(),
      transactionRepository: sl<DriftTransactionRepository>(),
      installmentRepository: sl<DriftInstallmentRepository>(),
      treasuryRepository: sl<DriftTreasuryRepository>(),
      unitOfWork: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => GetPeopleWithBalances(sl<DriftPersonRepository>()),
  );
  sl.registerLazySingleton(() => GetPersonById(sl<DriftPersonRepository>()));
  sl.registerLazySingleton(() => UpdatePerson(sl<DriftPersonRepository>()));
  sl.registerLazySingleton(() => GetPersonBalance(sl<DriftPersonRepository>()));
  sl.registerLazySingleton(
    () => GetTransactionsByPerson(sl<DriftTransactionRepository>()),
  );
  sl.registerLazySingleton(
    () => GetInstallmentPlansByPerson(sl<DriftInstallmentRepository>()),
  );
  sl.registerLazySingleton(
    () => GetDashboardSummary(
      treasuryRepository: sl<DriftTreasuryRepository>(),
      transactionRepository: sl<DriftTransactionRepository>(),
      getPeopleWithBalances: sl(),
    ),
  );

  // Blocs
  sl.registerFactory(
    () => DashboardBloc(getDashboardSummary: sl(), dataEventBus: sl()),
  );
  sl.registerFactory(
    () => PeopleBloc(getPeopleWithBalances: sl(), dataEventBus: sl()),
  );
  sl.registerFactory(
    () => PersonDetailsBloc(
      getPersonById: sl(),
      getPersonBalance: sl(),
      getTransactionsByPerson: sl(),
      getInstallmentPlansByPerson: sl(),
      dataEventBus: sl(),
    ),
  );
  sl.registerFactory(
    () => PersonActionBloc(deletePerson: sl(), updatePerson: sl()),
  );
  sl.registerFactory(
    () => TransactionActionBloc(
      addDebt: sl(),
      addPayment: sl(),
      affectTreasury: sl(),
      deleteTransaction: sl(),
    ),
  );
  sl.registerFactory(() => CategoriesBloc(useCases: sl()));
}

class WazlyMinimalApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  final bool hasCompletedLocaleSetup;

  const WazlyMinimalApp({
    super.key,
    required this.hasSeenOnboarding,
    required this.hasCompletedLocaleSetup,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardBloc>(
          create: (context) => sl<DashboardBloc>()..add(LoadDashboard()),
        ),
        BlocProvider<PeopleBloc>(
          create: (context) => sl<PeopleBloc>()..add(const LoadPeople()),
        ),
        BlocProvider<PersonActionBloc>(
          create: (context) => sl<PersonActionBloc>(),
        ),
        BlocProvider<TransactionActionBloc>(
          create: (context) => sl<TransactionActionBloc>(),
        ),
        BlocProvider<PersonDetailsBloc>(
          create: (context) => sl<PersonDetailsBloc>(),
        ),
        BlocProvider<CategoriesBloc>(create: (context) => sl<CategoriesBloc>()),
        BlocProvider<ThemeCubit>(create: (context) => sl<ThemeCubit>()),
        BlocProvider<SettingsCubit>(create: (context) => sl<SettingsCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return MaterialApp(
                title: 'Wazly V2 Minimal',
                theme: AppTheme.getTheme(themeState.option),
                debugShowCheckedModeBanner: false,
                locale: Locale(settingsState.languageCode),
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('en', ''), Locale('ar', '')],
                builder: (context, child) {
                  return AppLockWrapper(child: child!);
                },
                home: hasCompletedLocaleSetup
                    ? (hasSeenOnboarding
                          ? const AppShell()
                          : const OnboardingScreen())
                    : LocaleSetupScreen(hasSeenOnboarding: hasSeenOnboarding),
              );
            },
          );
        },
      ),
    );
  }
}

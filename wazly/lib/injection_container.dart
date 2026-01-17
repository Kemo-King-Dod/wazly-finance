import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/transactions/data/models/transaction_model.dart';
import 'features/accounts/data/models/account_model.dart';
import 'features/transactions/data/models/audit_log_model.dart';
import 'features/transactions/data/datasources/transaction_local_datasource.dart';
import 'features/accounts/data/datasources/account_local_datasource.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/accounts/domain/repositories/account_repository.dart';
import 'features/accounts/data/repositories/account_repository_impl.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';
import 'features/wallet/domain/repositories/wallet_repository.dart';
import 'features/wallet/data/repositories/wallet_repository_impl.dart';
import 'features/transactions/domain/usecases/balance_calculator.dart';
import 'features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'features/transactions/domain/usecases/add_transaction_usecase.dart';
import 'features/transactions/domain/usecases/get_category_wise_expenses_usecase.dart';
import 'features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'features/accounts/domain/usecases/add_account_usecase.dart';
import 'features/accounts/domain/usecases/get_account_balance_usecase.dart';
import 'features/accounts/domain/usecases/delete_account_usecase.dart';
import 'features/wallet/domain/usecases/calculate_net_worth_usecase.dart';
import 'features/accounts/presentation/blocs/account_bloc.dart';
import 'features/transactions/presentation/blocs/transaction_bloc.dart';
import 'features/wallet/presentation/blocs/settings/settings_bloc.dart';
import 'core/services/backup_service.dart';
import 'core/services/security_service.dart';
import 'core/services/notification_service.dart';

final sl = GetIt.instance;

/// Initialize dependency injection
Future<void> initializeDependencies() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(AccountModelAdapter());
  Hive.registerAdapter(AuditLogModelAdapter());

  // Open boxes
  await Hive.openBox('settings');

  // Data Sources
  final transactionLocalDataSource = TransactionLocalDataSourceImpl();
  await transactionLocalDataSource.init();
  sl.registerLazySingleton<TransactionLocalDataSource>(
    () => transactionLocalDataSource,
  );

  final accountLocalDataSource = AccountLocalDataSourceImpl();
  await accountLocalDataSource.init();
  sl.registerLazySingleton<AccountLocalDataSource>(
    () => accountLocalDataSource,
  );

  // Repositories
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<WalletRepository>(() => WalletRepositoryImpl());

  // Use Cases
  sl.registerLazySingleton(() => BalanceCalculator());
  sl.registerLazySingleton(() => GetTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => AddTransactionUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoryWiseExpensesUseCase(sl()));
  sl.registerLazySingleton(() => GetAccountsUseCase(sl()));
  sl.registerLazySingleton(() => AddAccountUseCase(sl()));
  sl.registerLazySingleton(() => GetAccountBalanceUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));
  sl.registerLazySingleton<CalculateNetWorthUseCase>(
    () => CalculateNetWorthUseCase(
      transactionRepository: sl(),
      accountRepository: sl(),
      balanceCalculator: sl(),
      getAccountBalanceUseCase: sl(),
    ),
  );

  // Services
  sl.registerLazySingleton(() => BackupService());
  sl.registerLazySingleton(() => SecurityService());
  sl.registerLazySingleton(() => NotificationService());

  // BLoCs
  sl.registerFactory(
    () => TransactionBloc(
      getTransactionsUseCase: sl(),
      addTransactionUseCase: sl(),
      balanceCalculator: sl(),
      getCategoryWiseExpensesUseCase: sl(),
      calculateNetWorthUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => AccountBloc(
      getAccountsUseCase: sl(),
      addAccountUseCase: sl(),
      deleteAccountUseCase: sl(),
      calculateNetWorthUseCase: sl(),
      getAccountBalanceUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => SettingsBloc());
}

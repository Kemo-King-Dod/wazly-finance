import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/wallet/data/models/transaction_model.dart';
import 'features/wallet/data/models/account_model.dart';
import 'features/wallet/data/models/audit_log_model.dart';
import 'features/wallet/data/datasources/wallet_local_datasource.dart';
import 'features/wallet/data/repositories/wallet_repository_impl.dart';
import 'features/wallet/domain/repositories/wallet_repository.dart';
import 'features/wallet/domain/usecases/balance_calculator.dart';
import 'features/wallet/domain/usecases/get_transactions_usecase.dart';
import 'features/wallet/domain/usecases/add_transaction_usecase.dart';
import 'features/wallet/domain/usecases/get_category_wise_expenses_usecase.dart';
import 'features/wallet/domain/usecases/get_accounts_usecase.dart';
import 'features/wallet/domain/usecases/add_account_usecase.dart';
import 'features/wallet/domain/usecases/get_account_balance_usecase.dart';
import 'features/wallet/domain/usecases/calculate_net_worth_usecase.dart';
import 'features/wallet/domain/usecases/delete_account_usecase.dart';
import 'features/wallet/presentation/blocs/wallet_bloc.dart';
import 'features/wallet/presentation/blocs/settings/settings_bloc.dart';

final sl = GetIt.instance;

/// Initialize dependency injection
Future<void> initializeDependencies() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(AccountModelAdapter());
  Hive.registerAdapter(AuditLogModelAdapter());

  // Data Sources
  final localDataSource = WalletLocalDataSourceImpl();
  await localDataSource.init();
  sl.registerLazySingleton<WalletLocalDataSource>(() => localDataSource);

  // Repositories
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(localDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => BalanceCalculator());
  sl.registerLazySingleton(() => GetTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => AddTransactionUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoryWiseExpensesUseCase(sl()));
  sl.registerLazySingleton(() => GetAccountsUseCase(sl()));
  sl.registerLazySingleton(() => AddAccountUseCase(sl()));
  sl.registerLazySingleton(() => GetAccountBalanceUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));
  sl.registerLazySingleton(
    () => CalculateNetWorthUseCase(
      repository: sl(),
      balanceCalculator: sl(),
      getAccountBalanceUseCase: sl(),
    ),
  );

  // BLoC
  sl.registerFactory(
    () => WalletBloc(
      getTransactionsUseCase: sl(),
      addTransactionUseCase: sl(),
      balanceCalculator: sl(),
      getCategoryWiseExpensesUseCase: sl(),
      getAccountsUseCase: sl(),
      addAccountUseCase: sl(),
      calculateNetWorthUseCase: sl(),
      deleteAccountUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => SettingsBloc());
}

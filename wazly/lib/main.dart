import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'injection_container.dart' as di;
import 'features/home/presentation/pages/dashboard_page.dart';
import 'features/analytics/presentation/pages/analytics_page.dart';
import 'features/accounts/presentation/pages/accounts_page.dart';
import 'features/debts/presentation/blocs/debt_bloc.dart';
import 'features/transactions/presentation/pages/transaction_history_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/settings/presentation/blocs/settings_bloc.dart';
import 'features/settings/presentation/blocs/settings_event.dart';
import 'features/settings/presentation/blocs/settings_state.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/settings/presentation/pages/security_lock_page.dart';
import 'features/transactions/presentation/blocs/transaction_bloc.dart';
import 'features/accounts/presentation/blocs/account_bloc.dart';
import 'features/analytics/presentation/blocs/analytics_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initializeDependencies();
  runApp(const WazlyApp());
}

class WazlyApp extends StatelessWidget {
  const WazlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<SettingsBloc>()..add(const LoadSettings()),
        ),
        BlocProvider(create: (context) => di.sl<TransactionBloc>()),
        BlocProvider(create: (context) => di.sl<AnalyticsBloc>()),
        BlocProvider(create: (context) => di.sl<DebtBloc>()),
        BlocProvider(create: (context) => di.sl<AccountBloc>()),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Wazly',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            locale: state.locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('ar')],
            builder: (context, child) => SecurityLockPage(child: child!),
            initialRoute: '/',
            routes: {
              '/': (context) => const DashboardPage(),
              '/history': (context) => const TransactionHistoryPage(),
              '/accounts': (context) => const AccountsPage(),
              '/analytics': (context) => const AnalyticsPage(),
              '/settings': (context) => const SettingsPage(),
            },
          );
        },
      ),
    );
  }
}

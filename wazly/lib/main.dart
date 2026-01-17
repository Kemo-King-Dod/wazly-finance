import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'injection_container.dart' as di;
import 'features/home/presentation/pages/dashboard_page.dart';
import 'features/analytics/presentation/pages/analytics_page.dart';
import 'features/accounts/presentation/pages/accounts_page.dart';
import 'features/debts/presentation/blocs/debt_bloc.dart';
import 'features/profile/presentation/pages/profile_page.dart';
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
import 'features/profile/presentation/blocs/profile_bloc.dart';
import 'features/profile/presentation/blocs/profile_event.dart';
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'features/auth/presentation/blocs/auth_event.dart';
import 'features/auth/presentation/blocs/auth_state.dart';
import 'features/auth/presentation/pages/welcome_page.dart';

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
        BlocProvider(
          create: (context) => di.sl<ProfileBloc>()..add(const LoadProfile()),
        ),
        BlocProvider.value(value: di.sl<AuthBloc>()),
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
            home: const _AuthGate(),
            routes: {
              '/welcome': (context) => const WelcomePage(),
              '/dashboard': (context) => const DashboardPage(),
              '/history': (context) => const TransactionHistoryPage(),
              '/accounts': (context) => const AccountsPage(),
              '/analytics': (context) => const AnalyticsPage(),
              '/profile': (context) => const ProfilePage(),
              '/settings': (context) => const SettingsPage(),
            },
          );
        },
      ),
    );
  }
}

/// Auth gate widget that decides which screen to show
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  void initState() {
    super.initState();
    // Check auth status when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(const CheckAuthStatus());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading || state is AuthInitial) {
            return const Scaffold(
              backgroundColor: AppTheme.backgroundColor,
              body: Center(
                child: CircularProgressIndicator(color: AppTheme.incomeColor),
              ),
            );
          }

          if (state is AuthWelcomeRequired) {
            return const WelcomePage();
          }

          return const DashboardPage();
        },
      ),
    );
  }
}

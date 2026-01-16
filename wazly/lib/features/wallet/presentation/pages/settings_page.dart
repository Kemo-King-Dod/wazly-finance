import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../blocs/settings/settings_bloc.dart';
import '../blocs/settings/settings_event.dart';
import '../blocs/settings/settings_state.dart';
import '../blocs/wallet_bloc.dart';
import '../blocs/wallet_state.dart';
import '../widgets/wazly_drawer_premium.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          double totalBalance = 0;
          double debtAssets = 0;
          double debtLiabilities = 0;

          if (state is WalletLoaded) {
            totalBalance = state.totalBalance;
            debtAssets = state.debtAssets;
            debtLiabilities = state.debtLiabilities;
          }

          return WazlyDrawerPremium(
            currentRoute: '/settings',
            totalBalance: totalBalance,
            debtAssets: debtAssets,
            debtLiabilities: debtLiabilities,
          );
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader(l10n.language),
          const SizedBox(height: 16),
          _buildLanguageSelector(context, l10n),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.incomeColor,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final currentLocale = state.locale.languageCode;

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildLanguageOption(
                context,
                title: l10n.english,
                isSelected: currentLocale == 'en',
                onTap: () => context.read<SettingsBloc>().add(
                  const ChangeLocale(Locale('en')),
                ),
                isFirst: true,
              ),
              Divider(
                height: 1,
                color: AppTheme.textSecondary.withValues(alpha: 0.1),
              ),
              _buildLanguageOption(
                context,
                title: l10n.arabic,
                isSelected: currentLocale == 'ar',
                onTap: () => context.read<SettingsBloc>().add(
                  const ChangeLocale(Locale('ar')),
                ),
                isLast: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(20) : Radius.zero,
        bottom: isLast ? const Radius.circular(20) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.incomeColor,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }
}

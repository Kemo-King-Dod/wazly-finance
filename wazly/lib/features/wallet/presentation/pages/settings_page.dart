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
import '../widgets/wazly_navigation_rail.dart';

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
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          return Row(
            children: [
              if (settingsState.isNavigationRailEnabled)
                WazlyNavigationRail(
                  currentRoute: '/settings',
                  onNavigate: (route) {
                    if (route != '/settings') {
                      Navigator.pushReplacementNamed(context, route);
                    }
                  },
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildSectionHeader(l10n.language),
                    const SizedBox(height: 16),
                    _buildLanguageSelector(context, l10n),
                    const SizedBox(height: 32),
                    _buildSectionHeader(l10n.appearance),
                    const SizedBox(height: 16),
                    _buildAppearanceSection(context, l10n),
                    const SizedBox(height: 32),
                    _buildSectionHeader(l10n.security),
                    const SizedBox(height: 16),
                    _buildSecuritySection(context, l10n),
                    const SizedBox(height: 32),
                    _buildSectionHeader(l10n.dataManagement),
                    const SizedBox(height: 16),
                    _buildDataManagementSection(context, l10n),
                    const SizedBox(height: 40),
                    _buildResetButton(context, l10n),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
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
              _buildSettingsTile(
                icon: Icons.view_sidebar_rounded,
                title: l10n.miniSidebar,
                subtitle: l10n.miniSidebarDesc,
                trailing: Switch.adaptive(
                  value: state.isNavigationRailEnabled,
                  onChanged: (value) {
                    context.read<SettingsBloc>().add(
                      ToggleNavigationRail(value),
                    );
                  },
                  activeThumbColor: AppTheme.incomeColor,
                ),
                isFirst: true,
                isLast: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSecuritySection(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
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
              _buildSettingsTile(
                icon: Icons.fingerprint_rounded,
                title: l10n.biometric,
                subtitle: l10n.appLock,
                trailing: Switch.adaptive(
                  value:
                      state.isSecurityEnabled &&
                      state.securityType == SecurityType.biometric,
                  onChanged: (value) {
                    if (value) {
                      context.read<SettingsBloc>().add(
                        const ToggleSecurity(SecurityType.biometric),
                      );
                    } else {
                      context.read<SettingsBloc>().add(
                        const ToggleSecurity(SecurityType.none),
                      );
                    }
                  },
                  activeThumbColor: AppTheme.incomeColor,
                ),
                isFirst: true,
              ),
              Divider(
                height: 1,
                color: AppTheme.textSecondary.withValues(alpha: 0.1),
              ),
              _buildSettingsTile(
                icon: Icons.password_rounded,
                title: l10n.password,
                subtitle: l10n.setupPassword,
                onTap: () => _showPasswordDialog(context, l10n),
                trailing:
                    state.isSecurityEnabled &&
                        state.securityType == SecurityType.password
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.incomeColor,
                      )
                    : const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.textSecondary,
                      ),
                isLast: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataManagementSection(
    BuildContext context,
    AppLocalizations l10n,
  ) {
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
          _buildSettingsTile(
            icon: Icons.backup_rounded,
            title: l10n.backupData,
            onTap: () {
              context.read<SettingsBloc>().add(const BackupData());
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.backupExported)));
            },
            isFirst: true,
          ),
          Divider(
            height: 1,
            color: AppTheme.textSecondary.withValues(alpha: 0.1),
          ),
          _buildSettingsTile(
            icon: Icons.restore_rounded,
            title: l10n.restoreData,
            onTap: () {
              context.read<SettingsBloc>().add(const RestoreData());
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.backupRestored)));
            },
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => _showFormatConfirmation(context, l10n),
        icon: const Icon(
          Icons.delete_forever_rounded,
          color: AppTheme.debtColor,
        ),
        label: Text(
          l10n.systemReset,
          style: const TextStyle(
            color: AppTheme.debtColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(20),
          backgroundColor: AppTheme.debtColor.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.incomeColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showPasswordDialog(BuildContext context, AppLocalizations l10n) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.setupPassword,
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            hintText: l10n.enterPassword,
            hintStyle: const TextStyle(color: AppTheme.textSecondary),
            filled: true,
            fillColor: AppTheme.backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<SettingsBloc>().add(
                  ToggleSecurity(
                    SecurityType.password,
                    password: controller.text,
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.incomeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.save, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFormatConfirmation(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.systemReset,
          style: const TextStyle(color: AppTheme.debtColor),
        ),
        content: Text(
          l10n.formatConfirmation,
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SettingsBloc>().add(const ResetSystem());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('System Reset successful')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.debtColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.format,
              style: const TextStyle(color: Colors.white),
            ),
          ),
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

import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wazly/core/presentation/bloc/settings/settings_cubit.dart';
import 'package:wazly/core/presentation/pages/onboarding_screen.dart';
import 'package:wazly/core/presentation/pages/app_shell.dart';
import 'package:wazly/l10n/app_localizations.dart';
import 'package:wazly/core/presentation/widgets/custom_selector_bottom_sheet.dart';
import 'package:wazly/core/theme/app_theme.dart';

class LocaleSetupScreen extends StatefulWidget {
  final bool hasSeenOnboarding;
  
  const LocaleSetupScreen({
    super.key,
    required this.hasSeenOnboarding,
  });

  @override
  State<LocaleSetupScreen> createState() => _LocaleSetupScreenState();
}

class _LocaleSetupScreenState extends State<LocaleSetupScreen> {
  late String _selectedLanguage;
  String? _selectedCountry;
  String _detectedCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    _selectedLanguage = context.read<SettingsCubit>().state.languageCode;
  }

  List<SelectorItem> _getLanguageItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      SelectorItem(label: l10n.langEnglish, value: 'en', leadingIcon: '🇺🇸'),
      SelectorItem(label: l10n.arabicLanguageLabel, value: 'ar', leadingIcon: '🇸🇦'),
    ];
  }

  List<SelectorItem> _getCountryItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      SelectorItem(label: l10n.countryLibya, value: 'LY', leadingIcon: '🇱🇾', badgeText: l10n.currencySymbol),
      SelectorItem(label: l10n.countryEgypt, value: 'EG', leadingIcon: '🇪🇬', badgeText: 'EGP'),
      SelectorItem(label: l10n.countryUAE, value: 'AE', leadingIcon: '🇦🇪', badgeText: 'AED'),
      SelectorItem(label: l10n.countrySaudiArabia, value: 'SA', leadingIcon: '🇸🇦', badgeText: 'SAR'),
      SelectorItem(label: l10n.countryUS, value: 'US', leadingIcon: '🇺🇸', badgeText: 'USD'),
      SelectorItem(label: l10n.countryUK, value: 'GB', leadingIcon: '🇬🇧', badgeText: 'GBP'),
      SelectorItem(label: l10n.countryEurozone, value: 'EU', leadingIcon: '🇪🇺', badgeText: 'EUR'),
      SelectorItem(label: l10n.countryIndia, value: 'IN', leadingIcon: '🇮🇳', badgeText: 'INR'),
    ];
  }

  void _onCountryChanged(String? countryCode) {
    setState(() {
      _selectedCountry = countryCode;
      if (countryCode != null) {
        final countryItems = _getCountryItems(context);
        final countryItem = countryItems.firstWhere((c) => c.value == countryCode);
        _detectedCurrency = countryItem.badgeText!;
      }
    });
  }

  void _saveAndContinue() async {
    if (_selectedCountry == null) return;

    await context.read<SettingsCubit>().updateLocaleSetup(
      _selectedLanguage,
      _selectedCountry!,
      _detectedCurrency,
    );

    if (!mounted) return;

    if (widget.hasSeenOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canContinue = _selectedCountry != null;
    final l10n = AppLocalizations.of(context);
    final countryItems = _getCountryItems(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  FluentIcons.globe_24_regular,
                  size: 48,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n?.welcomeTitle ?? 'Welcome to Wazly',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.welcomeSubtitle ?? 'Let\'s set up your region to configure date formatting, text direction, and currency.',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),

              // Language
              Text(
                l10n?.languageLabel ?? 'LANGUAGE',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  CustomSelectorBottomSheet.show(
                    context: context,
                    title: l10n?.selectLanguageHint ?? 'Select your language',
                    type: SelectorType.language,
                    items: _getLanguageItems(context),
                    selectedValue: _selectedLanguage,
                    onSelected: (val) {
                      setState(() => _selectedLanguage = val);
                      context.read<SettingsCubit>().updateLanguage(val);
                    },
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getLanguageItems(context).firstWhere((l) => l.value == _selectedLanguage).leadingIcon ?? '🌐',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getLanguageItems(context).firstWhere((l) => l.value == _selectedLanguage).label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Icon(FluentIcons.chevron_down_24_regular, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Country
              Text(
                l10n?.countryLabel ?? 'COUNTRY',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  CustomSelectorBottomSheet.show(
                    context: context,
                    title: l10n?.selectCountryHint ?? 'Select your country',
                    type: SelectorType.country,
                    items: countryItems,
                    selectedValue: _selectedCountry ?? '',
                    onSelected: _onCountryChanged,
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderLight, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      if (_selectedCountry != null) ...[
                        Text(
                          countryItems.firstWhere((c) => c.value == _selectedCountry).leadingIcon ?? '🌐',
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            countryItems.firstWhere((c) => c.value == _selectedCountry).label,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: Text(
                            l10n?.selectCountryHint ?? 'Select your country',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                      Icon(FluentIcons.chevron_down_24_regular, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              if (_selectedCountry != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(FluentIcons.info_24_regular, 
                          color: Theme.of(context).primaryColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n?.currencyNotice(_detectedCurrency) ?? 'Your default currency will be set to $_detectedCurrency. You can change this later in Settings.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: canContinue ? _saveAndContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    disabledBackgroundColor: AppTheme.borderLight,
                    disabledForegroundColor: AppTheme.textSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n?.continueButton ?? 'Continue',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

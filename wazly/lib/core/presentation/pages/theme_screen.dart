import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wazly/core/presentation/bloc/theme/theme_cubit.dart';
import 'package:wazly/core/theme/app_theme.dart';
import 'package:wazly/l10n/app_localizations.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  String _localizedThemeName(BuildContext context, AppThemeOption option) {
    final l10n = AppLocalizations.of(context)!;
    switch (option) {
      case AppThemeOption.royalPurple: return l10n.themeRoyalPurple;
      case AppThemeOption.indigo: return l10n.themeIndigo;
      case AppThemeOption.emerald: return l10n.themeEmerald;
      case AppThemeOption.sunsetOrange: return l10n.themeSunset;
      case AppThemeOption.midnightDark: return l10n.themeMidnight;
      case AppThemeOption.crimsonRed: return l10n.themeCrimson;
      case AppThemeOption.oceanBlue: return l10n.themeOcean;
      case AppThemeOption.amberGold: return l10n.themeAmber;
      case AppThemeOption.teal: return l10n.themeTeal;
      case AppThemeOption.rosePink: return l10n.themeRose;
      case AppThemeOption.forestGreen: return l10n.themeForest;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTheme),
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            itemCount: AppThemeOption.values.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final option = AppThemeOption.values[index];
              final isSelected = state.option == option;

              return GestureDetector(
                onTap: () {
                  context.read<ThemeCubit>().setTheme(option);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    border: Border.all(
                      color: isSelected ? option.color : AppTheme.borderLight,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: option.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _localizedThemeName(context, option),
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(FluentIcons.checkmark_circle_24_filled, color: option.color),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeOption {
  royalPurple('Royal Purple', Color(0xFF3713EC)),
  indigo('Indigo', Color(0xFF3F51B5)),
  emerald('Emerald', Color(0xFF10B981)),
  sunsetOrange('Sunset', Color(0xFFFF5722)),
  midnightDark('Midnight', Color(0xFF1E293B)),
  crimsonRed('Crimson', Color(0xFFDC2626)),
  oceanBlue('Ocean', Color(0xFF0284C7)),
  amberGold('Amber', Color(0xFFD97706)),
  teal('Teal', Color(0xFF0D9488)),
  rosePink('Rose', Color(0xFFE11D48)),
  forestGreen('Forest', Color(0xFF15803D));

  final String name;
  final Color color;
  const AppThemeOption(this.name, this.color);
}

class AppTheme {
  // --- Semantic & Status Colors ---
  static const Color incomeColor = Color(0xFF10B981); // Emerald Green
  static const Color debtColor = Color(0xFFEF4444); // Ruby Red
  static const Color warningColor = Color(0xFFF59E0B); // Amber

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF5F6FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF3F4F6);
  static const Color lightOnSurface = Color(0xFF111111);
  static const Color lightOnSurfaceVariant = Color(0xFF6B7280);

  // Card & Surface tokens
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderSubtle = Color(0xFFF3F4F6);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF131022);
  static const Color darkSurface = Color(0xFF2B2839);
  static const Color darkCard = Color(0xFF1E1B2E);
  static const Color darkOnSurface = Color(0xFFF1F5F9);
  static const Color darkOnSurfaceVariant = Color(0xFF94A3B8);

  // Legacy mappings
  static const Color backgroundColor = lightBackground;
  static const Color textPrimary = lightOnSurface;
  static const Color textSecondary = lightOnSurfaceVariant;

  // --- Shared Constants ---
  static const double cardRadius = 16.0;
  static const double cardElevation = 0.0;
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20);

  static BoxDecoration get sectionCardDecoration => BoxDecoration(
    color: surfaceCard,
    borderRadius: BorderRadius.circular(cardRadius),
    border: Border.all(color: borderLight, width: 1),
  );

  static ThemeData getTheme(AppThemeOption option, {bool isDark = false}) {
    final primaryColor = option.color;
    // Derive a secondary color (slightly lighter/different) for gradients if needed
    final secondaryColor = HSLColor.fromColor(primaryColor).withLightness((HSLColor.fromColor(primaryColor).lightness + 0.1).clamp(0.0, 1.0)).toColor();

    if (isDark) {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: darkBackground,
        colorScheme: ColorScheme.dark(
          primary: primaryColor,
          secondary: secondaryColor,
          surface: darkSurface,
          surfaceContainerHighest: darkCard,
          error: debtColor,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: darkOnSurface,
          onSurfaceVariant: darkOnSurfaceVariant,
          onError: Colors.white,
        ),
        fontFamily: 'Almarai',
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: darkOnSurface,
          displayColor: darkOnSurface,
          fontFamily: 'Almarai',
        ),
        cardTheme: CardThemeData(
          color: darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
            side: const BorderSide(color: Colors.white10, width: 1),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Colors.transparent,
          space: 0,
          thickness: 0,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: darkBackground,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: darkOnSurface),
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: darkOnSurface,
            fontFamily: 'Almarai',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cardRadius),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Almarai',
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Almarai'),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkSurface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 1.5),
          ),
        ),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightSurface,
        surfaceContainerHighest: lightSurfaceVariant,
        error: debtColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightOnSurface,
        onSurfaceVariant: lightOnSurfaceVariant,
        onError: Colors.white,
      ),
      fontFamily: 'Almarai',
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: lightOnSurface,
        displayColor: lightOnSurface,
        fontFamily: 'Almarai',
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.transparent,
        space: 0,
        thickness: 0,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: lightOnSurface),
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: lightOnSurface,
        ).copyWith(fontFamily: 'Almarai'),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Almarai',
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Almarai'),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
    );
  }
}


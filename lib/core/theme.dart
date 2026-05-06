import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Rarity System ─────────────────────────────────────────────────────────
enum Rarity { common, uncommon, rare, epic, legendary }

Color rarityColor(Rarity rarity) {
  switch (rarity) {
    case Rarity.common:
      return QuestlingsTheme.rarityCommon;
    case Rarity.uncommon:
      return QuestlingsTheme.rarityUncommon;
    case Rarity.rare:
      return QuestlingsTheme.rarityRare;
    case Rarity.epic:
      return QuestlingsTheme.rarityEpic;
    case Rarity.legendary:
      return QuestlingsTheme.rarityLegendary;
  }
}

String rarityLabel(Rarity rarity) {
  switch (rarity) {
    case Rarity.common:
      return 'Common';
    case Rarity.uncommon:
      return 'Uncommon';
    case Rarity.rare:
      return 'Rare';
    case Rarity.epic:
      return 'Epic';
    case Rarity.legendary:
      return 'Legendary';
  }
}

class QuestlingsTheme {
  // ── Colors from DESIGN.md ───────────────────────────────────────────────
  static const Color surface = Color(0xFFFAFAF2);
  static const Color surfaceDim = Color(0xFFDADAD3);
  static const Color onSurface = Color(0xFF1A1C18);
  static const Color outline = Color(0xFF717A6D);
  
  static const Color primary = Color(0xFF2F6B2D);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF98D98E);
  static const Color onPrimaryContainer = Color(0xFF246024);
  
  static const Color secondary = Color(0xFF13648F);
  static const Color onSecondary = Color(0xFFFFFFFF);
  
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  
  static const Color background = Color(0xFFFAFAF2);
  static const Color onBackground = Color(0xFF1A1C18);

  static const Color border = Color(0xFF282828); // Rigorous Dark Gray border

  // ── Old properties mapped to new ones for backwards compatibility ───────
  static const Color primaryLight = primary;
  static const Color primaryDark = onPrimaryContainer;
  static const Color accent = secondary;
  static const Color surfaceDark = surface;
  static const Color surfaceCard = surface;
  static const Color surfaceOverlay = surfaceDim;
  static const Color backgroundDark = background;
  static const Color textPrimary = onSurface;
  static const Color textSecondary = outline;
  static const Color success = primary;
  static const Color danger = error;
  static const Color warning = secondary;
  
  static const Color rarityCommon = outline;
  static const Color rarityUncommon = primary;
  static const Color rarityRare = secondary;
  static const Color rarityEpic = Color(0xFF675030);
  static const Color rarityLegendary = Color(0xFFE3C49B);

  // ── Gradients ───────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, background], // Solid color for retro
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [surface, surface],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [rarityLegendary, Color(0xFFD2B48C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Shadows ─────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
        const BoxShadow(
          color: border,
          blurRadius: 0,
          offset: Offset(2, 2),
        ),
      ];

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.3),
          blurRadius: 0, // No blur for retro
          offset: const Offset(2, 2),
        ),
      ];

  // ── Theme Data ──────────────────────────────────────────────────────────
  static ThemeData get retroTheme {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        surface: surface,
        onSurface: onSurface,
        error: error,
        onError: onError,
        outline: outline,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.splineSans(
          color: onSurface,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.02,
        ),
        displayMedium: GoogleFonts.splineSans(
          color: onSurface,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: GoogleFonts.splineSans(
          color: onSurface,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 32 / 24,
          letterSpacing: -0.02,
        ),
        headlineMedium: GoogleFonts.splineSans(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          height: 28 / 20,
        ),
        titleLarge: GoogleFonts.lexend(
          color: onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.8,
        ),
        bodyLarge: GoogleFonts.lexend(
          color: onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 24 / 16,
        ),
        bodyMedium: GoogleFonts.lexend(
          color: onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 20 / 14,
        ),
        labelLarge: GoogleFonts.lexend(
          color: onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 16 / 12,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.splineSans(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: onSurface),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: border, width: 2),
          ),
          elevation: 0,
          textStyle: GoogleFonts.lexend(fontWeight: FontWeight.w600),
        ).copyWith(
          shadowColor: WidgetStateProperty.all(border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE8E8D0), 
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: border, width: 2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: border, width: 2),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: primary, width: 2),
        ),
        labelStyle: GoogleFonts.lexend(color: outline),
        prefixIconColor: outline,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: outline,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.lexend(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.lexend(
          fontWeight: FontWeight.w400,
          fontSize: 11,
        ),
      ),
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: border, width: 2),
        ),
        margin: EdgeInsets.all(8),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 2,
        space: 2,
      ),
    );
  }
}
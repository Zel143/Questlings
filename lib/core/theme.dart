import 'package:flutter/material.dart';

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
  // ── Colors ──────────────────────────────────────────────────────────────
  static const Color primaryLight = Color(0xFF7C4DFF);
  static const Color primaryDark = Color(0xFFB388FF);
  static const Color secondary = Color(0xFFFFD54F);
  static const Color accent = Color(0xFF00E5FF);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color surfaceCard = Color(0xFF16213E);
  static const Color surfaceOverlay = Color(0xFF0F3460);
  static const Color backgroundDark = Color(0xFF0D0D1A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0C3);
  static const Color success = Color(0xFF4CAF50);
  static const Color danger = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFB74D);
  static const Color rarityCommon = Color(0xFF9E9E9E);
  static const Color rarityUncommon = Color(0xFF4CAF50);
  static const Color rarityRare = Color(0xFF42A5F5);
  static const Color rarityEpic = Color(0xFFAB47BC);
  static const Color rarityLegendary = Color(0xFFFFB74D);

  // ── Gradients ───────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0D0D1A), Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF16213E), Color(0xFF1A1A2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Shadows ─────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: primaryLight.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 0),
        ),
      ];

  // ── Theme Data ──────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryLight,
        secondary: secondary,
        surface: surfaceDark,
        error: danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
        labelLarge: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: primaryLight.withValues(alpha: 0.4),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: surfaceOverlay, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        prefixIconColor: textSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryLight,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 20,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 11,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: surfaceOverlay.withValues(alpha: 0.5),
        thickness: 1,
      ),
    );
  }
}
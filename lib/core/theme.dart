import 'package:flutter/material.dart';

class QuestlingsTheme {
  static const Color background = Color(0xFFF8F8F0);
  static const Color surface = Color(0xFFE8E8D0);
  static const Color primaryAction = Color(0xFF2F6B2D);
  static const Color lightGreen = Color(0xFFA2D991);
  static const Color warning = Color(0xFFBA1A1A);
  static const Color shadow = Color(0xFF282828);
  static const Color blueAction = Color(0xFF1A6B9B);
  static const Color brownAction = Color(0xFF7B5C3F);
  
  static ThemeData get themeData {
    return ThemeData(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: shadow,
        surface: surface,
        onSurface: shadow,
        error: warning,
      ),
      fontFamily: 'Courier', // Standard monospace fallback for blocky look
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: shadow,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: shadow,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
      ),
      dividerColor: shadow,
    );
  }
}

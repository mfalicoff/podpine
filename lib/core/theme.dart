import 'package:flutter/material.dart';

class PodpineTheme {
  static const pine = Color(0xFF173F35);
  static const fern = Color(0xFF4E7D69);
  static const cream = Color(0xFFF6F4EE);
  static const coral = Color(0xFFE76F51);
  static const ink = Color(0xFF17211E);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: pine,
      brightness: Brightness.light,
      primary: pine,
      secondary: coral,
      surface: cream,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: cream,
      fontFamily: 'Georgia',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.7,
        ),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(fontSize: 16, height: 1.45),
        bodyMedium: TextStyle(fontSize: 14, height: 1.4),
        labelLarge: TextStyle(
          fontFamily: 'sans-serif',
          fontWeight: FontWeight.w700,
        ),
        labelMedium: TextStyle(
          fontFamily: 'sans-serif',
          fontWeight: FontWeight.w600,
        ),
      ).apply(bodyColor: ink, displayColor: ink),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: .72),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFFFDFCF8),
        indicatorColor: Color(0xFFDDE7E0),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'sans-serif',
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: .85),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE4E4DC)),
        ),
      ),
    );
  }
}

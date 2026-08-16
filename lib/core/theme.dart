import 'package:flutter/material.dart';

class PodpineTheme {
  static const pine = Color(0xFF173F35);
  static const fern = Color(0xFF4E7D69);
  static const cream = Color(0xFFF6F4EE);
  static const coral = Color(0xFFE76F51);
  static const ink = Color(0xFF17211E);

  static ThemeData get light => _theme(Brightness.light);

  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: pine,
      brightness: brightness,
      primary: isDark ? const Color(0xFF9FD5BE) : pine,
      secondary: isDark ? const Color(0xFFFFB4A2) : coral,
      surface: isDark ? const Color(0xFF101815) : cream,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: 'Georgia',
      textTheme:
          const TextTheme(
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
          ).apply(
            bodyColor: isDark ? const Color(0xFFF2F5F3) : ink,
            displayColor: isDark ? const Color(0xFFF2F5F3) : ink,
          ),
      cardTheme: CardThemeData(
        color: isDark
            ? const Color(0xFF1B2823)
            : Colors.white.withValues(alpha: .82),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark
            ? const Color(0xFF14201B)
            : const Color(0xFFFDFCF8),
        indicatorColor: isDark
            ? const Color(0xFF29483B)
            : const Color(0xFFDDE7E0),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'sans-serif',
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? const Color(0xFF1B2823)
            : Colors.white.withValues(alpha: .9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF51615A) : const Color(0xFF76766F),
          ),
        ),
      ),
      focusColor: scheme.primary.withValues(alpha: .18),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}

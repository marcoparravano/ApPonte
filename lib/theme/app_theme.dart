import 'package:flutter/material.dart';

class AppTheme {
  static const ink = Color(0xFF3F120C);
  static const red = Color(0xFFAD240A);
  static const softRed = Color(0xFFF4D3CC);
  static const coral = Color(0xFFE17B5B);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: red,
      brightness: brightness,
      surface: isDark ? const Color(0xFF1B1312) : const Color(0xFFFAF9F4),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? const Color(0xFF1B1110) : const Color(0xFFFAF9F4),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF2A1916) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF35221E) : const Color(0xFFF0F1E9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }
}

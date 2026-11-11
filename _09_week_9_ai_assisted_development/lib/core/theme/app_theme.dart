import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages the active light/dark [ThemeMode] across the application.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  /// Switches between light and dark themes.
  void toggle() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

/// Global provider controlling light and dark mode state.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Material 3 light and dark theme definitions with WCAG AA contrast targets.
abstract final class AppTheme {
  static const _indigoPrimary = Color(0xFF1E3A8A);
  static const _tealSecondary = Color(0xFF0F766E);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _indigoPrimary,
      primary: _indigoPrimary,
      secondary: _tealSecondary,
      surface: const Color(0xFFF8FAFC),
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: _indigoPrimary,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF818CF8),
      primary: const Color(0xFF818CF8),
      secondary: const Color(0xFF2DD4BF),
      surface: const Color(0xFF0F172A),
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Color(0xFF1E293B),
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF334155)),
        ),
      ),
    );
  }
}

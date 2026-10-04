import 'package:flutter/material.dart';

/// Tema desain Spotify sesuai DESIGN-spotify.md
class SpotifyTheme {
  // Brand colors
  static const Color spotifyGreen = Color(0xFF1ED760);
  static const Color nearBlack = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF181818);
  static const Color midDark = Color(0xFF1F1F1F);
  static const Color darkCard = Color(0xFF252525);
  static const Color midCard = Color(0xFF272727);

  // Text colors
  static const Color textBase = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFB3B3B3);
  static const Color textNearWhite = Color(0xFFCBCBCB);

  // Semantic colors
  static const Color textNegative = Color(0xFFF3727F);
  static const Color textWarning = Color(0xFFFFA42B);
  static const Color textAnnouncement = Color(0xFF539DF5);

  // Border colors
  static const Color borderGray = Color(0xFF4D4D4D);
  static const Color lightBorder = Color(0xFF7C7C7C);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: nearBlack,
      colorScheme: const ColorScheme.dark(
        primary: spotifyGreen,
        surface: darkSurface,
        onSurface: textBase,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: nearBlack,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textBase,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: textBase),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: spotifyGreen,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999), // Spotify full pill
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 1.4, // Systematic label voice
          ),
        ),
      ),
    );
  }
}

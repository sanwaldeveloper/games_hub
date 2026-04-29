// ============================================================
//  App Theme & Constants
//  Centralized styling for the entire quiz app
// ============================================================

import 'package:flutter/material.dart';

class AppTheme {
  // ── Primary Colors ──────────────────────────────────────
  static const Color primaryColor = Color(0xFF2C3E7A);    // Deep Navy Blue
  static const Color accentColor = Color(0xFF4ECDC4);     // Teal Accent
  static const Color secondaryColor = Color(0xFFF7C59F);  // Warm Peach
  static const Color backgroundColor = Color(0xFFF0F4FF); // Light Blue-White
  static const Color cardColor = Colors.white;

  // ── Status Colors ───────────────────────────────────────
  static const Color correctColor = Color(0xFF27AE60);    // Green for correct
  static const Color wrongColor = Color(0xFFE74C3C);      // Red for incorrect
  static const Color neutralColor = Color(0xFF95A5A6);    // Grey for unanswered

  // ── Text Colors ─────────────────────────────────────────
  static const Color textDark = Color(0xFF2C3E50);
  static const Color textLight = Color(0xFF7F8C8D);
  static const Color textWhite = Colors.white;

  // ── Subject Colors (one per subject) ────────────────────
  static const Map<String, Color> subjectColors = {
    'Pak Study': Color(0xFF16A085),   // Emerald Green
    'Math': Color(0xFF8E44AD),        // Purple
    'Urdu': Color(0xFFD35400),        // Dark Orange
    'English': Color(0xFF2980B9),     // Blue
    'General Science': Color(0xFF27AE60), // Green
  };

  // ── Subject Icons ────────────────────────────────────────
  static const Map<String, IconData> subjectIcons = {
    'Pak Study': Icons.flag_rounded,
    'Math': Icons.calculate_rounded,
    'Urdu': Icons.translate_rounded,
    'English': Icons.menu_book_rounded,
    'General Science': Icons.science_rounded,
  };

  // ── Subject Emojis ───────────────────────────────────────
  static const Map<String, String> subjectEmojis = {
    'Pak Study': '🇵🇰',
    'Math': '🔢',
    'Urdu': '📖',
    'English': '📚',
    'General Science': '🔬',
  };

  // ── Border Radius ────────────────────────────────────────
  static const double borderRadius = 16.0;
  static const double smallRadius = 8.0;

  // ── Spacing ──────────────────────────────────────────────
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // ── Get theme data ───────────────────────────────────────
  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 24,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

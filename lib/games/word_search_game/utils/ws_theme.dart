// games/word_search/utils/ws_theme.dart

import 'package:flutter/material.dart';

class WSTheme {
  static const Color primary = Color(0xFF6C63FF);
  static const Color accent  = Color(0xFFFF6584);
  static const Color success = Color(0xFF43D19E);
  static const Color warning = Color(0xFFFFB347);
  static const Color bgDark  = Color(0xFF1A1A2E);
  static const Color card    = Color(0xFF16213E);
  static const Color card2   = Color(0xFF0F3460);

  static const List<Color> wordColors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6584),
    Color(0xFF43D19E),
    Color(0xFFFFB347),
    Color(0xFF4FC3F7),
    Color(0xFFBA68C8),
    Color(0xFF81C784),
    Color(0xFFFF8A65),
  ];

  static Color difficultyColor(String label) {
    switch (label) {
      case 'Easy':   return success;
      case 'Medium': return warning;
      case 'Hard':   return accent;
      default:       return primary;
    }
  }
}

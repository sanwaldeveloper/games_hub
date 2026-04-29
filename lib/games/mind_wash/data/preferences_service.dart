// ============================================================
//  Preferences Service
//  Saves and loads user progress using SharedPreferences
// ============================================================

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  // Key constants
  static const String _levelKey = 'user_level';
  static const String _totalScoreKey = 'total_score';
  static const String _quizzesPlayedKey = 'quizzes_played';

  /// Save the user's current level (1, 2, or 3)
  static Future<void> saveLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_levelKey, level);
  }

  /// Load the user's saved level (defaults to 1 if not set)
  static Future<int> loadLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_levelKey) ?? 1;
  }

  /// Save how many quizzes the user has played
  static Future<void> incrementQuizzesPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_quizzesPlayedKey) ?? 0;
    await prefs.setInt(_quizzesPlayedKey, current + 1);
  }

  /// Get total quizzes played
  static Future<int> getQuizzesPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_quizzesPlayedKey) ?? 0;
  }

  /// Save total cumulative score
  static Future<void> addToTotalScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_totalScoreKey) ?? 0;
    await prefs.setInt(_totalScoreKey, current + score);
  }

  /// Get total cumulative score
  static Future<int> getTotalScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalScoreKey) ?? 0;
  }
}

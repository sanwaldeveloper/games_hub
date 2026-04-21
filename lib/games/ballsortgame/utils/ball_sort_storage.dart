import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level_model.dart';

class BallSortStorage {
  static const String _unlockedLevelsKey = 'ball_sort_unlocked_levels';
  static const String _currentLevelKey = 'ball_sort_current_level';
  static const String _savedStateKey = 'ball_sort_saved_state';
  static const String _totalLevelsKey = 'ball_sort_total_levels';
  static const int totalLevels = 50;

  static BallSortStorage? _instance;
  late SharedPreferences _prefs;

  BallSortStorage._();

  static Future<BallSortStorage> getInstance() async {
    if (_instance == null) {
      _instance = BallSortStorage._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // Unlocked levels
  int getUnlockedLevels() {
    return _prefs.getInt(_unlockedLevelsKey) ?? 1;
  }

  Future<void> unlockLevel(int level) async {
    final current = getUnlockedLevels();
    if (level > current) {
      await _prefs.setInt(_unlockedLevelsKey, level);
    }
  }

  // Current level
  int getCurrentLevel() {
    return _prefs.getInt(_currentLevelKey) ?? 1;
  }

  Future<void> saveCurrentLevel(int level) async {
    await _prefs.setInt(_currentLevelKey, level);
  }

  // Save in-progress game state
  Future<void> saveGameState(LevelModel level) async {
    final json = jsonEncode(level.toJson());
    await _prefs.setString(_savedStateKey, json);
  }

  LevelModel? loadGameState() {
    final json = _prefs.getString(_savedStateKey);
    if (json == null) return null;
    try {
      return LevelModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearGameState() async {
    await _prefs.remove(_savedStateKey);
  }

  // Theme preference
  Future<void> saveDarkMode(bool isDark) async {
    await _prefs.setBool('ball_sort_dark_mode', isDark);
  }

  bool getDarkMode() {
    return _prefs.getBool('ball_sort_dark_mode') ?? false;
  }

  // Sound preference
  Future<void> saveSoundEnabled(bool enabled) async {
    await _prefs.setBool('ball_sort_sound', enabled);
  }

  bool getSoundEnabled() {
    return _prefs.getBool('ball_sort_sound') ?? true;
  }

  // Vibration preference
  Future<void> saveVibrationEnabled(bool enabled) async {
    await _prefs.setBool('ball_sort_vibration', enabled);
  }

  bool getVibrationEnabled() {
    return _prefs.getBool('ball_sort_vibration') ?? true;
  }
}

// games/word_search/services/ws_storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WSStorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Set<int> getCompletedLevels() {
    final list = _prefs?.getStringList('ws_completed_levels') ?? [];
    return list.map(int.parse).toSet();
  }

  static Future<void> markLevelComplete(int levelId) async {
    final completed = getCompletedLevels();
    completed.add(levelId);
    await _prefs?.setStringList(
        'ws_completed_levels', completed.map((e) => e.toString()).toList());
  }

  static Map<int, int> getAllScores() {
    final raw = _prefs?.getString('ws_level_scores') ?? '{}';
    final map = json.decode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(int.parse(k), v as int));
  }

  static Future<void> saveScore(int levelId, int score) async {
    final scores = getAllScores();
    if ((scores[levelId] ?? 0) < score) {
      scores[levelId] = score;
      await _prefs?.setString('ws_level_scores',
          json.encode(scores.map((k, v) => MapEntry(k.toString(), v))));
    }
  }

  static bool isDailyChallengeCompleted() {
    final now = DateTime.now();
    final key = 'ws_daily_${now.year}-${now.month}-${now.day}';
    return _prefs?.getBool(key) ?? false;
  }

  static Future<void> markDailyChallengeComplete() async {
    final now = DateTime.now();
    final key = 'ws_daily_${now.year}-${now.month}-${now.day}';
    await _prefs?.setBool(key, true);
  }
}

// games/word_search/services/ws_game_provider.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/level_model.dart';
import '../services/grid_generator.dart';
import '../services/ws_storage_service.dart';

class WSGameProvider extends ChangeNotifier {
  Set<int> _completedLevels = {};
  Map<int, int> _levelScores = {};

  Set<int> get completedLevels => _completedLevels;
  Map<int, int> get levelScores => _levelScores;

  WSGameState? _gameState;
  WordSearchLevelModel? _currentLevel;
  bool _showConfetti = false;
  Timer? _timer;

  WSGameState? get gameState => _gameState;
  WordSearchLevelModel? get currentLevel => _currentLevel;
  bool get showConfetti => _showConfetti;

  WSCellPosition? _selectionStart;
  List<WSCellPosition> _currentSelection = [];
  List<WSCellPosition> get currentSelection => _currentSelection;

  void initialize() {
    _completedLevels = WSStorageService.getCompletedLevels();
    _levelScores = WSStorageService.getAllScores();
    notifyListeners();
  }

  bool isLevelUnlocked(int levelId) {
    if (levelId == 1) return true;
    return _completedLevels.contains(levelId - 1);
  }

  int? getBestScore(int levelId) => _levelScores[levelId];

  void loadLevel(WordSearchLevelModel level) {
    _currentLevel = level;
    final (grid, placedWords) = WSGridGenerator.generate(level);
    _gameState = WSGameState(
      grid: grid,
      placedWords: placedWords,
      hintsRemaining: level.difficulty == WordSearchDifficulty.easy
          ? 5
          : level.difficulty == WordSearchDifficulty.medium
              ? 3
              : 2,
    );
    _showConfetti = false;
    _currentSelection = [];
    _selectionStart = null;
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_gameState != null &&
          !_gameState!.isPaused &&
          !_gameState!.isComplete) {
        _gameState!.elapsedSeconds++;
        notifyListeners();
      }
    });
  }

  void togglePause() {
    if (_gameState == null) return;
    _gameState!.isPaused = !_gameState!.isPaused;
    notifyListeners();
  }

  void startSelection(WSCellPosition pos) {
    if (_gameState?.isPaused ?? true) return;
    _selectionStart = pos;
    _currentSelection = [pos];
    notifyListeners();
  }

  void updateSelection(WSCellPosition pos) {
    if (_selectionStart == null || _gameState?.isPaused == true) return;
    final start = _selectionStart!;
    final dr = pos.row - start.row;
    final dc = pos.col - start.col;
    List<WSCellPosition> newSelection = [];

    if (dr == 0 || dc == 0 || dr.abs() == dc.abs()) {
      final stepR = dr == 0 ? 0 : dr > 0 ? 1 : -1;
      final stepC = dc == 0 ? 0 : dc > 0 ? 1 : -1;
      final steps = max(dr.abs(), dc.abs());
      for (int i = 0; i <= steps; i++) {
        final r = start.row + i * stepR;
        final c = start.col + i * stepC;
        final size = _gameState!.grid.length;
        if (r >= 0 && r < size && c >= 0 && c < size) {
          newSelection.add(WSCellPosition(r, c));
        }
      }
    } else {
      newSelection = [start];
    }
    _currentSelection = newSelection;
    notifyListeners();
  }

  bool endSelection() {
    if (_gameState == null || _currentSelection.isEmpty) {
      _currentSelection = [];
      _selectionStart = null;
      notifyListeners();
      return false;
    }

    final selectedWord =
        _currentSelection.map((p) => _gameState!.grid[p.row][p.col]).join();

    bool found = false;
    for (final pw in _gameState!.placedWords) {
      if (pw.isFound) continue;
      final revStr = selectedWord.split('').reversed.join();
      if ((selectedWord == pw.word || revStr == pw.word) &&
          _cellsMatch(_currentSelection, pw.cells)) {
        pw.isFound = true;
        _gameState!.score += _calcScore(pw.word.length);
        found = true;
        if (_gameState!.isComplete) _onLevelComplete();
        break;
      }
    }

    _currentSelection = [];
    _selectionStart = null;
    notifyListeners();
    return found;
  }

  bool _cellsMatch(List<WSCellPosition> sel, List<WSCellPosition> word) {
    if (sel.length != word.length) return false;
    return sel.toSet().containsAll(word.toSet()) &&
        word.toSet().containsAll(sel.toSet());
  }

  int _calcScore(int wordLength) {
    final timeBonus = max(0, 300 - (_gameState?.elapsedSeconds ?? 0));
    return wordLength * 10 + timeBonus ~/ 10;
  }

  bool useHint() {
    if (_gameState == null || _gameState!.hintsRemaining <= 0) return false;
    final remaining = _gameState!.remainingWords;
    if (remaining.isEmpty) return false;
    _gameState!.hintsRemaining--;
    final word = remaining[Random().nextInt(remaining.length)];
    _gameState!.hintCell = word.cells.first;
    notifyListeners();
    Future.delayed(const Duration(seconds: 2), () {
      _gameState?.hintCell = null;
      notifyListeners();
    });
    return true;
  }

  void _onLevelComplete() {
    _timer?.cancel();
    _showConfetti = true;
    if (_currentLevel != null) {
      WSStorageService.markLevelComplete(_currentLevel!.id);
      WSStorageService.saveScore(_currentLevel!.id, _gameState!.score);
      _completedLevels = WSStorageService.getCompletedLevels();
      _levelScores = WSStorageService.getAllScores();
      if (_currentLevel!.id == 99) {
        WSStorageService.markDailyChallengeComplete();
      }
    }
  }

  void resetConfetti() {
    _showConfetti = false;
    notifyListeners();
  }

  String get formattedTime {
    final s = _gameState?.elapsedSeconds ?? 0;
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

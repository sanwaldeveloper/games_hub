import 'package:flutter/material.dart';
import '../models/ball_model.dart';
import '../models/tube_model.dart';
import '../models/level_model.dart';
import '../utils/ball_sort_storage.dart';

enum MoveResult { success, invalidFull, invalidColor, invalidEmpty, win }

class GameState {
  final LevelModel level;
  final int? selectedTubeIndex;
  final bool isWon;
  final int moves;

  const GameState({
    required this.level,
    this.selectedTubeIndex,
    this.isWon = false,
    this.moves = 0,
  });

  GameState copyWith({
    LevelModel? level,
    int? selectedTubeIndex,
    bool clearSelection = false,
    bool? isWon,
    int? moves,
  }) {
    return GameState(
      level: level ?? this.level,
      selectedTubeIndex:
          clearSelection ? null : selectedTubeIndex ?? this.selectedTubeIndex,
      isWon: isWon ?? this.isWon,
      moves: moves ?? this.moves,
    );
  }
}

class BallSortController extends ChangeNotifier {
  late BallSortStorage _storage;
  late LevelModel _initialLevel;

  GameState? _currentState;
  final List<GameState> _undoStack = [];
  static const int maxUndoSteps = 5;

  bool _isDarkMode = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _isInitialized = false;

  // Getters
  GameState? get state => _currentState;
  bool get isDarkMode => _isDarkMode;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get isInitialized => _isInitialized;
  bool get canUndo => _undoStack.isNotEmpty;
  int get currentLevelNumber => _currentState?.level.levelNumber ?? 1;
  int get unlockedLevels => _storage.getUnlockedLevels();
  int get totalLevels => BallSortStorage.totalLevels;

  Future<void> initialize() async {
    _storage = await BallSortStorage.getInstance();
    _isDarkMode = _storage.getDarkMode();
    _soundEnabled = _storage.getSoundEnabled();
    _vibrationEnabled = _storage.getVibrationEnabled();

    // Try to restore saved game
    final saved = _storage.loadGameState();
    if (saved != null) {
      _initialLevel = LevelGenerator.generate(saved.levelNumber);
      _currentState = GameState(level: saved, moves: 0);
    } else {
      final levelNum = _storage.getCurrentLevel();
      _loadLevel(levelNum);
    }

    _isInitialized = true;
    notifyListeners();
  }

  void _loadLevel(int levelNumber) {
    final level = LevelGenerator.generate(levelNumber);
    _initialLevel = level;
    _currentState = GameState(level: level);
    _undoStack.clear();
  }

  Future<void> loadLevel(int levelNumber) async {
    _loadLevel(levelNumber);
    await _storage.saveCurrentLevel(levelNumber);
    await _storage.saveGameState(_currentState!.level);
    notifyListeners();
  }

  MoveResult onTubeTapped(int tubeIndex) {
    if (_currentState == null || _currentState!.isWon) return MoveResult.invalidEmpty;

    final state = _currentState!;
    final tubes = state.level.tubes;

    if (state.selectedTubeIndex == null) {
      // Cannot select empty tube or a locked (fully sorted) tube
      if (tubes[tubeIndex].isEmpty) return MoveResult.invalidEmpty;
      if (tubes[tubeIndex].isLocked) return MoveResult.invalidEmpty;
      _currentState = state.copyWith(selectedTubeIndex: tubeIndex);
      notifyListeners();
      return MoveResult.success;
    }

    final fromIndex = state.selectedTubeIndex!;

    // Deselect if same tube tapped
    if (fromIndex == tubeIndex) {
      _currentState = state.copyWith(clearSelection: true);
      notifyListeners();
      return MoveResult.success;
    }

    // Attempt move
    final fromTube = tubes[fromIndex];
    final toTube = tubes[tubeIndex];

    if (fromTube.isEmpty || fromTube.isLocked) {
      _currentState = state.copyWith(clearSelection: true);
      notifyListeners();
      return MoveResult.invalidEmpty;
    }

    if (toTube.isFull) {
      // Switch selection to tapped tube if it's selectable
      if (!tubes[tubeIndex].isEmpty && !tubes[tubeIndex].isLocked) {
        _currentState = state.copyWith(selectedTubeIndex: tubeIndex);
        notifyListeners();
      } else {
        _currentState = state.copyWith(clearSelection: true);
        notifyListeners();
      }
      return MoveResult.invalidFull;
    }

    final ball = fromTube.topBall!;
    if (!toTube.canAccept(ball)) {
      // Switch selection to tapped tube if selectable
      if (!tubes[tubeIndex].isEmpty && !tubes[tubeIndex].isLocked) {
        _currentState = state.copyWith(selectedTubeIndex: tubeIndex);
        notifyListeners();
      }
      return MoveResult.invalidColor;
    }

    // Valid move: push to undo stack
    _pushUndo(state);

    // Perform the move
    final newTubes = List<TubeModel>.from(tubes);
    newTubes[fromIndex] = fromTube.withTopBallRemoved();
    newTubes[tubeIndex] = toTube.withBallAdded(ball);

    final newLevel = state.level.copyWith(tubes: newTubes);
    final won = newLevel.isCompleted;

    _currentState = GameState(
      level: newLevel,
      isWon: won,
      moves: state.moves + 1,
    );

    if (won) {
      _handleWin(newLevel.levelNumber);
    } else {
      _storage.saveGameState(newLevel);
    }

    notifyListeners();
    return won ? MoveResult.win : MoveResult.success;
  }

  void _pushUndo(GameState state) {
    _undoStack.add(state);
    if (_undoStack.length > maxUndoSteps) {
      _undoStack.removeAt(0);
    }
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    _currentState = _undoStack.removeLast();
    _storage.saveGameState(_currentState!.level);
    notifyListeners();
  }

  void restartLevel() {
    _currentState = GameState(level: _initialLevel);
    _undoStack.clear();
    _storage.saveGameState(_initialLevel);
    notifyListeners();
  }

  Future<void> _handleWin(int levelNumber) async {
    final nextLevel = levelNumber + 1;
    if (nextLevel <= totalLevels) {
      await _storage.unlockLevel(nextLevel);
    }
    await _storage.clearGameState();
  }

  Future<void> goToNextLevel() async {
    final next = currentLevelNumber + 1;
    if (next <= totalLevels) {
      await loadLevel(next);
    }
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _storage.saveDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    await _storage.saveSoundEnabled(_soundEnabled);
    notifyListeners();
  }

  Future<void> toggleVibration() async {
    _vibrationEnabled = !_vibrationEnabled;
    await _storage.saveVibrationEnabled(_vibrationEnabled);
    notifyListeners();
  }
}
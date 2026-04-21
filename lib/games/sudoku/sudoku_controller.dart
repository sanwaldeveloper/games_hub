import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:games_hub/games/sudoku/sudoku_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoveRecord {
  final int row;
  final int col;
  final int oldValue;
  final int newValue;

  MoveRecord({
    required this.row,
    required this.col,
    required this.oldValue,
    required this.newValue,
  });
}

class SudokuController extends ChangeNotifier {
  // ── Board state ──────────────────────────────────────────────────────────
  late List<List<int>> _puzzle;      // original puzzle (0 = empty)
  late List<List<int>> _solution;    // full correct solution
  late List<List<int>> _userBoard;   // current user progress
  late List<List<bool>> _isError;    // error flags per cell

  // ── Selection ────────────────────────────────────────────────────────────
  int _selectedRow = -1;
  int _selectedCol = -1;

  // ── Game meta ────────────────────────────────────────────────────────────
  String _difficulty = 'Medium';
  bool _isComplete = false;
  bool _isPaused = false;
  bool _autoCheck = true;
  int _hintsRemaining = 10;   // FIXED: 3 se 10 kar diya
  int _errorCount = 0;

  // ── Undo history ─────────────────────────────────────────────────────────
  final List<MoveRecord> _history = [];

  // ── Timer ────────────────────────────────────────────────────────────────
  Timer? _timer;
  int _elapsedSeconds = 0;

  // ── Getters ──────────────────────────────────────────────────────────────
  List<List<int>> get puzzle      => _puzzle;
  List<List<int>> get userBoard   => _userBoard;
  List<List<bool>> get isError    => _isError;
  int get selectedRow             => _selectedRow;
  int get selectedCol             => _selectedCol;
  String get difficulty           => _difficulty;
  bool get isComplete             => _isComplete;
  bool get isPaused               => _isPaused;
  bool get autoCheck              => _autoCheck;
  int get hintsRemaining          => _hintsRemaining;
  int get errorCount              => _errorCount;
  int get elapsedSeconds          => _elapsedSeconds;
  bool get canUndo                => _history.isNotEmpty;

  String get formattedTime {
    final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Init ─────────────────────────────────────────────────────────────────
  SudokuController() {
    _startNewGame();
  }

  // ── Game setup ───────────────────────────────────────────────────────────
  void _startNewGame({String? difficulty}) {
    _difficulty = difficulty ?? _difficulty;
    final result = SudokuGenerator.generatePuzzle(_difficulty);
    _puzzle    = result[0];
    _solution  = result[1];
    _userBoard = _puzzle.map((r) => List<int>.from(r)).toList();
    _isError   = List.generate(9, (_) => List.generate(9, (_) => false));

    _selectedRow    = -1;
    _selectedCol    = -1;
    _isComplete     = false;
    _isPaused       = false;
    _hintsRemaining = 10;   // FIXED: 10 hints
    _errorCount     = 0;
    _history.clear();
    _elapsedSeconds = 0;

    _timer?.cancel();
    _startTimer();
    notifyListeners();
  }

  void newGame({String? difficulty}) => _startNewGame(difficulty: difficulty);

  void restartGame() {
    _userBoard = _puzzle.map((r) => List<int>.from(r)).toList();
    _isError   = List.generate(9, (_) => List.generate(9, (_) => false));
    _selectedRow    = -1;
    _selectedCol    = -1;
    _isComplete     = false;
    _isPaused       = false;
    _hintsRemaining = 10;   // FIXED: 10 hints
    _errorCount     = 0;
    _history.clear();
    _elapsedSeconds = 0;

    _timer?.cancel();
    _startTimer();
    notifyListeners();
  }

  // ── Timer ────────────────────────────────────────────────────────────────
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused && !_isComplete) {
        _elapsedSeconds++;
        notifyListeners();
      }
    });
  }

  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  // ── Selection ────────────────────────────────────────────────────────────
  void selectCell(int row, int col) {
    if (_isPaused || _isComplete) return;
    _selectedRow = row;
    _selectedCol = col;
    notifyListeners();
  }

  // ── Input ────────────────────────────────────────────────────────────────
  void enterNumber(int num) {
    if (_selectedRow < 0 || _selectedCol < 0) return;
    if (_isPaused || _isComplete) return;
    if (_puzzle[_selectedRow][_selectedCol] != 0) return; // pre-filled

    int oldVal = _userBoard[_selectedRow][_selectedCol];

    _history.add(MoveRecord(
      row: _selectedRow,
      col: _selectedCol,
      oldValue: oldVal,
      newValue: num,
    ));

    _userBoard[_selectedRow][_selectedCol] = num;

    if (_autoCheck && num != 0) {
      bool valid = SudokuGenerator.isValidMove(
          _userBoard, _selectedRow, _selectedCol, num);
      _isError[_selectedRow][_selectedCol] = !valid;
      if (!valid) _errorCount++;
    } else {
      _isError[_selectedRow][_selectedCol] = false;
    }

    _checkCompletion();
    notifyListeners();
  }

  void clearCell() {
    if (_selectedRow < 0 || _selectedCol < 0) return;
    if (_puzzle[_selectedRow][_selectedCol] != 0) return;
    enterNumber(0);
  }

  // ── Undo ─────────────────────────────────────────────────────────────────
  void undo() {
    if (_history.isEmpty) return;
    final move = _history.removeLast();
    _userBoard[move.row][move.col] = move.oldValue;
    _isError[move.row][move.col] = false;
    notifyListeners();
  }

  // ── Hint ─────────────────────────────────────────────────────────────────
  void useHint() {
    if (_hintsRemaining <= 0) return;
    if (_isComplete || _isPaused) return;

    // Find an empty or wrong cell (prefer selected)
    List<List<int>> candidates = [];

    if (_selectedRow >= 0 &&
        _selectedCol >= 0 &&
        _puzzle[_selectedRow][_selectedCol] == 0 &&
        _userBoard[_selectedRow][_selectedCol] !=
            _solution[_selectedRow][_selectedCol]) {
      candidates.add([_selectedRow, _selectedCol]);
    } else {
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (_puzzle[r][c] == 0 &&
              _userBoard[r][c] != _solution[r][c]) {
            candidates.add([r, c]);
          }
        }
      }
    }

    if (candidates.isEmpty) return;

    candidates.shuffle();
    final cell = candidates.first;
    int r = cell[0], c = cell[1];

    _history.add(MoveRecord(
      row: r,
      col: c,
      oldValue: _userBoard[r][c],
      newValue: _solution[r][c],
    ));

    _userBoard[r][c] = _solution[r][c];
    _isError[r][c] = false;
    _hintsRemaining--;
    _selectedRow = r;
    _selectedCol = c;

    _checkCompletion();
    notifyListeners();
  }

  // ── Auto-check toggle ────────────────────────────────────────────────────
  void toggleAutoCheck() {
    _autoCheck = !_autoCheck;
    if (!_autoCheck) {
      // Clear all error flags
      _isError = List.generate(9, (_) => List.generate(9, (_) => false));
    } else {
      // Re-validate board
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (_puzzle[r][c] == 0 && _userBoard[r][c] != 0) {
            bool valid = SudokuGenerator.isValidMove(
                _userBoard, r, c, _userBoard[r][c]);
            _isError[r][c] = !valid;
          }
        }
      }
    }
    notifyListeners();
  }

  // ── Completion check ─────────────────────────────────────────────────────
  // FIXED: error wali cells hain toh complete nahi hogi
  // FIXED: koi bhi cell solution se alag hai toh complete nahi hogi
  void _checkCompletion() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        // Agar cell khali hai
        if (_userBoard[r][c] == 0) return;
        // Agar cell ka value solution se match nahi karta
        if (_userBoard[r][c] != _solution[r][c]) return;
        // Agar cell error state mein hai
        if (_isError[r][c]) return;
      }
    }
    // Sab cells sahi hain — game complete!
    _isComplete = true;
    _timer?.cancel();
    _saveRecord();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  bool isPreFilled(int row, int col) => _puzzle[row][col] != 0;

  bool isHighlighted(int row, int col) {
    if (_selectedRow < 0) return false;
    return row == _selectedRow ||
        col == _selectedCol ||
        (row ~/ 3 == _selectedRow ~/ 3 && col ~/ 3 == _selectedCol ~/ 3);
  }

  bool isSelected(int row, int col) =>
      row == _selectedRow && col == _selectedCol;

  bool sameNumber(int row, int col) {
    if (_selectedRow < 0) return false;
    int sel = _userBoard[_selectedRow][_selectedCol];
    int cur = _userBoard[row][col];
    return sel != 0 && sel == cur;
  }

  // ── Save best times ──────────────────────────────────────────────────────
  Future<void> _saveRecord() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'best_$_difficulty';
    int? best = prefs.getInt(key);
    if (best == null || _elapsedSeconds < best) {
      await prefs.setInt(key, _elapsedSeconds);
    }
  }

  Future<int?> getBestTime(String diff) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('best_$diff');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
// ============================================================
// lib/games/sliding_puzzle/puzzle_logic.dart
// Core game logic: grid state, shuffling, movement, win check
// ============================================================

import 'dart:math';

class PuzzleLogic {
  int gridSize;
  late List<int> board;
  late int emptyIndex;
  int moves = 0;
  bool started = false;
  bool solved = false;

  PuzzleLogic({this.gridSize = 4}) {
    _init();
  }

  int get totalTiles => gridSize * gridSize;

  void _init() {
    moves = 0;
    started = false;
    solved = false;
    _generateSolvableBoard();
  }

  void reset() => _init();

  void _generateSolvableBoard() {
    final rng = Random();
    do {
      board = List<int>.generate(totalTiles, (i) => i + 1);
      board[totalTiles - 1] = 0;
      for (int i = totalTiles - 1; i > 0; i--) {
        int j = rng.nextInt(i + 1);
        int tmp = board[i];
        board[i] = board[j];
        board[j] = tmp;
      }
    } while (!_isSolvable());
    emptyIndex = board.indexOf(0);
  }

  bool _isSolvable() {
    int inversions = _countInversions();
    if (gridSize % 2 == 1) {
      return inversions % 2 == 0;
    } else {
      int blankRowFromBottom = gridSize - (board.indexOf(0) ~/ gridSize);
      if (blankRowFromBottom % 2 == 1) {
        return inversions % 2 == 0;
      } else {
        return inversions % 2 == 1;
      }
    }
  }

  int _countInversions() {
    List<int> tiles = board.where((t) => t != 0).toList();
    int count = 0;
    for (int i = 0; i < tiles.length - 1; i++) {
      for (int j = i + 1; j < tiles.length; j++) {
        if (tiles[i] > tiles[j]) count++;
      }
    }
    return count;
  }

  bool moveTile(int tileIndex) {
    if (solved) return false;
    if (!_isAdjacent(tileIndex, emptyIndex)) return false;
    board[emptyIndex] = board[tileIndex];
    board[tileIndex] = 0;
    emptyIndex = tileIndex;
    moves++;
    started = true;
    solved = _checkWin();
    return true;
  }

  bool _isAdjacent(int a, int b) {
    int rowA = a ~/ gridSize, colA = a % gridSize;
    int rowB = b ~/ gridSize, colB = b % gridSize;
    int rowDiff = (rowA - rowB).abs();
    int colDiff = (colA - colB).abs();
    return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
  }

  bool _checkWin() {
    for (int i = 0; i < totalTiles - 1; i++) {
      if (board[i] != i + 1) return false;
    }
    return board[totalTiles - 1] == 0;
  }

  void changeSize(int newSize) {
    gridSize = newSize;
    _init();
  }
}

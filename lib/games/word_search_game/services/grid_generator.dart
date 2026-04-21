// games/word_search/services/grid_generator.dart

import 'dart:math';
import '../models/game_state.dart';
import '../models/level_model.dart';

class WSGridGenerator {
  static final Random _random = Random();

  static (List<List<String>>, List<WSPlacedWord>) generate(
      WordSearchLevelModel level) {
    final size = level.gridSize;
    final grid = List.generate(size, (_) => List.filled(size, ''));
    final placedWords = <WSPlacedWord>[];

    final words = List<String>.from(level.words)
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final word in words) {
      _placeWord(grid, word, size, placedWords, level);
    }
    _fillEmpty(grid, size);
    return (grid, placedWords);
  }

  static void _placeWord(List<List<String>> grid, String word, int size,
      List<WSPlacedWord> placedWords, WordSearchLevelModel level) {
    const maxAttempts = 200;
    List<List<int>> allowed = [
      [0, 1],
      [1, 0],
    ];
    if (level.allowDiagonal) {
      allowed.addAll([[1, 1], [-1, 1]]);
    }
    if (level.allowBackward) {
      allowed.addAll([[0, -1], [-1, 0]]);
      if (level.allowDiagonal) {
        allowed.addAll([[-1, -1], [1, -1]]);
      }
    }

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final dir = allowed[_random.nextInt(allowed.length)];
      final dr = dir[0];
      final dc = dir[1];

      int startRow, startCol;
      if (dr == 0) startRow = _random.nextInt(size);
      else if (dr > 0) startRow = _random.nextInt(size - word.length + 1);
      else startRow = word.length - 1 + _random.nextInt(size - word.length + 1);

      if (dc == 0) startCol = _random.nextInt(size);
      else if (dc > 0) startCol = _random.nextInt(size - word.length + 1);
      else startCol = word.length - 1 + _random.nextInt(size - word.length + 1);

      if (_canPlace(grid, word, startRow, startCol, dr, dc, size)) {
        final cells = <WSCellPosition>[];
        for (int i = 0; i < word.length; i++) {
          final r = startRow + i * dr;
          final c = startCol + i * dc;
          grid[r][c] = word[i];
          cells.add(WSCellPosition(r, c));
        }
        placedWords.add(WSPlacedWord(word: word, cells: cells));
        return;
      }
    }
    _forcePlaceHorizontal(grid, word, size, placedWords);
  }

  static bool _canPlace(List<List<String>> grid, String word, int startRow,
      int startCol, int dr, int dc, int size) {
    for (int i = 0; i < word.length; i++) {
      final r = startRow + i * dr;
      final c = startCol + i * dc;
      if (r < 0 || r >= size || c < 0 || c >= size) return false;
      final existing = grid[r][c];
      if (existing.isNotEmpty && existing != word[i]) return false;
    }
    return true;
  }

  static void _forcePlaceHorizontal(List<List<String>> grid, String word,
      int size, List<WSPlacedWord> placedWords) {
    for (int row = 0; row < size; row++) {
      for (int col = 0; col <= size - word.length; col++) {
        if (_canPlace(grid, word, row, col, 0, 1, size)) {
          final cells = <WSCellPosition>[];
          for (int i = 0; i < word.length; i++) {
            grid[row][col + i] = word[i];
            cells.add(WSCellPosition(row, col + i));
          }
          placedWords.add(WSPlacedWord(word: word, cells: cells));
          return;
        }
      }
    }
  }

  static void _fillEmpty(List<List<String>> grid, int size) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid[r][c].isEmpty) {
          grid[r][c] = letters[_random.nextInt(letters.length)];
        }
      }
    }
  }
}

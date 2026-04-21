import 'dart:math';

class SudokuGenerator {
  static final Random _random = Random();

  /// Generates a complete valid 9x9 Sudoku board.
  static List<List<int>> generateFullBoard() {
    List<List<int>> board =
        List.generate(9, (_) => List.generate(9, (_) => 0));
    _fillBoard(board);
    return board;
  }

  /// Recursively fills the board using backtracking.
  static bool _fillBoard(List<List<int>> board) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          List<int> nums = List.generate(9, (i) => i + 1)..shuffle(_random);
          for (int num in nums) {
            if (_isValid(board, row, col, num)) {
              board[row][col] = num;
              if (_fillBoard(board)) return true;
              board[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  /// Checks if placing [num] at [row],[col] is valid.
  static bool _isValid(List<List<int>> board, int row, int col, int num) {
    // Check row
    for (int c = 0; c < 9; c++) {
      if (board[row][c] == num) return false;
    }
    // Check column
    for (int r = 0; r < 9; r++) {
      if (board[r][col] == num) return false;
    }
    // Check 3x3 box
    int boxRow = (row ~/ 3) * 3;
    int boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (board[r][c] == num) return false;
      }
    }
    return true;
  }

  /// Generates a puzzle by removing cells from a full board based on difficulty.
  /// Returns [puzzle, solution].
  static List<List<List<int>>> generatePuzzle(String difficulty) {
    List<List<int>> solution = generateFullBoard();
    List<List<int>> puzzle =
        solution.map((row) => List<int>.from(row)).toList();

    int cellsToRemove;
    switch (difficulty) {
      case 'Easy':
        cellsToRemove = 35;
        break;
      case 'Medium':
        cellsToRemove = 45;
        break;
      case 'Hard':
        cellsToRemove = 55;
        break;
      default:
        cellsToRemove = 40;
    }

    List<List<int>> positions = [];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        positions.add([r, c]);
      }
    }
    positions.shuffle(_random);

    int removed = 0;
    for (List<int> pos in positions) {
      if (removed >= cellsToRemove) break;
      int row = pos[0];
      int col = pos[1];
      int backup = puzzle[row][col];
      puzzle[row][col] = 0;

      // Verify the puzzle still has a unique solution
      List<List<int>> temp =
          puzzle.map((r) => List<int>.from(r)).toList();
      int solutionCount = _countSolutions(temp, 0);

      if (solutionCount != 1) {
        puzzle[row][col] = backup; // Revert if not unique
      } else {
        removed++;
      }
    }

    return [puzzle, solution];
  }

  /// Counts the number of solutions (stops at 2 for efficiency).
  /// FIXED: proper backtracking with early exit
  static int _countSolutions(List<List<int>> board, int count) {
    if (count > 1) return count;

    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          for (int num = 1; num <= 9; num++) {
            if (_isValid(board, row, col, num)) {
              board[row][col] = num;
              count = _countSolutions(board, count);
              board[row][col] = 0;
              if (count > 1) return count;
            }
          }
          return count; // No valid number found — dead end
        }
      }
    }
    return count + 1; // All cells filled = one solution found
  }

  /// Public validation helper for real-time checking.
  static bool isValidMove(List<List<int>> board, int row, int col, int num) {
    // Temporarily clear the cell to check without self-conflict
    int original = board[row][col];
    board[row][col] = 0;
    bool valid = _isValid(board, row, col, num);
    board[row][col] = original;
    return valid;
  }
}
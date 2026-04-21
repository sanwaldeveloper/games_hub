// games/word_search/models/game_state.dart

class WSCellPosition {
  final int row;
  final int col;

  const WSCellPosition(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is WSCellPosition && other.row == row && other.col == col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}

class WSPlacedWord {
  final String word;
  final List<WSCellPosition> cells;
  bool isFound;

  WSPlacedWord({
    required this.word,
    required this.cells,
    this.isFound = false,
  });
}

class WSGameState {
  final List<List<String>> grid;
  final List<WSPlacedWord> placedWords;
  List<WSCellPosition> selectedCells;
  int hintsRemaining;
  int score;
  int elapsedSeconds;
  bool isPaused;
  WSCellPosition? hintCell;

  WSGameState({
    required this.grid,
    required this.placedWords,
    this.selectedCells = const [],
    this.hintsRemaining = 3,
    this.score = 0,
    this.elapsedSeconds = 0,
    this.isPaused = false,
    this.hintCell,
  });

  List<WSPlacedWord> get foundWords => placedWords.where((w) => w.isFound).toList();
  List<WSPlacedWord> get remainingWords => placedWords.where((w) => !w.isFound).toList();
  bool get isComplete => placedWords.every((w) => w.isFound);
  int get totalWords => placedWords.length;
  int get foundCount => foundWords.length;
}

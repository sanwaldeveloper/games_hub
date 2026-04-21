// games/word_search/models/level_model.dart

enum WordSearchDifficulty { easy, medium, hard }

class WordSearchLevelModel {
  final int id;
  final String theme;
  final String themeIcon;
  final List<String> words;
  final int gridSize;
  final WordSearchDifficulty difficulty;
  final bool allowDiagonal;
  final bool allowBackward;

  const WordSearchLevelModel({
    required this.id,
    required this.theme,
    required this.themeIcon,
    required this.words,
    required this.gridSize,
    required this.difficulty,
    this.allowDiagonal = false,
    this.allowBackward = false,
  });

  String get difficultyLabel {
    switch (difficulty) {
      case WordSearchDifficulty.easy:
        return 'Easy';
      case WordSearchDifficulty.medium:
        return 'Medium';
      case WordSearchDifficulty.hard:
        return 'Hard';
    }
  }
}

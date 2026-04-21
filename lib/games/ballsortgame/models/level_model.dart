import 'tube_model.dart';
import 'ball_model.dart';

class LevelModel {
  final int levelNumber;
  final List<TubeModel> tubes;
  final int colorCount;
  final int tubeCapacity;

  const LevelModel({
    required this.levelNumber,
    required this.tubes,
    required this.colorCount,
    this.tubeCapacity = 4,
  });

  bool get isCompleted => tubes.every((t) => t.isSorted);

  LevelModel copyWith({
    int? levelNumber,
    List<TubeModel>? tubes,
    int? colorCount,
    int? tubeCapacity,
  }) {
    return LevelModel(
      levelNumber: levelNumber ?? this.levelNumber,
      tubes: tubes ?? this.tubes,
      colorCount: colorCount ?? this.colorCount,
      tubeCapacity: tubeCapacity ?? this.tubeCapacity,
    );
  }

  Map<String, dynamic> toJson() => {
        'levelNumber': levelNumber,
        'tubes': tubes.map((t) => t.toJson()).toList(),
        'colorCount': colorCount,
        'tubeCapacity': tubeCapacity,
      };

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      levelNumber: json['levelNumber'] as int,
      tubes: (json['tubes'] as List)
          .map((t) => TubeModel.fromJson(t as Map<String, dynamic>))
          .toList(),
      colorCount: json['colorCount'] as int,
      tubeCapacity: json['tubeCapacity'] as int? ?? 4,
    );
  }
}

// Level generator
class LevelGenerator {
  static LevelModel generate(int levelNumber) {
    // Difficulty progression
    int colorCount;
    int emptyTubes;
    int capacity = 4;

    if (levelNumber <= 3) {
      colorCount = 2 + levelNumber; // 3,4,5
      emptyTubes = 1;
    } else if (levelNumber <= 8) {
      colorCount = 4 + ((levelNumber - 4) ~/ 2); // 4-7
      emptyTubes = 2;
    } else if (levelNumber <= 15) {
      colorCount = 6 + ((levelNumber - 9) ~/ 2); // 6-10
      emptyTubes = 2;
    } else {
      colorCount = 10 + (levelNumber - 16) ~/ 3;
      colorCount = colorCount.clamp(10, 12);
      emptyTubes = 2;
    }

    return _generateLevel(levelNumber, colorCount, emptyTubes, capacity);
  }

  static LevelModel _generateLevel(
      int levelNumber, int colorCount, int emptyTubes, int capacity) {
    // Create all balls: colorCount * capacity
    List<BallModel> allBalls = [];
    for (int c = 0; c < colorCount; c++) {
      for (int i = 0; i < capacity; i++) {
        allBalls.add(BallModel(colorIndex: c));
      }
    }

    // Shuffle with level-based seed for reproducibility
    allBalls = _seededShuffle(allBalls, levelNumber);

    // Make sure the puzzle isn't already solved
    int attempts = 0;
    while (_isAlreadySorted(allBalls, colorCount, capacity) && attempts < 10) {
      allBalls = _seededShuffle(allBalls, levelNumber + attempts * 100);
      attempts++;
    }

    // Distribute balls into tubes
    List<TubeModel> tubes = [];
    int ballIndex = 0;
    for (int t = 0; t < colorCount; t++) {
      List<BallModel> tubeBalls = [];
      for (int i = 0; i < capacity; i++) {
        tubeBalls.add(allBalls[ballIndex++]);
      }
      tubes.add(TubeModel(balls: tubeBalls, capacity: capacity));
    }

    // Add empty tubes
    for (int e = 0; e < emptyTubes; e++) {
      tubes.add(TubeModel(balls: [], capacity: capacity));
    }

    return LevelModel(
      levelNumber: levelNumber,
      tubes: tubes,
      colorCount: colorCount,
      tubeCapacity: capacity,
    );
  }

  static bool _isAlreadySorted(
      List<BallModel> balls, int colorCount, int capacity) {
    for (int c = 0; c < colorCount; c++) {
      final start = c * capacity;
      final slice = balls.sublist(start, start + capacity);
      if (!slice.every((b) => b.colorIndex == c)) return false;
    }
    return true;
  }

  static List<BallModel> _seededShuffle(List<BallModel> list, int seed) {
    final result = List<BallModel>.from(list);
    // Simple seeded shuffle using linear congruential generator
    int state = seed + 12345;
    for (int i = result.length - 1; i > 0; i--) {
      state = (state * 1664525 + 1013904223) & 0xFFFFFFFF;
      int j = state % (i + 1);
      final temp = result[i];
      result[i] = result[j];
      result[j] = temp;
    }
    return result;
  }
}

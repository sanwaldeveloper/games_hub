import 'ball_model.dart';

class TubeModel {
  final List<BallModel> balls;
  final int capacity;

  const TubeModel({
    required this.balls,
    this.capacity = 4,
  });

  bool get isEmpty => balls.isEmpty;
  bool get isFull => balls.length >= capacity;
  int get ballCount => balls.length;

  BallModel? get topBall => balls.isEmpty ? null : balls.last;

  bool get isSorted {
    if (balls.isEmpty) return true;
    if (balls.length != capacity) return false;
    final firstColor = balls.first.colorIndex;
    return balls.every((b) => b.colorIndex == firstColor);
  }

  /// A tube is LOCKED only when it is fully sorted (all same color, full).
  /// Mixed-color full tubes can still have their top ball removed.
  bool get isLocked => isSorted && isFull;

  bool canAccept(BallModel ball) {
    if (isFull) return false;
    if (isEmpty) return true;
    return topBall!.colorIndex == ball.colorIndex;
  }

  TubeModel withBallAdded(BallModel ball) {
    return TubeModel(
      balls: [...balls, ball],
      capacity: capacity,
    );
  }

  TubeModel withTopBallRemoved() {
    if (balls.isEmpty) return this;
    return TubeModel(
      balls: balls.sublist(0, balls.length - 1),
      capacity: capacity,
    );
  }

  TubeModel copyWith({List<BallModel>? balls, int? capacity}) {
    return TubeModel(
      balls: balls ?? List.from(this.balls),
      capacity: capacity ?? this.capacity,
    );
  }

  Map<String, dynamic> toJson() => {
        'balls': balls.map((b) => b.toJson()).toList(),
        'capacity': capacity,
      };

  factory TubeModel.fromJson(Map<String, dynamic> json) {
    return TubeModel(
      balls: (json['balls'] as List)
          .map((b) => BallModel.fromJson(b as Map<String, dynamic>))
          .toList(),
      capacity: json['capacity'] as int? ?? 4,
    );
  }
}
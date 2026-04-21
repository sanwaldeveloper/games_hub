import 'dart:math';
import 'package:flame/components.dart';
import 'snake.dart';

class Enemy extends Snake {
  double directionChangeTimer = 0;
  final double directionChangeInterval = 1.5;
  final Random random = Random();

  Enemy({
    required super.gridPosition,
    required super.cellSize,
    required super.gridDimensions,
  }) : super(
          isPlayer: false,
          moveInterval: 0.2,
        ) {
    currentDirection = Direction.values[random.nextInt(Direction.values.length)];

    body = [
      gridPosition.clone(),
      Vector2(gridPosition.x - 1, gridPosition.y),
    ];
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameRef.gameOver || gameRef.isPaused) return;

    directionChangeTimer += dt;
    if (directionChangeTimer >= directionChangeInterval) {
      directionChangeTimer = 0;
      _changeDirectionRandomly();
    }
  }

  void _changeDirectionRandomly() {
    final possibleDirections = <Direction>[];

    for (var dir in Direction.values) {
      // ✅ FIX: public method call — no underscore
      if (isValidDirectionChange(dir)) {
        possibleDirections.add(dir);
      }
    }

    final safeDirections = <Direction>[];
    for (var dir in possibleDirections) {
      if (_isSafeDirection(dir)) {
        safeDirections.add(dir);
      }
    }

    if (safeDirections.isNotEmpty) {
      currentDirection = safeDirections[random.nextInt(safeDirections.length)];
    } else if (possibleDirections.isNotEmpty) {
      currentDirection = possibleDirections[random.nextInt(possibleDirections.length)];
    }
  }

  bool _isSafeDirection(Direction dir) {
    Vector2 testPosition = body.first.clone();

    switch (dir) {
      case Direction.up:
        testPosition.y -= 1;
        break;
      case Direction.down:
        testPosition.y += 1;
        break;
      case Direction.left:
        testPosition.x -= 1;
        break;
      case Direction.right:
        testPosition.x += 1;
        break;
    }

    return !gameRef.checkWallCollision(testPosition);
  }

  // ✅ FIX: @override sahi hai ab — public method override kar rahe hain
  @override
  bool isValidDirectionChange(Direction newDirection) {
    return super.isValidDirectionChange(newDirection);
  }
}
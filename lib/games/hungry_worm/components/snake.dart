import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../hungry_worm_game.dart';

enum Direction { up, down, left, right }

class Snake extends Component with HasGameRef<HungryWormGame> {
  Vector2 gridPosition;
  final double cellSize;
  final Vector2 gridDimensions;
  final bool isPlayer;

  List<Vector2> body = [];
  Direction currentDirection = Direction.right;
  Direction? pendingDirection;

  double moveTimer = 0;
  final double moveInterval;

  static const double defaultMoveInterval = 0.15;

  int segmentsToGrow = 0;

  Vector2? swipeStart;
  static const double swipeThreshold = 30.0;

  final List<Color> playerColors = [
    const Color(0xFF00ff88),
    const Color(0xFF00dd77),
    const Color(0xFF00bb66),
  ];

  Snake({
    required this.gridPosition,
    required this.cellSize,
    required this.gridDimensions,
    this.isPlayer = true,
    this.moveInterval = defaultMoveInterval,
  }) {
    body = [
      gridPosition.clone(),
      Vector2(gridPosition.x - 1, gridPosition.y),
      Vector2(gridPosition.x - 2, gridPosition.y),
    ];
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameRef.gameOver || gameRef.isPaused) return;

    moveTimer += dt;

    if (moveTimer >= moveInterval) {
      moveTimer = 0;
      _move();
    }
  }

  void _move() {
    // ✅ updated to use renamed public method
    if (pendingDirection != null && isValidDirectionChange(pendingDirection!)) {
      currentDirection = pendingDirection!;
      pendingDirection = null;
    }

    Vector2 newHead = body.first.clone();

    switch (currentDirection) {
      case Direction.up:
        newHead.y -= 1;
        break;
      case Direction.down:
        newHead.y += 1;
        break;
      case Direction.left:
        newHead.x -= 1;
        break;
      case Direction.right:
        newHead.x += 1;
        break;
    }

    if (gameRef.checkWallCollision(newHead)) {
      if (isPlayer) {
        gameRef.endGame();
      }
      return;
    }

    if (isPlayer && gameRef.checkEnemyCollision(newHead)) {
      gameRef.endGame();
      return;
    }

    if (isPlayer && newHead == gameRef.food?.gridPosition) {
      gameRef.onFoodEaten();
      segmentsToGrow += 1;
    }

    body.insert(0, newHead);

    if (segmentsToGrow > 0) {
      segmentsToGrow--;
    } else {
      body.removeLast();
    }
  }

  bool isValidDirectionChange(Direction newDirection) {
    if (currentDirection == Direction.up && newDirection == Direction.down) return false;
    if (currentDirection == Direction.down && newDirection == Direction.up) return false;
    if (currentDirection == Direction.left && newDirection == Direction.right) return false;
    if (currentDirection == Direction.right && newDirection == Direction.left) return false;
    return true;
  }

  void grow() {
    segmentsToGrow += 1;
  }

  void handleSwipeStart(Vector2 position) {
    swipeStart = position;
  }

  void handleSwipeUpdate(Vector2 position) {}

  void handleSwipeEnd() {
    if (swipeStart == null) return;
  }

  void detectSwipe(Vector2 start, Vector2 end) {
    final diff = end - start;

    if (diff.length < swipeThreshold) return;

    if (diff.x.abs() > diff.y.abs()) {
      pendingDirection = diff.x > 0 ? Direction.right : Direction.left;
    } else {
      pendingDirection = diff.y > 0 ? Direction.down : Direction.up;
    }

    swipeStart = null;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    for (int i = 0; i < body.length; i++) {
      final segment = body[i];
      final position = Vector2(segment.x * cellSize, segment.y * cellSize);

      final paint = Paint()..style = PaintingStyle.fill;

      if (isPlayer) {
        final colorIndex = min(i, playerColors.length - 1);
        paint.color = playerColors[colorIndex];
      } else {
        paint.color = i == 0 ? const Color(0xFFff4444) : const Color(0xFFdd3333);
      }

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          position.x + 1,
          position.y + 1,
          cellSize - 2,
          cellSize - 2,
        ),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, paint);

      if (i == 0) {
        final glowPaint = Paint()
          ..color = (isPlayer ? Colors.greenAccent : Colors.redAccent).withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawRRect(rect, glowPaint);
      }

      if (i == 0) {
        final eyePaint = Paint()..color = Colors.white;
        final pupilPaint = Paint()..color = Colors.black;

        double eyeOffsetX = 0;
        double eyeOffsetY = 0;

        switch (currentDirection) {
          case Direction.up:
            eyeOffsetY = -cellSize * 0.2;
            break;
          case Direction.down:
            eyeOffsetY = cellSize * 0.2;
            break;
          case Direction.left:
            eyeOffsetX = -cellSize * 0.2;
            break;
          case Direction.right:
            eyeOffsetX = cellSize * 0.2;
            break;
        }

        canvas.drawCircle(
          Offset(position.x + cellSize * 0.35 + eyeOffsetX,
              position.y + cellSize * 0.35 + eyeOffsetY),
          cellSize * 0.1,
          eyePaint,
        );
        canvas.drawCircle(
          Offset(position.x + cellSize * 0.35 + eyeOffsetX,
              position.y + cellSize * 0.35 + eyeOffsetY),
          cellSize * 0.05,
          pupilPaint,
        );

        canvas.drawCircle(
          Offset(position.x + cellSize * 0.65 + eyeOffsetX,
              position.y + cellSize * 0.35 + eyeOffsetY),
          cellSize * 0.1,
          eyePaint,
        );
        canvas.drawCircle(
          Offset(position.x + cellSize * 0.65 + eyeOffsetX,
              position.y + cellSize * 0.35 + eyeOffsetY),
          cellSize * 0.05,
          pupilPaint,
        );
      }
    }
  }
}

extension SnakeSwipeExtension on Snake {
  void updateSwipe(Vector2? start, Vector2 current) {
    if (start == null) return;
    detectSwipe(start, current);
  }
}
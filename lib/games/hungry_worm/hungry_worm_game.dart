import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/snake.dart';
import 'components/food.dart';
import 'components/enemy.dart';

class HungryWormGame extends FlameGame with PanDetector, HasCollisionDetection {
  static const int gridSize = 20;
  static const int initialEnemies = 2;

  // ✅ moveInterval constructor se aayega
  final double moveInterval;

  int score = 0;
  bool gameOver = false;
  bool isPaused = false;

  late Snake playerSnake;
  Food? food;
  final List<Enemy> enemies = [];

  late double cellSize;
  late Vector2 gridDimensions;

  late TextComponent scoreText;
  late TextComponent pausedText;

  Vector2? _swipeStart;

  // ✅ Default normal speed
  HungryWormGame({this.moveInterval = 0.20});

  @override
  Color backgroundColor() => const Color(0xFF1a1a2e);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    cellSize = size.x / gridSize;
    final rows = (size.y / cellSize).floor();
    gridDimensions = Vector2(gridSize.toDouble(), rows.toDouble());

    playerSnake = Snake(
      gridPosition: Vector2(
        (gridSize / 2).floorToDouble(),
        (rows / 2).floorToDouble(),
      ),
      cellSize: cellSize,
      gridDimensions: gridDimensions,
      isPlayer: true,
      moveInterval: moveInterval, // ✅ speed pass karo
    );
    add(playerSnake);

    _spawnFood();

    await Future.delayed(const Duration(milliseconds: 100));
    for (int i = 0; i < initialEnemies; i++) {
      _spawnEnemy();
    }

    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(20, 60), // ✅ thoda neeche — pause button se overlap na ho
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(blurRadius: 5.0, color: Colors.greenAccent, offset: Offset(0, 0)),
          ],
        ),
      ),
    );
    add(scoreText);

    pausedText = TextComponent(
      text: 'PAUSED',
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellowAccent,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    pausedText.priority = 100;
  }

  void _spawnFood() {
    final rand = Random();
    Vector2 pos;
    int attempts = 0;

    do {
      pos = Vector2(
        rand.nextInt(gridSize).toDouble(),
        rand.nextInt(gridDimensions.y.toInt()).toDouble(),
      );
      attempts++;
      if (attempts > 200) break;
    } while (_isPositionOccupied(pos));

    final newFood = Food(gridPosition: pos, cellSize: cellSize);
    food = newFood;
    add(newFood);
  }

  void _spawnEnemy() {
    final rand = Random();
    Vector2 pos;
    int attempts = 0;

    do {
      pos = Vector2(
        rand.nextInt(gridSize).toDouble(),
        rand.nextInt(gridDimensions.y.toInt()).toDouble(),
      );
      attempts++;
      if (attempts > 100) return;
    } while (
      _isPositionOccupied(pos) ||
      pos.distanceTo(playerSnake.gridPosition) <= 5
    );

    final enemy = Enemy(
      gridPosition: pos,
      cellSize: cellSize,
      gridDimensions: gridDimensions,
    );
    enemies.add(enemy);
    add(enemy);
  }

  bool _isPositionOccupied(Vector2 position) {
    if (playerSnake.body.any((s) => s == position)) return true;
    for (var e in enemies) {
      if (e.body.any((s) => s == position)) return true;
    }
    if (food != null && food!.gridPosition == position) return true;
    return false;
  }

  void onFoodEaten() {
    score += 10;
    scoreText.text = 'Score: $score';

    if (food != null) {
      remove(food!);
      food = null;
    }

    _spawnFood();
    playerSnake.grow();

    if (score % 50 == 0 && enemies.length < 8) {
      _spawnEnemy();
    }
  }

  void endGame() {
    if (gameOver) return;
    gameOver = true;
    pauseEngine();
    overlays.add('gameOver');
  }

  void togglePause() {
    isPaused = !isPaused;
    if (isPaused) {
      pauseEngine();
      add(pausedText);
    } else {
      resumeEngine();
      remove(pausedText);
    }
  }

  @override
  void onPanStart(DragStartInfo info) {
    if (gameOver || isPaused) return;
    _swipeStart = info.eventPosition.global.clone();
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (gameOver || isPaused) return;
    if (_swipeStart == null) return;

    final current = info.eventPosition.global;
    final diff = current - _swipeStart!;

    if (diff.length < 20) return;

    if (diff.x.abs() > diff.y.abs()) {
      playerSnake.pendingDirection =
          diff.x > 0 ? Direction.right : Direction.left;
    } else {
      playerSnake.pendingDirection =
          diff.y > 0 ? Direction.down : Direction.up;
    }

    _swipeStart = current.clone();
  }

  @override
  void onPanEnd(DragEndInfo info) {
    _swipeStart = null;
  }

  bool checkEnemyCollision(Vector2 position) {
    for (var e in enemies) {
      if (e.body.any((s) => s == position)) return true;
    }
    return false;
  }

  bool checkWallCollision(Vector2 position) {
    return position.x < 0 ||
        position.x >= gridSize ||
        position.y < 0 ||
        position.y >= gridDimensions.y;
  }
}
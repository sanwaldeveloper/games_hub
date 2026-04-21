import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Food extends Component {
  final Vector2 gridPosition;
  final double cellSize;

  // Animation
  double animationTimer = 0;
  final double animationSpeed = 3.0;

  Food({
    required this.gridPosition,
    required this.cellSize,
  });

  @override
  void update(double dt) {
    super.update(dt);
    animationTimer += dt * animationSpeed;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final position = Vector2(gridPosition.x * cellSize, gridPosition.y * cellSize);

    // Pulsing animation
    final scale = 1.0 + sin(animationTimer) * 0.15;
    final size = cellSize * 0.7 * scale;
    final offset = (cellSize - size) / 2;

    // Outer glow
    final glowPaint = Paint()
      ..color = Colors.yellowAccent.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawCircle(
      Offset(position.x + cellSize / 2, position.y + cellSize / 2),
      size / 2 + 5,
      glowPaint,
    );

    // Main food circle (gradient effect)
    final rect = Rect.fromLTWH(
      position.x + offset,
      position.y + offset,
      size,
      size,
    );

    final gradient = RadialGradient(
      colors: [
        const Color(0xFFffdd00),
        const Color(0xFFffaa00),
      ],
      stops: const [0.3, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(position.x + cellSize / 2, position.y + cellSize / 2),
      size / 2,
      paint,
    );

    // Shine effect
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(position.x + cellSize / 2 - size * 0.15, position.y + cellSize / 2 - size * 0.15),
      size * 0.15,
      shinePaint,
    );
  }
}

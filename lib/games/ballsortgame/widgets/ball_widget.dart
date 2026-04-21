import 'package:flutter/material.dart';
import '../models/ball_model.dart';

class BallWidget extends StatelessWidget {
  final BallModel ball;
  final double size;
  final bool isLifted;

  const BallWidget({
    super.key,
    required this.ball,
    this.size = 36,
    this.isLifted = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = kBallColors[ball.colorIndex % kBallColors.length];

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Main ball
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.3),
                radius: 0.85,
                colors: [
                  Color.lerp(color, Colors.white, 0.45)!,
                  color,
                  Color.lerp(color, Colors.black, 0.35)!,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isLifted ? 0.0 : 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          // White glare spot (top-left)
          Positioned(
            left: size * 0.2,
            top: size * 0.14,
            child: Container(
              width: size * 0.28,
              height: size * 0.18,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.65),
                borderRadius: BorderRadius.circular(size),
              ),
              transform: Matrix4.rotationZ(-0.5),
              transformAlignment: Alignment.center,
            ),
          ),
        ],
      ),
    );
  }
}
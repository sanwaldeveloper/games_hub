import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/ball_model.dart';

class BallArcAnimationOverlay extends StatefulWidget {
  final BallModel ball;
  final Offset startPosition; // top-center of source tube opening
  final Offset endPosition;   // top-center of target tube opening
  final VoidCallback onComplete;

  const BallArcAnimationOverlay({
    super.key,
    required this.ball,
    required this.startPosition,
    required this.endPosition,
    required this.onComplete,
  });

  @override
  State<BallArcAnimationOverlay> createState() =>
      _BallArcAnimationOverlayState();
}
   
class _BallArcAnimationOverlayState extends State<BallArcAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final List<_TrailPoint> _trail = [];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 480),
      vsync: this,
    );
    _ctrl.addListener(() {
      final pos = _computePosition(_ctrl.value);
      _trail.add(_TrailPoint(pos, _ctrl.value));
      // Keep only recent trail points
      while (_trail.length > 12) _trail.removeAt(0);
      setState(() {});
    });
    _ctrl.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Offset _computePosition(double t) {
    final start = widget.startPosition;
    final end = widget.endPosition;
    // How high above tubes the ball travels
    final double peakY = math.min(start.dy, end.dy) - 70;

    if (t <= 0.3) {
      // Phase 1: straight up from start
      final p = t / 0.3;
      final easedP = Curves.easeOut.transform(p);
      return Offset(start.dx, start.dy + (peakY - start.dy) * easedP);
    } else if (t <= 0.7) {
      // Phase 2: horizontal move at peak height
      final p = (t - 0.3) / 0.4;
      final easedP = Curves.easeInOut.transform(p);
      return Offset(
        start.dx + (end.dx - start.dx) * easedP,
        peakY,
      );
    } else {
      // Phase 3: straight down into target
      final p = (t - 0.7) / 0.3;
      final easedP = Curves.easeIn.transform(p);
      return Offset(end.dx, peakY + (end.dy - peakY) * easedP);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = kBallColors[widget.ball.colorIndex % kBallColors.length];
    final double ballSize = 36;

    final currentPos = _computePosition(_ctrl.value);

    return Stack(
      children: [
        // Trail
        CustomPaint(
          painter: _TrailPainter(
            trail: List.from(_trail),
            color: color,
            ballSize: ballSize,
          ),
          size: Size.infinite,
        ),
        // Ball
        Positioned(
          left: currentPos.dx - ballSize / 2,
          top: currentPos.dy - ballSize / 2,
          child: Container(
            width: ballSize,
            height: ballSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.35, -0.35),
                radius: 0.75,
                colors: [
                  Color.lerp(color, Colors.white, 0.55)!,
                  color,
                  Color.lerp(color, Colors.black, 0.3)!,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.7),
                  blurRadius: 18,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: ballSize * 0.28,
                height: ballSize * 0.18,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(ballSize),
                ),
                transform: Matrix4.rotationZ(-0.5),
                transformAlignment: Alignment.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrailPoint {
  final Offset position;
  final double t;
  _TrailPoint(this.position, this.t);
}

class _TrailPainter extends CustomPainter {
  final List<_TrailPoint> trail;
  final Color color;
  final double ballSize;

  _TrailPainter({required this.trail, required this.color, required this.ballSize});

  @override
  void paint(Canvas canvas, Size size) {
    if (trail.length < 2) return;

    for (int i = 1; i < trail.length; i++) {
      final opacity = (i / trail.length) * 0.45;
      final radius = (ballSize / 2) * (i / trail.length) * 0.7;
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.8);

      canvas.drawCircle(trail[i].position, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_TrailPainter old) => true;
}
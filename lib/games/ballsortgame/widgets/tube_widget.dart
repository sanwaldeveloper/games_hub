import 'package:flutter/material.dart';
import '../models/tube_model.dart';
import '../models/ball_model.dart';
import 'ball_widget.dart';

class TubeWidget extends StatelessWidget {
  final TubeModel tube;
  final int tubeIndex;
  final bool isSelected;
  final VoidCallback onTap;
  final double ballSize;
  final int capacity;
  final bool isDark;

  const TubeWidget({
    super.key,
    required this.tube,
    required this.tubeIndex,
    required this.isSelected,
    required this.onTap,
    this.ballSize = 40,
    this.capacity = 4,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final balls = tube.balls;
    final bool locked = tube.isLocked;
    const double gap = 2.0;
    final double innerH = ballSize * capacity + gap * (capacity - 1);
    final double tubeH = innerH + 16;
    final double tubeW = ballSize + 14;

    final Color borderColor = locked
        ? const Color(0xFF2ECC71)
        : isSelected
            ? const Color(0xFF6C63FF)
            : isDark
                ? Colors.white24
                : const Color(0xFFBBBBCC);

    final Color bgColor = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.white.withOpacity(0.55);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, isSelected ? -16 : 0, 0),
        child: CustomPaint(
          painter: _TubePainter(
            borderColor: borderColor,
            fillColor: bgColor,
            isSelected: isSelected,
            isLocked: locked,
            isDark: isDark,
          ),
          child: SizedBox(
            width: tubeW,
            height: tubeH,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(7, 8, 7, 8),
              child: ClipRect(
                child: SizedBox(
                  width: ballSize,
                  height: innerH,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: _buildSlots(balls, gap),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSlots(List<BallModel> balls, double gap) {
    final int emptySlots = capacity - balls.length;
    final List<Widget> children = [];

    for (int i = 0; i < emptySlots; i++) {
      children.add(SizedBox(width: ballSize, height: ballSize));
      if (i < emptySlots - 1 || balls.isNotEmpty) {
        children.add(SizedBox(height: gap));
      }
    }

    for (int i = 0; i < balls.length; i++) {
      children.add(BallWidget(
        ball: balls[i],
        size: ballSize,
        isLifted: isSelected && i == balls.length - 1,
      ));
      if (i < balls.length - 1) {
        children.add(SizedBox(height: gap));
      }
    }

    return children;
  }
}

class _TubePainter extends CustomPainter {
  final Color borderColor;
  final Color fillColor;
  final bool isSelected;
  final bool isLocked;
  final bool isDark;

  const _TubePainter({
    required this.borderColor,
    required this.fillColor,
    required this.isSelected,
    required this.isLocked,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double r = size.width / 2;
    final double sw = (isSelected || isLocked) ? 2.5 : 1.8;

    final Path uPath = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height - r)
      ..arcToPoint(Offset(size.width, size.height - r),
          radius: Radius.circular(r), clockwise: false)
      ..lineTo(size.width, 0);

    // Fill
    canvas.drawPath(uPath, Paint()..color = fillColor);

    // Glow
    if (isSelected) {
      canvas.drawPath(
        uPath,
        Paint()
          ..color = const Color(0xFF6C63FF).withOpacity(0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    } else if (isLocked) {
      canvas.drawPath(
        uPath,
        Paint()
          ..color = const Color(0xFF2ECC71).withOpacity(0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }

    // Glass highlight strip
    canvas.drawLine(
      Offset(sw + 2.5, 10),
      Offset(sw + 2.5, size.height - r - 6),
      Paint()
        ..color = Colors.white.withOpacity(isDark ? 0.1 : 0.55)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Border stroke
    canvas.drawPath(
      uPath,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_TubePainter old) =>
      old.borderColor != borderColor ||
      old.isSelected != isSelected ||
      old.isLocked != isLocked ||
      old.fillColor != fillColor;
}
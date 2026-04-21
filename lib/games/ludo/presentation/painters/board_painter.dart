import 'dart:math';
import 'package:flutter/material.dart';
import 'package:games_hub/games/ludo/domain/models/board_position.dart';
import 'package:games_hub/games/ludo/domain/models/player.dart';


class BoardPainter extends CustomPainter {
  final List<Player> players;
  final int currentPlayerIndex;
  final List<Token> validTokens;

  BoardPainter({
    required this.players,
    required this.currentPlayerIndex,
    required this.validTokens,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final boardSize = size.width;
    final cellSize = boardSize / 15;

    _drawBackground(canvas, size);
    _drawPlayerHomes(canvas, size, cellSize);
    _drawCenterPaths(canvas, size, cellSize);
    _drawSafeSpots(canvas, size, cellSize);
    _drawHomeStretch(canvas, size, cellSize);
    _drawTokens(canvas, size, cellSize);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, backgroundPaint);
  }

  void _drawPlayerHomes(Canvas canvas, Size size, double cellSize) {
    final homeSize = 6 * cellSize;
    final colors = [Colors.red, Colors.green, Colors.yellow, Colors.blue];
    final homePositions = [
      Offset.zero,
      Offset(size.width - homeSize, 0),
      Offset(size.width - homeSize, size.height - homeSize),
      Offset(0, size.height - homeSize),
    ];

    for (var i = 0; i < colors.length; i++) {
      _drawHome(canvas, homePositions[i], homeSize, colors[i]);
    }
  }

  void _drawHome(Canvas canvas, Offset offset, double size, Color color) {
    final homePaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final rect = Rect.fromLTWH(offset.dx, offset.dy, size, size);
    canvas.drawRect(rect, homePaint);
    canvas.drawRect(rect, borderPaint);

    // Draw token spots
    final spotPositions = [
      Offset(offset.dx + size * 0.25, offset.dy + size * 0.25),
      Offset(offset.dx + size * 0.75, offset.dy + size * 0.25),
      Offset(offset.dx + size * 0.25, offset.dy + size * 0.75),
      Offset(offset.dx + size * 0.75, offset.dy + size * 0.75),
    ];

    for (final spotOffset in spotPositions) {
      canvas.drawCircle(
        spotOffset,
        size * 0.15,
        Paint()
          ..color = color.withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        spotOffset,
        size * 0.15,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
  }

  void _drawCenterPaths(Canvas canvas, Size size, double cellSize) {
    final pathPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.fill;

    // Vertical path
    canvas.drawRect(
      Rect.fromLTWH(6 * cellSize, 0, 3 * cellSize, size.height),
      pathPaint,
    );

    // Horizontal path
    canvas.drawRect(
      Rect.fromLTWH(0, 6 * cellSize, size.width, 3 * cellSize),
      pathPaint,
    );

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (var i = 0; i <= 15; i++) {
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, size.height),
        gridPaint,
      );
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.width, i * cellSize),
        gridPaint,
      );
    }
  }

  void _drawSafeSpots(Canvas canvas, Size size, double cellSize) {
    // Define individual safe spots matching each player
    final playerSafeSpots = {
      Colors.red: [BoardPosition(1, 6)],
      Colors.green: [BoardPosition(8, 1)],
      Colors.yellow: [BoardPosition(13, 8)],
      Colors.blue: [BoardPosition(6, 13)]
    };

    // All safe spots
    final allSafeSpots = [
      BoardPosition(6, 2),
      BoardPosition(8, 1),
      BoardPosition(1, 6),
      BoardPosition(2, 8),
      BoardPosition(6, 13),
      BoardPosition(8, 12),
      BoardPosition(12, 6),
      BoardPosition(13, 8),
    ];

    // Paint objects

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final spot in allSafeSpots) {
      final center = Offset((spot.x + 0.5) * cellSize, (spot.y + 0.5) * cellSize);

      // Determine the color for this specific safe spot
      Color spotColor = Colors.grey[200]!;
      for (var entry in playerSafeSpots.entries) {
        if (entry.value.contains(spot)) {
          spotColor = entry.key.withOpacity(0.9);
          break;
        }
      }

      // Use specific player's color or the neutral color
      final safePaint = Paint()
        ..color = spotColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, cellSize * 0.4, safePaint);
      canvas.drawCircle(center, cellSize * 0.4, borderPaint);

      // Draw star pattern
      _drawStar(canvas, center, cellSize * 0.3, borderPaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double outerRadius, Paint paint) {
    // Number of points in the star
    const int numPoints = 5;
    // Ratio of the inner radius compared to the outer
    final double innerRadius = outerRadius * 0.5;
    final path = Path();
    double angle = -pi / 2; // Start at the top of the star

    for (int i = 0; i < numPoints * 2; i++) {
      // Toggle between outer and inner points
      final double radius = i.isEven ? outerRadius : innerRadius;

      // Calculate the position for each point
      final double x = center.dx + radius * cos(angle);
      final double y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Increment the angle
      angle += pi / numPoints; // 360 degrees divided by twice the number of points
    }
    path.close(); // Complete the star outline by closing the path
    canvas.drawPath(path, paint);
  }

  void _drawHomeStretch(Canvas canvas, Size size, double cellSize) {
    final colors = [Colors.red, Colors.green, Colors.yellow, Colors.blue];

    final center = Offset(7.5 * cellSize, 7.5 * cellSize);

    // Draw red triangle
    _drawTriangle(canvas, Offset(6 * cellSize, 6 * cellSize), center, Offset(6 * cellSize, 9 * cellSize), colors[0]);

    // Draw green triangle
    _drawTriangle(canvas, Offset(6 * cellSize, 6 * cellSize), center, Offset(9 * cellSize, 6 * cellSize), colors[1]);

    // Draw yellow triangle
    _drawTriangle(canvas, Offset(9 * cellSize, 6 * cellSize), center, Offset(9 * cellSize, 9 * cellSize), colors[2]);

    // Draw blue triangle
    _drawTriangle(canvas, Offset(6 * cellSize, 9 * cellSize), center, Offset(9 * cellSize, 9 * cellSize), colors[3]);


    // Red home stretch (horizontal, left)
    _drawColoredPath(canvas, 1 * cellSize, 7 * cellSize, 5 * cellSize, cellSize, colors[0]);
    // Gree  home stretch (vertical, top)
    _drawColoredPath(canvas, 7 * cellSize, 1 * cellSize, cellSize, 5 * cellSize, colors[1]);
    // Yellow home stretch (horizontal, right)
    _drawColoredPath(canvas, 9 * cellSize, 7 * cellSize, 5 * cellSize, cellSize, colors[2]);
    // Blue home stretch (vertical, bottom)
    _drawColoredPath(canvas, 7 * cellSize, 9 * cellSize, cellSize, 5 * cellSize, colors[3]);

  }

  void _drawTriangle(Canvas canvas, Offset start, Offset pivot, Offset end, Color color) {
    final path = Path()..moveTo(start.dx, start.dy);
    path.lineTo(pivot.dx, pivot.dy);
    path.lineTo(end.dx, end.dy);
    path.close();

    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  void _drawColoredPath(Canvas canvas, double x, double y, double width, double height, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final rect = Rect.fromLTWH(x, y, width, height);
    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);
  }

  void _drawTokens(Canvas canvas, Size size, double cellSize) {
    // Map to keep track of the number of tokens in each position
    final Map<BoardPosition, int> tokenCounts = {};

    // Increment token count for each position
    for (final player in players) {
      for (final token in player.tokens) {
        if (token.position != null) {
          tokenCounts[token.position!] = (tokenCounts[token.position!] ?? 0) + 1;
        }
      }
    }

    // Draw tokens with offset if the count at the position is greater than 1
    for (final player in players) {
      for (final token in player.tokens) {
        if (token.position != null) {
          final center = Offset(
            (token.position!.x + 0.5) * cellSize,
            (token.position!.y + 0.5) * cellSize,
          );

          // Check how many tokens are at this position
          final tokenCount = tokenCounts[token.position!] ?? 1;

          if (tokenCount > 1) {
            // Add a slight offset for each token in the stack for visibility
            final index = player.tokens.indexOf(token);
            final offsetAmount = (index % tokenCount) * cellSize * 0.1;
            final adjustedCenter = center + Offset(-offsetAmount, -offsetAmount);

            _drawToken(
              canvas,
              adjustedCenter,
              cellSize * 0.4,
              player.color,
              validTokens.contains(token),
              players[currentPlayerIndex].id == player.id,
            );
          } else {
            _drawToken(
              canvas,
              center,
              cellSize * 0.4,
              player.color,
              validTokens.contains(token),
              players[currentPlayerIndex].id == player.id,
            );
          }
        }
      }
    }
  }

  void _drawToken(
      Canvas canvas,
      Offset center,
      double radius,
      Color color,
      bool isValid,
      bool isCurrentPlayer,
      )
  {
    // Draw shadow
    canvas.drawCircle(
      center.translate(2, 2),
      radius,
      Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..style = PaintingStyle.fill,
    );

    // Draw token background
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    // Draw token border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Draw highlight for valid moves
    if (isValid) {
      canvas.drawCircle(
        center,
        radius * 1.2,
        Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0,
      );
    }

    // Draw current player indicator
    if (isCurrentPlayer) {
      canvas.drawCircle(
        center,
        radius * 0.6,
        Paint()
          ..color = Colors.white.withOpacity(0.8)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) {
    return oldDelegate.players != players ||
        oldDelegate.currentPlayerIndex != currentPlayerIndex ||
        oldDelegate.validTokens != validTokens;
  }
}

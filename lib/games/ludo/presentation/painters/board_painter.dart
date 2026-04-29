import 'dart:math';
import 'package:flutter/material.dart';
import 'package:games_hub/games/ludo/domain/models/board_position.dart';
import 'package:games_hub/games/ludo/domain/models/player.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Ludo Board Painter — matches real-world Ludo board (reference image)
//
// Corner layout (exactly like the image):
//   Top-Left    = RED    (0xFFE53935)
//   Top-Right   = GREEN  (0xFF43A047)
//   Bottom-Left = BLUE   (0xFF1E88E5)
//   Bottom-Right= YELLOW (0xFFFDD835)
//
// Home-stretch (colored lanes leading to center):
//   Red    → horizontal lane  row 7,  cols 1-5   (left side)
//   Green  → vertical lane    col 7,  rows 1-5   (top side)
//   Yellow → horizontal lane  row 7,  cols 9-13  (right side)
//   Blue   → vertical lane    col 7,  rows 9-13  (bottom side)
//
// Center finish triangles:
//   Red    → left  triangle
//   Green  → top   triangle
//   Yellow → right triangle
//   Blue   → bottom triangle
// ─────────────────────────────────────────────────────────────────────────────

class BoardPainter extends CustomPainter {
  final List<Player> players;
  final int currentPlayerIndex;
  final List<Token> validTokens;

  BoardPainter({
    required this.players,
    required this.currentPlayerIndex,
    required this.validTokens,
  });

  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color _red    = Color(0xFFE53935);
  static const Color _green  = Color(0xFF43A047);
  static const Color _blue   = Color(0xFF1E88E5);
  static const Color _yellow = Color.fromARGB(255, 222, 201, 9);
  static const Color _white  = Colors.white;

  // Light tints used for home-area fills
  static Color _tint(Color c) => c.withOpacity(0.18);

  // ── Paint helpers ─────────────────────────────────────────────────────────
  Paint _fill(Color c) => Paint()..color = c..style = PaintingStyle.fill;
  Paint _stroke(Color c, double w) =>
      Paint()..color = c..style = PaintingStyle.stroke..strokeWidth = w;

  // ── Main paint entry ─────────────────────────────────────────────────────
  @override
  void paint(Canvas canvas, Size size) {
    final cs = size.width / 15; // cell size

    _drawBoardBackground(canvas, size);
    _drawGrid(canvas, size, cs);
    _drawCornerHomes(canvas, size, cs);
    _drawHomeStretches(canvas, size, cs);
    _drawCenterFinish(canvas, size, cs);
    _drawSafeStars(canvas, size, cs);
    _drawArrows(canvas, size, cs);
    _drawTokens(canvas, size, cs);
  }

  // ── 1. White background ───────────────────────────────────────────────────
  void _drawBoardBackground(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, _fill(_white));
  }

  // ── 2. Grid lines ─────────────────────────────────────────────────────────
  void _drawGrid(Canvas canvas, Size size, double cs) {
    final p = _stroke(Colors.grey.shade400, 0.5);
    for (var i = 0; i <= 15; i++) {
      canvas.drawLine(Offset(i * cs, 0), Offset(i * cs, size.height), p);
      canvas.drawLine(Offset(0, i * cs), Offset(size.width, i * cs), p);
    }
  }

  // ── 3. Four corner home squares ───────────────────────────────────────────
  //
  //  Each home is a 6×6 cell square with:
  //   • Colored border + light-tint fill
  //   • Inner white rounded rectangle (the "token parking" area)
  //   • 4 token-spot circles (colored ring + white interior)
  //
  //  Positions (col, row), 0-indexed top-left:
  //   Red    → (0,0)
  //   Green  → (9,0)
  //   Blue   → (0,9)
  //   Yellow → (9,9)
  void _drawCornerHomes(Canvas canvas, Size size, double cs) {
    _drawHome(canvas, cs, col: 0, row: 0, color: _red);
    _drawHome(canvas, cs, col: 9, row: 0, color: _green);
    _drawHome(canvas, cs, col: 0, row: 9, color: _blue);
    _drawHome(canvas, cs, col: 9, row: 9, color: _yellow);
  }

  void _drawHome(Canvas canvas, double cs,
      {required int col, required int row, required Color color}) {
    final x = col * cs;
    final y = row * cs;
    final s = 6 * cs;

    // Outer colored square
    final rect = Rect.fromLTWH(x, y, s, s);
    canvas.drawRect(rect, _fill(_tint(color)));
    canvas.drawRect(rect, _stroke(color, 1.5));

    // Inner white rounded panel (inset 10%)
    final inset = s * 0.12;
    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x + inset, y + inset, s - inset * 2, s - inset * 2),
      const Radius.circular(8),
    );
    canvas.drawRRect(innerRect, _fill(_white));
    canvas.drawRRect(innerRect, _stroke(color.withOpacity(0.4), 1));

    // 4 token spots at 25% / 75% of home square
    final spotOffsets = [
      Offset(x + s * 0.27, y + s * 0.27),
      Offset(x + s * 0.73, y + s * 0.27),
      Offset(x + s * 0.27, y + s * 0.73),
      Offset(x + s * 0.73, y + s * 0.73),
    ];
    for (final o in spotOffsets) {
      final r = s * 0.155;
      // Outer ring
      canvas.drawCircle(o, r, _fill(color.withOpacity(0.25)));
      canvas.drawCircle(o, r, _stroke(color, 1.5));
      // Inner white dot
      canvas.drawCircle(o, r * 0.55, _fill(_white));
    }
  }

  // ── 4. Home-stretch colored lanes ─────────────────────────────────────────
  //
  //  These are the 5-cell lanes leading toward the center finish:
  //   Red    → row 7,  cols 1-5  (horizontal, left)
  //   Green  → col 7,  rows 1-5  (vertical,   top)
  //   Yellow → row 7,  cols 9-13 (horizontal, right)
  //   Blue   → col 7,  rows 9-13 (vertical,   bottom)
  void _drawHomeStretches(Canvas canvas, Size size, double cs) {
    // Red (left horizontal, row index 7)
    for (var col = 1; col <= 5; col++) {
      _drawStretchCell(canvas, cs, col: col, row: 7, color: _red);
    }
    // Green (top vertical, col index 7)
    for (var row = 1; row <= 5; row++) {
      _drawStretchCell(canvas, cs, col: 7, row: row, color: _green);
    }
    // Yellow (right horizontal, row index 7)
    for (var col = 9; col <= 13; col++) {
      _drawStretchCell(canvas, cs, col: col, row: 7, color: _yellow);
    }
    // Blue (bottom vertical, col index 7)
    for (var row = 9; row <= 13; row++) {
      _drawStretchCell(canvas, cs, col: 7, row: row, color: _blue);
    }
  }

  void _drawStretchCell(Canvas canvas, double cs,
      {required int col, required int row, required Color color}) {
    final rect = Rect.fromLTWH(col * cs, row * cs, cs, cs);
    canvas.drawRect(rect, _fill(color.withOpacity(0.85)));
    canvas.drawRect(rect, _stroke(Colors.white.withOpacity(0.4), 0.5));
  }

  // ── 5. Center finish (4 colored triangles + white circle) ─────────────────
  //
  //  The 3×3 center square (cols 6-8, rows 6-8) is split into 4 triangles:
  //   Red    → left
  //   Green  → top
  //   Yellow → right
  //   Blue   → bottom
  void _drawCenterFinish(Canvas canvas, Size size, double cs) {
    final tl = Offset(6 * cs, 6 * cs); // top-left
    final tr = Offset(9 * cs, 6 * cs); // top-right
    final bl = Offset(6 * cs, 9 * cs); // bottom-left
    final br = Offset(9 * cs, 9 * cs); // bottom-right
    final ce = Offset(7.5 * cs, 7.5 * cs); // center

    _drawTriangle(canvas, tl, ce, bl, _red);    // left
    _drawTriangle(canvas, tl, ce, tr, _green);  // top
    _drawTriangle(canvas, tr, ce, br, _yellow); // right
    _drawTriangle(canvas, bl, ce, br, _blue);   // bottom

    // White finish circle in the very center
    canvas.drawCircle(ce, cs * 0.9, _fill(_white));
    canvas.drawCircle(ce, cs * 0.9, _stroke(Colors.grey.shade300, 1));

    // Small colored star / trophy indicator
    _drawStar(canvas, ce, cs * 0.55, _stroke(Colors.grey.shade400, 1.2));
  }

  void _drawTriangle(Canvas canvas, Offset a, Offset b, Offset c, Color color) {
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..close();
    canvas.drawPath(path, _fill(color));
    canvas.drawPath(path, _stroke(Colors.white.withOpacity(0.6), 0.5));
  }

  // ── 6. Safe-spot stars ────────────────────────────────────────────────────
  //
  //  Standard Ludo safe spots (cannot be captured):
  //   (1,6), (6,1), (8,2), (13,6), (1,8), (6,13), (8,12), (13,8)
  //  Plus the colored start cells (col/row 1 of each entry column):
  //   Red entry    → (1,6)
  //   Green entry  → (8,1)  — already above
  //   Yellow entry → (13,8) — already above
  //   Blue entry   → (6,13) — already above
  void _drawSafeStars(Canvas canvas, Size size, double cs) {
    // Neutral safe spots (grey background + white star)
    final neutralSpots = [
      const BoardPosition(1, 6),
      const BoardPosition(6, 2),
      const BoardPosition(8, 1),
      const BoardPosition(2, 8),
      const BoardPosition(6, 12),
      const BoardPosition(8, 13),
      const BoardPosition(12, 6),
      const BoardPosition(13, 8),
    ];

    for (final sp in neutralSpots) {
      final center = Offset((sp.x + 0.5) * cs, (sp.y + 0.5) * cs);
      canvas.drawCircle(center, cs * 0.42, _fill(Colors.grey.shade200));
      canvas.drawCircle(center, cs * 0.42, _stroke(Colors.grey.shade400, 0.8));
      _drawStar(canvas, center, cs * 0.3,
          _stroke(Colors.grey.shade600, 1.2)..style = PaintingStyle.fill
            ..color = Colors.grey.shade500);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double outerR, Paint paint) {
    const numPoints = 5;
    final innerR = outerR * 0.45;
    final path = Path();
    var angle = -pi / 2.0;
    for (var i = 0; i < numPoints * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      angle += pi / numPoints;
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  // ── 7. Entry arrows ───────────────────────────────────────────────────────
  //
  //  Each color's starting entry cell has a colored arrow showing direction:
  //   Red    → (1,6)  arrow pointing RIGHT  →
  //   Green  → (8,1)  arrow pointing DOWN   ↓  (actually up on board — entry from top-right)
  //   Yellow → (13,8) arrow pointing LEFT   ←
  //   Blue   → (6,13) arrow pointing UP     ↑
  void _drawArrows(Canvas canvas, Size size, double cs) {
    _drawArrow(canvas, cs, col: 0, row: 6, color: _red,
        dx: 1, dy: 0); // right
    _drawArrow(canvas, cs, col: 8, row: 0, color: _green,
        dx: 0, dy: 1); // down
    _drawArrow(canvas, cs, col: 14, row: 8, color: _yellow,
        dx: -1, dy: 0); // left
    _drawArrow(canvas, cs, col: 6, row: 14, color: _blue,
        dx: 0, dy: -1); // up
  }

  void _drawArrow(Canvas canvas, double cs,
      {required int col, required int row,
        required Color color,
        required double dx,
        required double dy}) {
    final cx = (col + 0.5) * cs;
    final cy = (row + 0.5) * cs;
    final len = cs * 0.35;

    // Filled triangle arrow
    final norm = Offset(-dy, dx); // perpendicular
    final tip = Offset(cx + dx * len, cy + dy * len);
    final base1 = Offset(cx - dx * len + norm.dx * len * 0.5,
        cy - dy * len + norm.dy * len * 0.5);
    final base2 = Offset(cx - dx * len - norm.dx * len * 0.5,
        cy - dy * len - norm.dy * len * 0.5);

    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(base1.dx, base1.dy)
      ..lineTo(base2.dx, base2.dy)
      ..close();

    canvas.drawPath(path, _fill(color));
  }

  // ── 8. Tokens ─────────────────────────────────────────────────────────────
  void _drawTokens(Canvas canvas, Size size, double cs) {
    final Map<String, int> posCount = {};

    // Count tokens per position key
    for (final player in players) {
      for (final token in player.tokens) {
        if (token.position != null) {
          final key = '${token.position!.x},${token.position!.y}';
          posCount[key] = (posCount[key] ?? 0) + 1;
        }
      }
    }

    final Map<String, int> posIndex = {};

    for (final player in players) {
      for (final token in player.tokens) {
        if (token.position == null) continue;

        final key = '${token.position!.x},${token.position!.y}';
        final count = posCount[key] ?? 1;
        final idx = posIndex[key] ?? 0;
        posIndex[key] = idx + 1;

        final base = Offset(
          (token.position!.x + 0.5) * cs,
          (token.position!.y + 0.5) * cs,
        );

        // Offset stacked tokens slightly
        final offset = count > 1
            ? Offset(
          (idx % 2 == 0 ? -1 : 1) * cs * 0.12,
          (idx < 2 ? -1 : 1) * cs * 0.12,
        )
            : Offset.zero;

        _drawToken(
          canvas,
          base + offset,
          cs * 0.38,
          player.color,
          validTokens.contains(token),
          players[currentPlayerIndex].id == player.id,
        );
      }
    }
  }

  void _drawToken(Canvas canvas, Offset center, double radius, Color color,
      bool isValid, bool isCurrentPlayer) {
    // Shadow
    canvas.drawCircle(center.translate(1.5, 2),
        radius, _fill(Colors.black.withOpacity(0.22)));

    // Main body
    canvas.drawCircle(center, radius, _fill(color));

    // White ring
    canvas.drawCircle(center, radius, _stroke(_white, 2));

    // Inner shine
    canvas.drawCircle(center, radius * 0.55,
        _fill(_white.withOpacity(0.35)));

    // Valid move highlight
    if (isValid) {
      canvas.drawCircle(center, radius * 1.3,
          _stroke(_white, 2.5)..color = Colors.yellow);
    }

    // Current player inner dot
    if (isCurrentPlayer) {
      canvas.drawCircle(center, radius * 0.3, _fill(_white.withOpacity(0.9)));
    }
  }

  @override
  bool shouldRepaint(BoardPainter old) =>
      old.players != players ||
          old.currentPlayerIndex != currentPlayerIndex ||
          old.validTokens != validTokens;
}
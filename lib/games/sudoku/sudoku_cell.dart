import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:games_hub/games/sudoku/sudoku_controller.dart';

class SudokuCell extends StatefulWidget {
  final int row;
  final int col;

  const SudokuCell({super.key, required this.row, required this.col});

  @override
  State<SudokuCell> createState() => _SudokuCellState();
}

class _SudokuCellState extends State<SudokuCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  int _lastValue = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animController.reverse();
        }
      });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<SudokuController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final int value      = ctrl.userBoard[widget.row][widget.col];
    final bool prefilled = ctrl.isPreFilled(widget.row, widget.col);
    final bool selected  = ctrl.isSelected(widget.row, widget.col);
    final bool highlighted = ctrl.isHighlighted(widget.row, widget.col);
    final bool error     = ctrl.isError[widget.row][widget.col];
    final bool sameNum   = ctrl.sameNumber(widget.row, widget.col);

    // Trigger scale animation when value changes
    if (value != _lastValue && value != 0) {
      _lastValue = value;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _animController.forward();
      });
    }

    // ── Colors ───────────────────────────────────────────────────────────
    Color bgColor;
    if (selected) {
      bgColor = isDark
          ? const Color(0xFF4A90D9)
          : const Color(0xFF1565C0);
    } else if (error) {
      bgColor = isDark
          ? const Color(0xFF7B1A1A)
          : const Color(0xFFFFCDD2);
    } else if (sameNum && value != 0) {
      bgColor = isDark
          ? const Color(0xFF2A4A6B)
          : const Color(0xFFBBDEFB);
    } else if (highlighted) {
      bgColor = isDark
          ? const Color(0xFF1E2A3A)
          : const Color(0xFFE3F2FD);
    } else {
      bgColor = isDark
          ? const Color(0xFF1A1F2E)
          : Colors.white;
    }

    Color textColor;
    if (error) {
      textColor = isDark ? Colors.red[300]! : Colors.red[700]!;
    } else if (prefilled) {
      textColor = isDark ? Colors.white : const Color(0xFF1A237E);
    } else {
      textColor = isDark ? const Color(0xFF64B5F6) : const Color(0xFF1565C0);
    }

    return GestureDetector(
      onTap: () => ctrl.selectCell(widget.row, widget.col),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: bgColor,
          border: _buildBorder(context),
        ),
        child: Center(
          child: value == 0
              ? null
              : ScaleTransition(
                  scale: _scaleAnim,
                  child: Text(
                    '$value',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: prefilled ? FontWeight.w800 : FontWeight.w600,
                      color: textColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Border _buildBorder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final thinColor = isDark
        ? const Color(0xFF2E3A4E)
        : const Color(0xFFB0BEC5);
    final thickColor = isDark
        ? const Color(0xFF546E7A)
        : const Color(0xFF455A64);

    const double thin = 0.5;
    const double thick = 2.0;

    int r = widget.row;
    int c = widget.col;

    return Border(
      top: BorderSide(
          color: (r % 3 == 0) ? thickColor : thinColor,
          width: (r % 3 == 0) ? thick : thin),
      left: BorderSide(
          color: (c % 3 == 0) ? thickColor : thinColor,
          width: (c % 3 == 0) ? thick : thin),
      bottom: BorderSide(
          color: (r == 8 || r % 3 == 2) ? thickColor : thinColor,
          width: (r == 8 || r % 3 == 2) ? thick : thin),
      right: BorderSide(
          color: (c == 8 || c % 3 == 2) ? thickColor : thinColor,
          width: (c == 8 || c % 3 == 2) ? thick : thin),
    );
  }
}
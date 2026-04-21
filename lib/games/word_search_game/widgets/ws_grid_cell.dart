// games/word_search/widgets/ws_grid_cell.dart

import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../utils/ws_theme.dart';

class WSGridCell extends StatelessWidget {
  final String letter;
  final WSCellPosition position;
  final bool isSelected;
  final bool isFound;
  final bool isHint;
  final Color? foundColor;
  final double cellSize;

  const WSGridCell({
    super.key,
    required this.letter,
    required this.position,
    required this.isSelected,
    required this.isFound,
    required this.isHint,
    required this.cellSize,
    this.foundColor,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.transparent;
    Color txtColor = Colors.white70;
    double scale = 1.0;

    if (isFound && foundColor != null) {
      bgColor = foundColor!;
      txtColor = Colors.white;
    } else if (isSelected) {
      bgColor = WSTheme.primary;
      txtColor = Colors.white;
      scale = 1.1;
    } else if (isHint) {
      bgColor = WSTheme.accent.withOpacity(0.8);
      txtColor = Colors.white;
      scale = 1.1;
    }

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: cellSize,
        height: cellSize,
        margin: const EdgeInsets.all(1.2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(cellSize * 0.2),
          border: Border.all(
            color: isSelected
                ? WSTheme.primary
                : isFound
                    ? (foundColor ?? Colors.transparent)
                    : Colors.white12,
            width: isSelected || isFound ? 2 : 1,
          ),
          boxShadow: isSelected || isFound
              ? [
                  BoxShadow(
                    color: (isFound ? foundColor ?? WSTheme.primary : WSTheme.primary)
                        .withOpacity(0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: cellSize * 0.42,
              fontWeight: FontWeight.w700,
              color: txtColor,
            ),
          ),
        ),
      ),
    );
  }
}

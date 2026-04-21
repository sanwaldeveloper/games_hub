// games/word_search/widgets/ws_word_grid.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../services/ws_game_provider.dart';
import '../utils/ws_theme.dart';
import 'ws_grid_cell.dart';

class WSWordGrid extends StatefulWidget {
  const WSWordGrid({super.key});

  @override
  State<WSWordGrid> createState() => _WSWordGridState();
}

class _WSWordGridState extends State<WSWordGrid> {
  final GlobalKey _gridKey = GlobalKey();
  double? _cellSize;

  void _calcCellSize(WSGameProvider gp) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = _gridKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        final size = box.size;
        final gridSize = gp.gameState!.grid.length;
        if (mounted) {
          setState(() {
            _cellSize = (size.width / gridSize) - 2.4;
          });
        }
      }
    });
  }

  WSCellPosition? _posFromOffset(Offset local, int gridSize) {
    if (_cellSize == null) return null;
    final totalCell = _cellSize! + 2.4;
    final row = (local.dy / totalCell).floor();
    final col = (local.dx / totalCell).floor();
    if (row < 0 || row >= gridSize || col < 0 || col >= gridSize) return null;
    return WSCellPosition(row, col);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WSGameProvider>(builder: (context, gp, _) {
      final gs = gp.gameState;
      if (gs == null) return const SizedBox();

      _calcCellSize(gp);

      final gridSize = gs.grid.length;
      final cellSize = _cellSize ?? 28.0;

      // Build found-color map
      final foundColorMap = <WSCellPosition, Color>{};
      int colorIdx = 0;
      for (final pw in gs.placedWords) {
        if (pw.isFound) {
          final color = WSTheme.wordColors[colorIdx % WSTheme.wordColors.length];
          for (final cell in pw.cells) foundColorMap[cell] = color;
          colorIdx++;
        }
      }

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (d) {
          final pos = _posFromOffset(d.localPosition, gridSize);
          if (pos != null) gp.startSelection(pos);
        },
        onPanUpdate: (d) {
          final pos = _posFromOffset(d.localPosition, gridSize);
          if (pos != null) gp.updateSelection(pos);
        },
        onPanEnd: (_) => gp.endSelection(),
        child: Container(
          key: _gridKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(gridSize, (row) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(gridSize, (col) {
                  final pos = WSCellPosition(row, col);
                  return WSGridCell(
                    letter: gs.grid[row][col],
                    position: pos,
                    isSelected: gp.currentSelection.contains(pos),
                    isFound: foundColorMap.containsKey(pos),
                    isHint: gs.hintCell == pos,
                    foundColor: foundColorMap[pos],
                    cellSize: cellSize,
                  );
                }),
              );
            }),
          ),
        ),
      );
    });
  }
}

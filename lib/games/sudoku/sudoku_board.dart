import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:games_hub/games/sudoku/sudoku_cell.dart';
import 'package:games_hub/games/sudoku/sudoku_controller.dart';

class SudokuBoard extends StatelessWidget {
  const SudokuBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final isPaused = context.watch<SudokuController>().isPaused;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.5)
                  : Colors.blueGrey.withOpacity(0.2),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 9,
                ),
                itemCount: 81,
                itemBuilder: (context, index) {
                  final row = index ~/ 9;
                  final col = index % 9;
                  return SudokuCell(row: row, col: col);
                },
              ),
              if (isPaused)
                Container(
                  color: isDark
                      ? Colors.black.withOpacity(0.85)
                      : Colors.white.withOpacity(0.92),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pause_circle_filled_rounded,
                          size: 64,
                          color: isDark
                              ? const Color(0xFF4A90D9)
                              : const Color(0xFF1565C0),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'PAUSED',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 6,
                            color: isDark
                                ? const Color(0xFF4A90D9)
                                : const Color(0xFF1565C0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
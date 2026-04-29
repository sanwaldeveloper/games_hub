// ============================================================
// lib/games/sliding_puzzle/tile_widget.dart
// Individual tile UI widget
// ============================================================

import 'package:flutter/material.dart';

class SlidingTileWidget extends StatelessWidget {
  final int value;
  final int gridSize;
  final double tileSize;
  final VoidCallback onTap;
  final bool solved;

  const SlidingTileWidget({
    super.key,
    required this.value,
    required this.gridSize,
    required this.tileSize,
    required this.onTap,
    this.solved = false,
  });

  @override
  Widget build(BuildContext context) {
    if (value == 0) {
      return SizedBox(width: tileSize, height: tileSize);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        width: tileSize,
        height: tileSize,
        decoration: BoxDecoration(
          color: solved ? const Color(0xFF4CAF50) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: tileSize * 0.38,
              fontWeight: FontWeight.bold,
              color: solved ? Colors.white : const Color(0xFF1A237E),
              letterSpacing: 1.2,
            ),
            child: Text(value.toString()),
          ),
        ),
      ),
    );
  }
}

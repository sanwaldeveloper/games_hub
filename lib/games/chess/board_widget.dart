// ============================================================
// board_widget.dart
// Renders the 8x8 chess board, pieces, highlights, and labels
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_controller.dart';
import 'piece_model.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, gc, _) {
        return AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF3D2B1F), width: 3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: List.generate(8, (row) {
                return Expanded(
                  child: Row(
                    children: List.generate(8, (col) {
                      return Expanded(
                        child: _buildSquare(context, gc, row, col),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSquare(
      BuildContext context, GameController gc, int row, int col) {
    final pos = Position(row, col);
    final piece = gc.board[row][col];
    final isLight = (row + col) % 2 == 0;
    final isSelected = gc.selectedPosition == pos;
    final isValidMove = gc.validMoves.contains(pos);
    final isLastMove = gc.moveHistory.isNotEmpty &&
        (gc.moveHistory.last.from == pos || gc.moveHistory.last.to == pos);

    // Color determination
    Color squareColor;
    if (isSelected) {
      squareColor = const Color(0xFFF6F669); // Bright yellow for selected
    } else if (isLastMove) {
      squareColor =
          isLight ? const Color(0xFFCDD26A) : const Color(0xFFADB053);
    } else {
      squareColor =
          isLight ? const Color(0xFFF0D9B5) : const Color(0xFFB58863);
    }

    return GestureDetector(
      onTap: () => gc.onSquareTapped(pos),
      child: Container(
        color: squareColor,
        child: Stack(
          children: [
            // Rank & file labels
            if (col == 0)
              Positioned(
                top: 2,
                left: 3,
                child: Text(
                  '${8 - row}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isLight
                        ? const Color(0xFFB58863)
                        : const Color(0xFFF0D9B5),
                  ),
                ),
              ),
            if (row == 7)
              Positioned(
                bottom: 2,
                right: 3,
                child: Text(
                  String.fromCharCode('a'.codeUnitAt(0) + col),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isLight
                        ? const Color(0xFFB58863)
                        : const Color(0xFFF0D9B5),
                  ),
                ),
              ),

            // Valid move indicator
            if (isValidMove)
              Center(
                child: piece != null
                    ? Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black.withOpacity(0.35),
                            width: 3,
                          ),
                        ),
                      )
                    : Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.18),
                        ),
                      ),
              ),

            // Chess piece
            if (piece != null)
              Center(
                child: _PieceWidget(piece: piece),
              ),
          ],
        ),
      ),
    );
  }
}

class _PieceWidget extends StatelessWidget {
  final ChessPiece piece;

  const _PieceWidget({required this.piece});

  @override
  Widget build(BuildContext context) {
    final isWhite = piece.color == PieceColor.white;

    return LayoutBuilder(builder: (context, constraints) {
      double size = constraints.maxWidth * 0.82;
      return Stack(
        alignment: Alignment.center,
        children: [
          // Shadow / outline for contrast
          Text(
            piece.symbol,
            style: TextStyle(
              fontSize: size,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.5
                ..color =
                    isWhite ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.3),
            ),
          ),
          // Piece fill
          Text(
            piece.symbol,
            style: TextStyle(
              fontSize: size,
              color: isWhite ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
        ],
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_controller.dart';
import 'board_widget.dart';
import 'piece_model.dart';

class ChessGameScreen extends StatelessWidget {
  const ChessGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C1810),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFF0D9B5)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Text('♟', style: TextStyle(fontSize: 28)),
            SizedBox(width: 10),
            Text(
              'Flutter Chess',
              style: TextStyle(
                color: Color(0xFFF0D9B5),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          Consumer<GameController>(
            builder: (ctx, gc, _) => IconButton(
              tooltip: gc.aiEnabled ? 'AI: ON' : 'AI: OFF',
              icon: Icon(
                gc.aiEnabled ? Icons.smart_toy : Icons.smart_toy_outlined,
                color: gc.aiEnabled
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFF0D9B5),
              ),
              onPressed: gc.toggleAi,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWide = constraints.maxWidth > 600;
            return isWide
                ? _buildWideLayout(context)
                : _buildNarrowLayout(context);
          },
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Column(
      children: [
        _StatusPanel(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: const BoardWidget(),
        ),
        _ControlPanel(),
        const SizedBox(height: 8),
        _CapturedPiecesPanel(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: const BoardWidget(),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _StatusPanel(),
                const SizedBox(height: 16),
                _ControlPanel(),
                const SizedBox(height: 16),
                _CapturedPiecesPanel(),
                const SizedBox(height: 16),
                _MoveHistoryPanel(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class _StatusPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (_, gc, __) {
        final isGameOver = gc.gameStatus == GameStatus.checkmate ||
            gc.gameStatus == GameStatus.stalemate;
        final isCheck = gc.gameStatus == GameStatus.check;

        return Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isGameOver
                ? const Color(0xFF4A1010)
                : isCheck
                    ? const Color(0xFF4A3010)
                    : const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isGameOver
                  ? Colors.red.shade700
                  : isCheck
                      ? Colors.orange.shade600
                      : const Color(0xFF3C3C3E),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isGameOver)
                Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: gc.currentTurn == PieceColor.white
                        ? Colors.white
                        : Colors.black,
                    border: Border.all(color: Colors.grey, width: 1.5),
                  ),
                ),
              if (isGameOver) const Text('🏆 ', style: TextStyle(fontSize: 20)),
              Text(
                gc.statusMessage,
                style: TextStyle(
                  color: isGameOver
                      ? Colors.red.shade300
                      : isCheck
                          ? Colors.orange.shade300
                          : const Color(0xFFF0D9B5),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}


// CONTROL PANEL


class _ControlPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (_, gc, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.refresh,
                label: 'Restart',
                color: const Color(0xFF5C3A1E),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: const Color(0xFF2C2C2E),
                      title: const Text('New Game',
                          style: TextStyle(color: Color(0xFFF0D9B5))),
                      content: const Text(
                        'Start a new game? Current progress will be lost.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            gc.restartGame();
                            Navigator.pop(context);
                          },
                          child: const Text('New Game',
                              style: TextStyle(color: Color(0xFFF0D9B5))),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionButton(
                icon: Icons.undo,
                label: 'Undo',
                color: const Color(0xFF1E3A5C),
                onTap: gc.moveHistory.isEmpty ? null : gc.undoMove,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey.shade800 : color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: onTap == null
                ? Colors.grey.shade700
                : color.withOpacity(0.8),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: onTap == null ? Colors.grey : const Color(0xFFF0D9B5),
                size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: onTap == null ? Colors.grey : const Color(0xFFF0D9B5),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// CAPTURED PIECES PANEL


class _CapturedPiecesPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (_, gc, __) {
        final whiteCaptured = <ChessPiece>[];
        final blackCaptured = <ChessPiece>[];

        for (final move in gc.moveHistory) {
          if (move.capturedPiece != null) {
            if (move.capturedPiece!.color == PieceColor.white) {
              blackCaptured.add(move.capturedPiece!);
            } else {
              whiteCaptured.add(move.capturedPiece!);
            }
          }
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _captureRow('White captured:', whiteCaptured),
              const SizedBox(height: 4),
              _captureRow('Black captured:', blackCaptured),
            ],
          ),
        );
      },
    );
  }

  Widget _captureRow(String label, List<ChessPiece> pieces) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            pieces.map((p) => p.symbol).join(' '),
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}


// MOVE HISTORY PANEL


class _MoveHistoryPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (_, gc, __) {
        final moves = gc.moveHistory;
        return Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Move History',
                  style: TextStyle(
                    color: Color(0xFFF0D9B5),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const Divider(color: Colors.grey),
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: (moves.length / 2).ceil(),
                    itemBuilder: (_, i) {
                      int moveNum = moves.length ~/ 2 - i;
                      int idx = moveNum * 2 - 1;
                      String white = idx - 1 < moves.length
                          ? _moveLabel(moves[idx - 1])
                          : '';
                      String black =
                          idx < moves.length ? _moveLabel(moves[idx]) : '';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 28,
                              child: Text('$moveNum.',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ),
                            Expanded(
                              child: Text(white,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ),
                            Expanded(
                              child: Text(black,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _moveLabel(ChessMove move) {
    final cols = 'abcdefgh';
    final fromLabel = '${cols[move.from.col]}${8 - move.from.row}';
    final toLabel = '${cols[move.to.col]}${8 - move.to.row}';
    final capture = move.capturedPiece != null ? 'x' : '-';
    return '${move.movedPiece.symbol} $fromLabel$capture$toLabel';
  }
}
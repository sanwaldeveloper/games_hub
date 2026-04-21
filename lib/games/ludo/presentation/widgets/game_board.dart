import 'package:flutter/material.dart';
import 'package:games_hub/games/ludo/constants.dart';
import 'package:games_hub/games/ludo/domain/models/player.dart';
import 'package:games_hub/games/ludo/presentation/painters/board_painter.dart';
import 'package:games_hub/games/ludo/presentation/provider/game_provider.dart';
import 'package:provider/provider.dart';

class GameBoard extends StatelessWidget {
  final List<Player> players;
  final int currentPlayerIndex;

  const GameBoard({
    super.key,
    required this.players,
    required this.currentPlayerIndex,
  });

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth * 0.9;
        return GestureDetector(
          onTapDown: (details) => _handleTap(context, details, size, game),
          child: Center(
            child: Container(
              key: gameBoardKey,
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: CustomPaint(
                painter: BoardPainter(
                  players: players,
                  currentPlayerIndex: currentPlayerIndex,
                  validTokens: game.validTokens,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTap(
      BuildContext context, TapDownDetails details, double size, GameProvider game) {
    if (game.validTokens.isEmpty) return;

    final renderBox =
        gameBoardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = renderBox.globalToLocal(details.globalPosition);
    final cellSize = size / 15;
    final x = (localPosition.dx / cellSize).floor();
    final y = (localPosition.dy / cellSize).floor();

    for (final token in game.validTokens) {
      if (token.position?.x == x && token.position?.y == y) {
        context.read<GameProvider>().selectToken(token);
        break;
      }
    }
  }
}
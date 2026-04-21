import 'package:flutter/material.dart';
import 'package:games_hub/games/ludo/presentation/provider/game_provider.dart';
import 'package:games_hub/games/ludo/presentation/widgets/dice_widget.dart';
import 'package:games_hub/games/ludo/presentation/widgets/game_board.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' ', style: GoogleFonts.poppins()),
      ),
      body: Consumer<GameProvider>(
        builder: (context, game, _) {
          if (game.isGameOver) {
            return _buildGameOverScreen(context, game);
          }

          final isP1Turn = game.currentPlayerIndex == 0;
          final isP2Turn = game.currentPlayerIndex == 1;
          final isP3Turn = game.currentPlayerIndex == 2;
          final isP4Turn = game.currentPlayerIndex == 3;

          return Column(
            children: [




              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    

                    // ── Top row: Player 1 (left) | Player 2 (right) ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Player 1 dice — only active on P1 turn
                          _PlayerDicePanel(
                            label: 'Player 1',
                            playerIndex: 0,
                            currentIndex: game.currentPlayerIndex,
                            diceValue: isP1Turn ? game.diceValue : null,
                            canRoll: isP1Turn && game.canRollDice,
                            onRoll: () =>
                                context.read<GameProvider>().rollDice(),
                          ),
                          // Player 2 dice — only active on P2 turn
                          _PlayerDicePanel(
                            label: 'Player 2',
                            playerIndex: 1,
                            currentIndex: game.currentPlayerIndex,
                            diceValue: isP2Turn ? game.diceValue : null,
                            canRoll: isP2Turn && game.canRollDice,
                            onRoll: () =>
                                context.read<GameProvider>().rollDice(),
                            reversed: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Board ──
                    GameBoard(
                      players: game.players,
                      currentPlayerIndex: game.currentPlayerIndex,
                    ),

                    const SizedBox(height: 8),

                    // ── Bottom row: Player 4 (left) | Player 3 (right) ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _PlayerDicePanel(
                            label: 'Player 4',
                            playerIndex: 3,
                            currentIndex: game.currentPlayerIndex,
                            diceValue: isP4Turn ? game.diceValue : null,
                            canRoll: isP4Turn && game.canRollDice,
                            onRoll: () =>
                                context.read<GameProvider>().rollDice(),
                          ),
                          _PlayerDicePanel(
                            label: 'Player 3',
                            playerIndex: 2,
                            currentIndex: game.currentPlayerIndex,
                            diceValue: isP3Turn ? game.diceValue : null,
                            canRoll: isP3Turn && game.canRollDice,
                            onRoll: () =>
                                context.read<GameProvider>().rollDice(),
                            reversed: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGameOverScreen(BuildContext context, GameProvider game) {
    final duration = DateTime.now().difference(game.startTime!);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
        ),
      ),
      child: Center(
        child: Card(
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Game Over!',
                    style: GoogleFonts.rubikVinyl(
                        fontSize: 48, color: Colors.black87)),
                const SizedBox(height: 20),
                Text('Winner: Player ${game.currentPlayerIndex + 1}',
                    style: GoogleFonts.poppins(
                        fontSize: 24, color: Colors.black87)),
                const SizedBox(height: 10),
                Text(
                    'Time: ${duration.inMinutes}m ${duration.inSeconds % 60}s',
                    style: GoogleFonts.poppins(
                        fontSize: 20, color: Colors.black54)),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.replay),
                  label: Text('Play Again',
                      style: GoogleFonts.poppins(
                          fontSize: 20, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A small panel showing the player label + their dice.
/// When [reversed] is true, dice is on the left of the label (right-side players).
class _PlayerDicePanel extends StatelessWidget {
  final String label;
  final int playerIndex;
  final int currentIndex;
  final int? diceValue;
  final bool canRoll;
  final VoidCallback onRoll;
  final bool reversed;

  const _PlayerDicePanel({
    required this.label,
    required this.playerIndex,
    required this.currentIndex,
    required this.diceValue,
    required this.canRoll,
    required this.onRoll,
    this.reversed = false,
  });

  bool get isMyTurn => playerIndex == currentIndex;

  @override
  Widget build(BuildContext context) {
    final labelWidget = Text(
      label,
      style: GoogleFonts.poppins(
        fontWeight: isMyTurn ? FontWeight.bold : FontWeight.normal,
        color: isMyTurn ? Colors.green : Colors.black54,
      ),
    );

    final diceWidget = DiceWidget(
      value: diceValue,
      enabled: canRoll,
      onRoll: onRoll,
    );

    final children = reversed
        ? [diceWidget, const SizedBox(width: 6), labelWidget]
        : [labelWidget, const SizedBox(width: 6), diceWidget];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isMyTurn
            ? Colors.green.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isMyTurn ? Colors.green : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
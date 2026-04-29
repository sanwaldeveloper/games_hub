import 'package:flutter/material.dart';
import 'package:games_hub/games/ludo/presentation/provider/game_provider.dart';
import 'package:games_hub/games/ludo/presentation/widgets/dice_widget.dart';
import 'package:games_hub/games/ludo/presentation/widgets/game_board.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  static const _playerColors = [
    Color(0xFF4CAF50), // Player 1 — green
    Color(0xFFFF9800), // Player 2 — orange
    Color(0xFF6C63FF), // Player 3 — purple
    Color(0xFFF44336), // Player 4 — red
  ];

  static const _playerEmojis = ['🟢', '🟠', '🟣', '🔴'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
          ).createShader(bounds),
          child: const Text(
            'Ludo Master',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.timer_outlined, color: Colors.white70, size: 14),
                    SizedBox(width: 4),
                    _GameTimer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0E17),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: Consumer<GameProvider>(
          builder: (context, game, _) {
            if (game.isGameOver) {
              return _buildGameOverScreen(context, game);
            }

            return SafeArea(
              child: Column(
                children: [
                  // ── Turn Indicator Banner ──
                  _TurnBanner(
                    playerIndex: game.currentPlayerIndex,
                    playerColor: _playerColors[game.currentPlayerIndex],
                    playerEmoji:
                        _playerEmojis[game.currentPlayerIndex],
                    glowAnim: _glow,
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ── Top row: Player 1 (left) | Player 2 (right) ──
                          Row(
                            children: [
                              Expanded(
                                child: _PlayerDicePanel(
                                  label: 'Player 1',
                                  playerIndex: 0,
                                  currentIndex: game.currentPlayerIndex,
                                  diceValue: game.currentPlayerIndex == 0
                                      ? game.diceValue
                                      : null,
                                  canRoll: game.currentPlayerIndex == 0 &&
                                      game.canRollDice,
                                  onRoll: () =>
                                      context.read<GameProvider>().rollDice(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _PlayerDicePanel(
                                  label: 'Player 2',
                                  playerIndex: 1,
                                  currentIndex: game.currentPlayerIndex,
                                  diceValue: game.currentPlayerIndex == 1
                                      ? game.diceValue
                                      : null,
                                  canRoll: game.currentPlayerIndex == 1 &&
                                      game.canRollDice,
                                  onRoll: () =>
                                      context.read<GameProvider>().rollDice(),
                                  reversed: true,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // ── Board ──
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6C63FF)
                                      .withOpacity(0.25),
                                  blurRadius: 30,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: GameBoard(
                                players: game.players,
                                currentPlayerIndex: game.currentPlayerIndex,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // ── Bottom row: Player 4 (left) | Player 3 (right) ──
                          Row(
                            children: [
                              Expanded(
                                child: _PlayerDicePanel(
                                  label: 'Player 4',
                                  playerIndex: 3,
                                  currentIndex: game.currentPlayerIndex,
                                  diceValue: game.currentPlayerIndex == 3
                                      ? game.diceValue
                                      : null,
                                  canRoll: game.currentPlayerIndex == 3 &&
                                      game.canRollDice,
                                  onRoll: () =>
                                      context.read<GameProvider>().rollDice(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _PlayerDicePanel(
                                  label: 'Player 3',
                                  playerIndex: 2,
                                  currentIndex: game.currentPlayerIndex,
                                  diceValue: game.currentPlayerIndex == 2
                                      ? game.diceValue
                                      : null,
                                  canRoll: game.currentPlayerIndex == 2 &&
                                      game.canRollDice,
                                  onRoll: () =>
                                      context.read<GameProvider>().rollDice(),
                                  reversed: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Bottom Status Bar ──
                  _BottomStatusBar(game: game),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGameOverScreen(BuildContext context, GameProvider game) {
    final duration = DateTime.now().difference(game.startTime!);
    final winnerColor = _playerColors[game.currentPlayerIndex];
    final winnerEmoji = _playerEmojis[game.currentPlayerIndex];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F0E17), Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy glow container
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      winnerColor.withOpacity(0.4),
                      winnerColor.withOpacity(0.0),
                    ],
                  ),
                ),
                child: const Center(
                  child: Text('🏆', style: TextStyle(fontSize: 64)),
                ),
              ),

              const SizedBox(height: 16),

              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                ).createShader(bounds),
                child: const Text(
                  'Game Over!',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Winner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      winnerColor.withOpacity(0.25),
                      winnerColor.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: winnerColor.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      winnerEmoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Player ${game.currentPlayerIndex + 1} Wins!',
                      style: TextStyle(
                        color: winnerColor,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Time: ${duration.inMinutes}m ${duration.inSeconds % 60}s',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Stats row
              Row(
                children: [
                  Expanded(
                    child: _StatChip(
                      icon: Icons.casino_rounded,
                      label: 'Total Rolls',
                      value: '—',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatChip(
                      icon: Icons.timer,
                      label: 'Duration',
                      value: '${duration.inMinutes}m',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context)
                        ..pop()
                        ..pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.12),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white24,
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          '🏠  Home',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF6C63FF).withOpacity(0.85),
                              const Color(0xFFFF6584).withOpacity(0.85),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C63FF).withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          '🔄  Play Again',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Turn Banner ───────────────────────────────────────────────────────
class _TurnBanner extends StatelessWidget {
  final int playerIndex;
  final Color playerColor;
  final String playerEmoji;
  final Animation<double> glowAnim;

  const _TurnBanner({
    required this.playerIndex,
    required this.playerColor,
    required this.playerEmoji,
    required this.glowAnim,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnim,
      builder: (_, __) => Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              playerColor.withOpacity(0.2 * glowAnim.value),
              playerColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: playerColor.withOpacity(0.5 * glowAnim.value),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(playerEmoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Text(
              'Player ${playerIndex + 1}\'s Turn',
              style: TextStyle(
                color: playerColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: playerColor,
                boxShadow: [
                  BoxShadow(
                    color: playerColor.withOpacity(glowAnim.value),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Game Timer ────────────────────────────────────────────────────────
class _GameTimer extends StatefulWidget {
  const _GameTimer();

  @override
  State<_GameTimer> createState() => _GameTimerState();
}

class _GameTimerState extends State<_GameTimer> {
  late final Stream<int> _stream;
  final _start = DateTime.now();

  @override
  void initState() {
    super.initState();
    _stream = Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now().difference(_start).inSeconds,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _stream,
      initialData: 0,
      builder: (_, snap) {
        final s = snap.data!;
        final m = s ~/ 60;
        final sec = s % 60;
        return Text(
          '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}

// ─── Bottom Status Bar ─────────────────────────────────────────────────
class _BottomStatusBar extends StatelessWidget {
  final GameProvider game;

  const _BottomStatusBar({required this.game});

  static const _playerColors = [
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF6C63FF),
    Color(0xFFF44336),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.06),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          game.players.length,
          (i) => _MiniPlayerStatus(
            index: i,
            color: _playerColors[i],
            isActive: i == game.currentPlayerIndex,
            tokensDone: 0, // replace with actual data from game
          ),
        ),
      ),
    );
  }
}

class _MiniPlayerStatus extends StatelessWidget {
  final int index;
  final Color color;
  final bool isActive;
  final int tokensDone;

  const _MiniPlayerStatus({
    required this.index,
    required this.color,
    required this.isActive,
    required this.tokensDone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isActive ? 32 : 24,
          height: isActive ? 32 : 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? color : color.withOpacity(0.25),
            boxShadow: isActive
                ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10)]
                : null,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : color.withOpacity(0.7),
                fontWeight: FontWeight.bold,
                fontSize: isActive ? 14 : 11,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            4,
            (t) => Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: t < tokensDone ? color : color.withOpacity(0.2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Stat Chip ─────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Player Dice Panel ───────────────────────────────────────────────
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

  static const _playerColors = [
    Color(0xFF4CAF50), // Player 1 — green
    Color(0xFFFF9800), // Player 2 — orange
    Color(0xFF6C63FF), // Player 3 — purple
    Color(0xFFF44336), // Player 4 — red
  ];

  static const _playerEmojis = ['🟢', '🟠', '🟣', '🔴'];

  @override
  Widget build(BuildContext context) {
    final color = _playerColors[playerIndex];

    final labelCol = Column(
      crossAxisAlignment:
          reversed ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _playerEmojis[playerIndex] + '  ' + label,
          style: TextStyle(
            fontWeight: isMyTurn ? FontWeight.bold : FontWeight.normal,
            color: isMyTurn ? color : Colors.white38,
            fontSize: 12,
          ),
        ),
        if (isMyTurn)
          Text(
            'Your turn!',
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );

    final diceWidget = DiceWidget(
      value: diceValue,
      enabled: canRoll,
      onRoll: onRoll,
    );

    final children = reversed
        ? [diceWidget, const SizedBox(width: 8), Flexible(child: labelCol)]
        : [Flexible(child: labelCol), const SizedBox(width: 8), diceWidget];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: isMyTurn
            ? LinearGradient(colors: [
                color.withOpacity(0.22),
                color.withOpacity(0.06),
              ])
            : const LinearGradient(
                colors: [Colors.transparent, Colors.transparent]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMyTurn ? color.withOpacity(0.6) : Colors.white10,
          width: isMyTurn ? 1.5 : 1,
        ),
        boxShadow: isMyTurn
            ? [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
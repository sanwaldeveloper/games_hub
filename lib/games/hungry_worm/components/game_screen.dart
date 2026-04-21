import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:games_hub/games/hungry_worm/hungry_worm_game.dart';

enum GameSpeed { normal, medium, hard }

extension GameSpeedInterval on GameSpeed {
  double get interval {
    switch (this) {
      case GameSpeed.normal:
        return 0.20;
      case GameSpeed.medium:
        return 0.13;
      case GameSpeed.hard:
        return 0.07;
    }
  }
}

class HungryWormGameScreen extends StatefulWidget {
  const HungryWormGameScreen({super.key});

  @override
  State<HungryWormGameScreen> createState() => _HungryWormGameScreenState();
}

class _HungryWormGameScreenState extends State<HungryWormGameScreen> {
  HungryWormGame? _game;
  GameSpeed? _selectedSpeed;

  void _startGame(GameSpeed speed) {
    setState(() {
      _selectedSpeed = speed;
      _game = HungryWormGame(moveInterval: speed.interval);
    });
  }

  void _restartGame() {
    final speed = _selectedSpeed ?? GameSpeed.normal;
    setState(() {
      _game = HungryWormGame(moveInterval: speed.interval);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_game == null) {
      return _SpeedSelectionScreen(onSpeedSelected: _startGame);
    }

    return Scaffold(
      body: SafeArea(
        child: GameWidget(
          key: ValueKey(_game.hashCode),
          game: _game!,
          overlayBuilderMap: {
            'gameOver': (context, g) => _GameOverOverlay(
                  game: g as HungryWormGame,
                  onRestart: _restartGame,
                  onExit: () => Navigator.of(context).pop(),
                ),
            'pauseButton': (context, g) => _PauseButton(
                  game: g as HungryWormGame,
                  onExit: () => Navigator.of(context).pop(),
                ),
          },
          initialActiveOverlays: const ['pauseButton'],
        ),
      ),
    );
  }
}

// ─── Speed Selection ─────────────────────────────────────────────────────────

class _SpeedSelectionScreen extends StatelessWidget {
  final void Function(GameSpeed) onSpeedSelected;
  const _SpeedSelectionScreen({required this.onSpeedSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🐍 Hungry Worm',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                  shadows: [
                    Shadow(blurRadius: 15, color: Colors.green, offset: Offset(0, 0)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select Difficulty',
                style: TextStyle(fontSize: 18, color: Colors.white54),
              ),
              const SizedBox(height: 48),
              _SpeedButton(
                label: 'Normal',
                subtitle: 'Relaxed pace — beginner friendly',
                color: Colors.green,
                icon: Icons.sentiment_satisfied_alt,
                onTap: () => onSpeedSelected(GameSpeed.normal),
              ),
              const SizedBox(height: 16),
              _SpeedButton(
                label: 'Medium',
                subtitle: 'Moderate challenge',
                color: Colors.orange,
                icon: Icons.sentiment_neutral,
                onTap: () => onSpeedSelected(GameSpeed.medium),
              ),
              const SizedBox(height: 16),
              _SpeedButton(
                label: 'Hard',
                subtitle: 'Fast — experts only!',
                color: Colors.red,
                icon: Icons.local_fire_department,
                onTap: () => onSpeedSelected(GameSpeed.hard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeedButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _SpeedButton({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, // ✅ overflow fix
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
          boxShadow: [BoxShadow(color: color.withOpacity(0.25), blurRadius: 14)],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded( // ✅ text overflow fix
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.6), size: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Game Over ───────────────────────────────────────────────────────────────

class _GameOverOverlay extends StatelessWidget {
  final HungryWormGame game;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const _GameOverOverlay({
    required this.game,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'GAME OVER',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  shadows: [
                    Shadow(blurRadius: 10, color: Colors.redAccent, offset: Offset(0, 0)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.greenAccent, width: 2),
                ),
                child: Column(
                  children: [
                    const Text('Final Score',
                        style: TextStyle(fontSize: 20, color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text(
                      '${game.score}',
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              Row(
                children: [
                  Expanded( // ✅ Expanded — overflow nahi hoga
                    child: ElevatedButton.icon(
                      onPressed: onExit,
                      icon: const Icon(Icons.exit_to_app, size: 20),
                      label: const Text('EXIT',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded( // ✅ Expanded
                    child: ElevatedButton.icon(
                      onPressed: onRestart,
                      icon: const Icon(Icons.replay, size: 20),
                      label: const Text('RESTART',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
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

// ─── Pause Button ────────────────────────────────────────────────────────────

class _PauseButton extends StatelessWidget {
  final HungryWormGame game;
  final VoidCallback onExit;

  const _PauseButton({required this.game, required this.onExit});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Exit Game?'),
                  content: const Text('Return to game hub?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('CANCEL')),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          onExit();
                        },
                        child: const Text('EXIT')),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.arrow_back, size: 28, color: Colors.white),
            style: IconButton.styleFrom(
                backgroundColor: Colors.black54, padding: const EdgeInsets.all(10)),
          ),
          IconButton(
            onPressed: () => game.togglePause(),
            icon: Icon(
              game.isPaused ? Icons.play_arrow : Icons.pause,
              size: 28,
              color: Colors.white,
            ),
            style: IconButton.styleFrom(
                backgroundColor: Colors.black54, padding: const EdgeInsets.all(10)),
          ),
        ],
      ),
    );
  }
}
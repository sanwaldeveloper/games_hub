import 'package:flutter/material.dart';
import 'package:games_hub/games/ludo/injection.dart';
import 'package:games_hub/games/ludo/presentation/provider/game_provider.dart';
import 'package:games_hub/games/ludo/presentation/screens/game_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LudoHomeScreen extends StatefulWidget {
  const LudoHomeScreen({super.key});

  @override
  State<LudoHomeScreen> createState() => _LudoHomeScreenState();
}

class _LudoHomeScreenState extends State<LudoHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        title: const Text(
          'Select Players',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0E17), Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
            
                // Pulsing icon
                ScaleTransition(
                  scale: _pulse,
                  child: const Text('🎲', style: TextStyle(fontSize: 70)),
                ),
                const SizedBox(height: 16),
            
                // Gradient title
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                  ).createShader(bounds),
                  child: const Text(
                    'Ludo\nMaster',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
            
                Text(
                  'Choose players, start the game!',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6), fontSize: 16),
                ),
                const SizedBox(height: 30),
            
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'SELECT PLAYERS',
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2),
                  ),
                ),
                const SizedBox(height: 16),
            
                // Player count buttons
                ..._playerOptions.map((opt) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 6),
                      child: _PlayerButton(
                        emoji: opt['emoji'] as String,
                        label: opt['label'] as String,
                        subtitle: opt['subtitle'] as String,
                        color: opt['color'] as Color,
                        onTap: () =>
                            _startGame(context, opt['count'] as int),
                      ),
                    )),
            
                
                Text(
                  'Tap a mode to begin your Ludo journey!',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.3), fontSize: 13),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _playerOptions = [
    {
      'count': 2,
      'emoji': '😊',
      'label': '2 Players',
      'subtitle': 'Classic duel · Easy mode',
      'color': Color(0xFF4CAF50),
    },
    {
      'count': 3,
      'emoji': '🤔',
      'label': '3 Players',
      'subtitle': 'Triple threat · Medium',
      'color': Color(0xFFFF9800),
    },
    {
      'count': 4,
      'emoji': '🔥',
      'label': '4 Players',
      'subtitle': 'Full chaos · Hard mode',
      'color': Color(0xFFF44336),
    },
  ];

  void _startGame(BuildContext context, int playerCount) {
    final provider = getIt<GameProvider>()..startGame(playerCount);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const GameScreen(),
        ),
      ),
    );
  }
}

// ─── Player Button (same style as _DifficultyButton) ───────────────
class _PlayerButton extends StatelessWidget {
  final String emoji, label, subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PlayerButton({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            color.withOpacity(0.25),
            color.withOpacity(0.1),
          ]),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: color.withOpacity(0.5), width: 1.5),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: color.withOpacity(0.7), size: 18),
          ],
        ),
      ),
    );
  }
}
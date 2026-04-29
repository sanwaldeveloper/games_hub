import 'package:flutter/material.dart';
import 'package:games_hub/games/tictactoe/views/tictacteo3by3game.dart';
import 'package:games_hub/games/tictactoe/views/tictactoe6by6.dart';
import 'package:games_hub/games/tictactoe/views/tictactoe9by9game.dart';
import 'package:games_hub/games_hub_view.dart';
// ... your existing imports

class SellectLevelScreen extends StatefulWidget {
  const SellectLevelScreen({super.key});
  @override
  State<SellectLevelScreen> createState() => _SellectLevelScreenState();
}

class _SellectLevelScreenState extends State<SellectLevelScreen> {
  void _showGridPickerForAI(BuildContext context, bool aiMode) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1A1A2E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            aiMode ? 'Choose Grid — vs AI' : 'Choose Grid — vs Player',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _SheetBtn(label: '3×3 Classic', color: const Color(0xFF4CAF50),
              onTap: () { Navigator.pop(context); Navigator.push(context,
                  MaterialPageRoute(builder: (_) => NeonTicTacToeGame(isAIMode: aiMode))); }),
          const SizedBox(height: 10),
          _SheetBtn(label: '6×6 Extended', color: const Color(0xFFFF9800),
              onTap: () { Navigator.pop(context); Navigator.push(context,
                  MaterialPageRoute(builder: (_) => TicTacToe6x6Game(isAIMode: aiMode))); }),
          const SizedBox(height: 10),
          _SheetBtn(label: '9×9 Expert', color: const Color(0xFFF44336),
              onTap: () { Navigator.pop(context); Navigator.push(context,
                  MaterialPageRoute(builder: (_) => TicTacToe9x9Game(isAIMode: aiMode))); }),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}
 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFF0F0E17),
    body: Container(
      width: double.infinity,
      height: double.infinity,
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
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _NavBtn(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
                    const Text('TIC TAC TOE',
                        style: TextStyle(color: Colors.white60, fontSize: 13,
                            fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                    _NavBtn(
                      icon: Icons.home_outlined,
                      onTap: () => Navigator.pushAndRemoveUntil(context,
                          MaterialPageRoute(builder: (_) => GameHubScreen()), (r) => false),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              const Text('✖', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 10),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                ).createShader(bounds),
                child: const Text('Select Level',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
              const SizedBox(height: 4),
              Text('Choose your grid size & challenge',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),

              const SizedBox(height: 28),
              const _SectionLabel(text: 'GRID SIZE'),
              const SizedBox(height: 12),

              _LevelCard(
                emoji: '😊', label: 'Easy', meta: '3 × 3 grid  ·  Classic mode',
                color: const Color(0xFF4CAF50),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NeonTicTacToeGame())),
              ),
              const SizedBox(height: 10),
              _LevelCard(
                emoji: '🤔', label: 'Medium', meta: '6 × 6 grid  ·  Extended play',
                color: const Color(0xFFFF9800),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TicTacToe6x6Game())),
              ),
              const SizedBox(height: 10),
              _LevelCard(
                emoji: '🔥', label: 'Hard', meta: '9 × 9 grid  ·  Expert challenge',
                color: const Color(0xFFF44336),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TicTacToe9x9Game())),
              ),

              const SizedBox(height: 20),
              Container(height: 1, color: Colors.white.withOpacity(0.07),
                  margin: const EdgeInsets.symmetric(horizontal: 24)),
              const SizedBox(height: 18),

              const _SectionLabel(text: 'GAME MODE'),
              const SizedBox(height: 12),

             // Player vs AI buttons mein isAIMode: true pass karo:
_ModeButton(
  leftIcon: Icons.person,
  rightIcon: Icons.android,
  label: 'Player  vs  AI',
  onTap: () => _showGridPickerForAI(context, true),
),
const SizedBox(height: 10),
_ModeButton(
  leftIcon: Icons.person,
  rightIcon: Icons.person,
  label: 'Player  vs  Player',
  onTap: () => _showGridPickerForAI(context, false),
),
              const SizedBox(height: 30),  // ← Spacer() ki jagah fixed SizedBox
              Text('Tap a grid size, then choose your game mode!',
                  style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 12)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
  );
}}

// ── NavBtn ───────────────────────────────────────────────────────────
class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ── SectionLabel ─────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2)),
      ),
    );
  }
}

// ── LevelCard ────────────────────────────────────────────────────────
class _LevelCard extends StatelessWidget {
  final String emoji, label, meta;
  final Color color;
  final VoidCallback onTap;
  const _LevelCard({
    required this.emoji,
    required this.label,
    required this.meta,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              color.withOpacity(0.22),
              color.withOpacity(0.08),
            ]),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.45), width: 1.5),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            color: color,
                            fontSize: 19,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(meta,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: color.withOpacity(0.7), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ── ModeButton ───────────────────────────────────────────────────────
class _ModeButton extends StatelessWidget {
  final IconData leftIcon, rightIcon;
  final String label;
  final VoidCallback onTap;
  const _ModeButton({
    required this.leftIcon,
    required this.rightIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFE8B64A),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(leftIcon, color: Colors.black, size: 20),
              const SizedBox(width: 10),
              Text(label,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Icon(rightIcon, color: Colors.black, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
class _SheetBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SheetBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withOpacity(0.3), color.withOpacity(0.1)]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.6), width: 1.5),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
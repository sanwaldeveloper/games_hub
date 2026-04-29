// games/word_search/screens/ws_level_complete_screen.dart

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/levels_data.dart';
import '../models/level_model.dart';
import '../services/ws_game_provider.dart';
import '../utils/ws_theme.dart';
import 'ws_game_screen.dart';

class WSLevelCompleteScreen extends StatefulWidget {
  const WSLevelCompleteScreen({super.key});

  @override
  State<WSLevelCompleteScreen> createState() => _WSLevelCompleteScreenState();
}

class _WSLevelCompleteScreenState extends State<WSLevelCompleteScreen> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4));
    Future.delayed(
        const Duration(milliseconds: 200), () => _confetti.play());
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  int _stars(int score) {
    if (score >= 200) return 3;
    if (score >= 100) return 2;
    return 1;
  }

  String _fmtTime(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  WordSearchLevelModel? _nextLevel(WordSearchLevelModel current) {
    final idx = wsAllLevels.indexWhere((l) => l.id == current.id);
    if (idx == -1 || idx >= wsAllLevels.length - 1) return null;
    return wsAllLevels[idx + 1];
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<WSGameProvider>();
    final gs = gp.gameState;
    final level = gp.currentLevel;

    if (gs == null || level == null) {
      return const Scaffold(
        backgroundColor: WSTheme.bgDark,
        body: Center(child: CircularProgressIndicator(color: WSTheme.primary)),
      );
    }

    final best = gp.getBestScore(level.id) ?? gs.score;
    final next = _nextLevel(level);
    final stars = _stars(gs.score);

    return Scaffold(
      backgroundColor: WSTheme.bgDark,
      body: Stack(children: [
        // BG gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [WSTheme.primary.withOpacity(0.12), WSTheme.bgDark],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            colors: WSTheme.wordColors,
            numberOfParticles: 25,
            gravity: 0.15,
          ),
        ),

        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const SizedBox(height: 20),

              // Trophy
              const Text('🏆', style: TextStyle(fontSize: 80)),

              const SizedBox(height: 16),
              const Text('Level Complete!',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800,
                      color: Colors.white)),
              Text('${level.themeIcon} ${level.theme}',
                  style: const TextStyle(fontSize: 15, color: Colors.white54)),

              const SizedBox(height: 28),

              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    i < stars
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 48,
                    color: i < stars
                        ? WSTheme.warning
                        : Colors.white24,
                  ),
                )),
              ),

              const SizedBox(height: 28),

              // Stats card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: WSTheme.card,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3),
                        blurRadius: 14, offset: const Offset(0, 6)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Stat(icon: '⏱️', value: _fmtTime(gs.elapsedSeconds), label: 'Time'),
                    Container(width: 1, height: 50, color: Colors.white12),
                    _Stat(icon: '⭐', value: '${gs.score}', label: 'Score'),
                    Container(width: 1, height: 50, color: Colors.white12),
                    _Stat(icon: '🏅', value: '$best', label: 'Best'),
                    Container(width: 1, height: 50, color: Colors.white12),
                    _Stat(icon: '🔤', value: '${gs.totalWords}', label: 'Words'),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ✅ FIX: Next Level — provider pass karo
              if (next != null)
                _ActionBtn(
                  label: 'Next Level  →',
                  color: WSTheme.primary,
                  onTap: () {
                    final provider = context.read<WSGameProvider>();
                    provider.loadLevel(next);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: provider,
                          child: const WSGameScreen(),
                        ),
                      ),
                    );
                  },
                ),

              if (next != null) const SizedBox(height: 12),

              Row(children: [
                // ✅ FIX: Replay — provider pass karo
                Expanded(child: _ActionBtn(
                  label: 'Replay',
                  color: WSTheme.warning,
                  onTap: () {
                    final provider = context.read<WSGameProvider>();
                    provider.loadLevel(level);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: provider,
                          child: const WSGameScreen(),
                        ),
                      ),
                    );
                  },
                )),
                const SizedBox(width: 12),
                // Menu — popUntil theek hai, koi fix nahi chahiye
                Expanded(child: _ActionBtn(
                  label: 'Menu',
                  color: WSTheme.accent,
                  onTap: () => Navigator.popUntil(context, (r) => r.isFirst),
                )),
              ]),

              const SizedBox(height: 24),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final String icon, value, label;
  const _Stat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(icon, style: const TextStyle(fontSize: 22)),
      const SizedBox(height: 2),
      Text(value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
              color: Colors.white)),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
    ]);
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.35),
                blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}
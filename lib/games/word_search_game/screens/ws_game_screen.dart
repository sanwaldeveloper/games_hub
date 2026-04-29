// games/word_search/screens/ws_game_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../services/ws_game_provider.dart';
import '../utils/ws_theme.dart';
import '../widgets/ws_word_grid.dart';
import '../widgets/ws_word_list.dart';
import 'ws_level_complete_screen.dart';

class WSGameScreen extends StatefulWidget {
  const WSGameScreen({super.key});

  @override
  State<WSGameScreen> createState() => _WSGameScreenState();
}

class _WSGameScreenState extends State<WSGameScreen> {
  late ConfettiController _confetti;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: Provider context issue — Consumer ke andar provider read karo
    return Consumer<WSGameProvider>(builder: (context, gp, _) {
      final gs = gp.gameState;
      final level = gp.currentLevel;

      if (gs == null || level == null) {
        return const Scaffold(
          backgroundColor: WSTheme.bgDark,
          body: Center(child: CircularProgressIndicator(color: WSTheme.primary)),
        );
      }

      // Navigate to complete screen
      if (gs.isComplete && gp.showConfetti && !_navigated) {
        _navigated = true;
        _confetti.play();
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) {
            gp.resetConfetti();
            // ✅ FIX: Provider ko WSLevelCompleteScreen tak pass karo
            final provider = context.read<WSGameProvider>();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: provider,
                  child: const WSLevelCompleteScreen(),
                ),
              ),
            );
          }
        });
      }

      return Scaffold(
        backgroundColor: WSTheme.bgDark,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          // ✅ FIX: Overflow fix — Flexible wrap karo title Row mein
          title: Row(children: [
            Text(level.themeIcon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                level.theme,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
          actions: [
            // Timer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: WSTheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                const Icon(Icons.timer_outlined, size: 15, color: WSTheme.primary),
                const SizedBox(width: 4),
                Text(gp.formattedTime,
                    style: const TextStyle(
                        color: WSTheme.primary,
                        fontWeight: FontWeight.w700, fontSize: 14)),
              ]),
            ),
            IconButton(
              icon: const Icon(Icons.pause_circle_outline_rounded,
                  color: Colors.white),
              onPressed: () => _showPauseMenu(context, gp),
            ),
          ],
        ),
        body: Stack(children: [
          Column(children: [
            // Progress bar
            _ProgressBar(found: gs.foundCount, total: gs.totalWords),

            // Score + hints
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(children: [
                _Chip(
                  label: '⭐ ${gs.score}',
                  color: WSTheme.warning,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: gs.hintsRemaining > 0 ? () => gp.useHint() : null,
                  child: _Chip(
                    label: '💡 Hint (${gs.hintsRemaining})',
                    color: gs.hintsRemaining > 0 ? WSTheme.accent : Colors.grey,
                  ),
                ),
              ]),
            ),

            // Word chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: const WSWordList(),
            ),

            const SizedBox(height: 6),

            // Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: AspectRatio(aspectRatio: 1, child: const WSWordGrid()),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ]),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              colors: WSTheme.wordColors,
              numberOfParticles: 20,
              gravity: 0.2,
            ),
          ),

          // Pause overlay
          if (gs.isPaused)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Text('⏸ Paused',
                    style: TextStyle(fontSize: 30, color: Colors.white,
                        fontWeight: FontWeight.w800)),
              ),
            ),
        ]),
      );
    });
  }

  void _showPauseMenu(BuildContext ctx, WSGameProvider gp) {
    gp.togglePause();
    showModalBottomSheet(
      context: ctx,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: gp,
        // ✅ FIX: _PauseSheet ko bhi provider pass karo bottom sheet mein
        child: _PauseSheet(gp: gp),
      ),
    ).then((_) {
      if (gp.gameState?.isPaused == true) gp.togglePause();
    });
  }
}

class _ProgressBar extends StatelessWidget {
  final int found, total;
  const _ProgressBar({required this.found, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : found / total;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('$found / $total words',
              style: const TextStyle(fontSize: 12, color: Colors.white60,
                  fontWeight: FontWeight.w600)),
          Text('${(progress * 100).toInt()}%',
              style: const TextStyle(fontSize: 12, color: WSTheme.primary,
                  fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: WSTheme.primary.withOpacity(0.15),
            valueColor: const AlwaysStoppedAnimation(WSTheme.primary),
          ),
        ),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.w700, fontSize: 13, color: color)),
    );
  }
}

class _PauseSheet extends StatelessWidget {
  final WSGameProvider gp;
  const _PauseSheet({required this.gp});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: WSTheme.card,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Game Paused',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                color: Colors.white)),
        const SizedBox(height: 6),
        const Text('Take a breather ☕',
            style: TextStyle(color: Colors.white54)),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: _PauseBtn(
            label: 'Resume', icon: Icons.play_arrow_rounded,
            color: WSTheme.success,
            onTap: () { gp.togglePause(); Navigator.pop(context); },
          )),
          const SizedBox(width: 12),
          Expanded(child: _PauseBtn(
            label: 'Restart', icon: Icons.refresh_rounded,
            color: WSTheme.warning,
            onTap: () { Navigator.pop(context); gp.loadLevel(gp.currentLevel!); },
          )),
        ]),
        const SizedBox(height: 12),
        _PauseBtn(
          label: 'Exit to Menu', icon: Icons.home_rounded,
          color: WSTheme.accent,
          onTap: () { Navigator.pop(context); Navigator.pop(context); },
        ),
      ]),
    );
  }
}

class _PauseBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _PauseBtn(
      {required this.label, required this.icon,
       required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}
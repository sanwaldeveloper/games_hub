// games/word_search/screens/ws_home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/levels_data.dart';
import '../services/ws_game_provider.dart';
import '../services/ws_storage_service.dart';
import '../utils/ws_theme.dart';
import 'ws_level_select_screen.dart';
import 'ws_game_screen.dart';

class WordSearchHome extends StatelessWidget {
  const WordSearchHome({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<WSGameProvider>();

    return Scaffold(
      backgroundColor: WSTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Word Search Explorer',
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // BG blobs
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: WSTheme.primary.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 100, left: -80,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: WSTheme.accent.withOpacity(0.06),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),

                  // Logo
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [WSTheme.primary, WSTheme.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: WSTheme.primary.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🔍', style: TextStyle(fontSize: 42)),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Word Search',
                    style: TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Explorer',
                    style: TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w800,
                      color: WSTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Find words. Beat levels. Become a legend.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.white54),
                  ),

                  const Spacer(),

                  // Stats card
                  _StatsCard(gp: gp),

                  const SizedBox(height: 28),

                  // Play Levels button
                  _BigButton(
                    label: 'Play Levels',
                    icon: Icons.grid_view_rounded,
                    colors: const [WSTheme.primary, WSTheme.accent],
                    onTap: () {
                      final provider = context.read<WSGameProvider>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: provider,
                            child: const WSLevelSelectScreen(),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // Daily Challenge button
                  _BigButton(
                    label: WSStorageService.isDailyChallengeCompleted()
                        ? 'Daily Challenge ✅'
                        : 'Daily Challenge 🌟',
                    icon: Icons.today_rounded,
                    colors: const [WSTheme.success, Color(0xFF00BCD4)],
                    onTap: () {
                      final provider = context.read<WSGameProvider>();
                      provider.loadLevel(getWSDailyChallenge());
                      Navigator.push(
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

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final WSGameProvider gp;
  const _StatsCard({required this.gp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: WSTheme.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3),
              blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(icon: '🏆', value: '${gp.completedLevels.length}', label: 'Done'),
          Container(width: 1, height: 40, color: Colors.white12),
          _Stat(icon: '🔤', value: '${wsAllLevels.length}', label: 'Levels'),
          Container(width: 1, height: 40, color: Colors.white12),
          _Stat(icon: '⭐',
              value: '${gp.completedLevels.length * 3}', label: 'Stars'),
        ],
      ),
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
      Text(value,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
      Text(label,
          style: const TextStyle(fontSize: 11, color: Colors.white54)),
    ]);
  }
}

class _BigButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;
  const _BigButton(
      {required this.label, required this.icon,
       required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: colors.first.withOpacity(0.35),
                blurRadius: 12, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          // ✅ FIX: Flexible wrap — overflow rokne ke liye
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 17,
                  fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
      ),
    );
  }
}
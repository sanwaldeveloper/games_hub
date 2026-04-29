// games/word_search/screens/ws_level_select_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/levels_data.dart';
import '../models/level_model.dart';
import '../services/ws_game_provider.dart';
import '../utils/ws_theme.dart';
import 'ws_game_screen.dart';

class WSLevelSelectScreen extends StatefulWidget {
  const WSLevelSelectScreen({super.key});

  @override
  State<WSLevelSelectScreen> createState() => _WSLevelSelectScreenState();
}

class _WSLevelSelectScreenState extends State<WSLevelSelectScreen> {
  String _filter = 'All';

  List<String> get _themes =>
      ['All', ...wsAllLevels.map((l) => l.theme).toSet()];

  List<WordSearchLevelModel> get _levels => _filter == 'All'
      ? wsAllLevels
      : wsAllLevels.where((l) => l.theme == _filter).toList();

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<WSGameProvider>();

    return Scaffold(
      backgroundColor: WSTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Choose Level',
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(children: [
        // Filter chips
        SizedBox(
          height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: _themes.length,
            itemBuilder: (_, i) {
              final t = _themes[i];
              final sel = _filter == t;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: sel,
                  label: Text(t),
                  showCheckmark: false,
                  selectedColor: WSTheme.primary,
                  backgroundColor: WSTheme.card,
                  labelStyle: TextStyle(
                    color: sel ? Colors.white : Colors.white70,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.normal,
                  ),
                  onSelected: (_) => setState(() => _filter = t),
                ),
              );
            },
          ),
        ),

        // Level grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(14),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.94,
            ),
            itemCount: _levels.length,
            itemBuilder: (ctx, i) =>
                _LevelCard(level: _levels[i], gp: gp),
          ),
        ),
      ]),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final WordSearchLevelModel level;
  final WSGameProvider gp;
  const _LevelCard({required this.level, required this.gp});

  @override
  Widget build(BuildContext context) {
    final unlocked = gp.isLevelUnlocked(level.id);
    final completed = gp.completedLevels.contains(level.id);
    final best = gp.getBestScore(level.id);
    final diffColor = WSTheme.difficultyColor(level.difficultyLabel);

    return GestureDetector(
      onTap: unlocked
          ? () {
              // ✅ FIX: pehle level load karo, phir provider.value ke saath navigate karo
              gp.loadLevel(level);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: gp,
                    child: const WSGameScreen(),
                  ),
                ),
              );
            }
          : null,
      child: Stack(children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [WSTheme.card2, Color(0xFF533483)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: completed
                  ? WSTheme.success
                  : unlocked
                      ? WSTheme.primary.withOpacity(0.4)
                      : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3),
                  blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(level.themeIcon,
                      style: const TextStyle(fontSize: 28)),
                  if (completed)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: WSTheme.success, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 13),
                    ),
                ],
              ),
              const Spacer(),
              Text(level.theme,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: Colors.white)),
              Text('Level ${level.id}',
                  style: const TextStyle(fontSize: 12, color: Colors.white54)),
              const SizedBox(height: 8),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: diffColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(level.difficultyLabel,
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: diffColor)),
                ),
                const Spacer(),
                if (best != null)
                  Text('⭐ $best',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: WSTheme.warning)),
              ]),
            ],
          ),
        ),

        // Lock overlay
        if (!unlocked)
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Icon(Icons.lock_rounded, color: Colors.white60, size: 34),
            ),
          ),
      ]),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/ball_sort_controller.dart';
import '../models/ball_model.dart';
import 'ball_sort_game_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BallSortController>(
      builder: (context, ctrl, _) {
        final isDark = ctrl.isDarkMode;
        final unlockedLevels = ctrl.unlockedLevels;
        final totalLevels = ctrl.totalLevels;
        final currentLevel = ctrl.currentLevelNumber;

        final bgColor =
            isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F5F5);
        final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: textColor),
              onPressed: () => Navigator.maybePop(context),
            ),
            title: Text(
              'Select Level',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  isDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: textColor,
                ),
                onPressed: ctrl.toggleDarkMode,
              ),
            ],
          ),
          body: Column(
            children: [
              // Progress indicator
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$unlockedLevels / $totalLevels Unlocked',
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${((unlockedLevels / totalLevels) * 100).round()}%',
                          style: const TextStyle(
                            color: Color(0xFF6C63FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: unlockedLevels / totalLevels,
                        backgroundColor: isDark
                            ? Colors.white12
                            : Colors.black12,
                        valueColor: const AlwaysStoppedAnimation(
                            Color(0xFF6C63FF)),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              // Level grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: totalLevels,
                  itemBuilder: (ctx, index) {
                    final level = index + 1;
                    final isUnlocked = level <= unlockedLevels;
                    final isCurrent = level == currentLevel;

                    return _LevelCell(
                      level: level,
                      isUnlocked: isUnlocked,
                      isCurrent: isCurrent,
                      isDark: isDark,
                      onTap: isUnlocked
                          ? () async {
                              await ctrl.loadLevel(level);
                              if (context.mounted) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ChangeNotifierProvider.value(
                                      value: ctrl,
                                      child: const BallSortGameScreen(),
                                    ),
                                  ),
                                );
                              }
                            }
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LevelCell extends StatelessWidget {
  final int level;
  final bool isUnlocked;
  final bool isCurrent;
  final bool isDark;
  final VoidCallback? onTap;

  const _LevelCell({
    required this.level,
    required this.isUnlocked,
    required this.isCurrent,
    required this.isDark,
    this.onTap,
  });

  Color _getDifficultyColor() {
    if (level <= 5) return kBallColors[1]; // Blue - easy
    if (level <= 15) return kBallColors[2]; // Green - medium
    if (level <= 30) return kBallColors[3]; // Orange - hard
    return kBallColors[0]; // Red - expert
  }

  @override
  Widget build(BuildContext context) {
    final diffColor = _getDifficultyColor();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isCurrent
              ? const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isCurrent
              ? null
              : isUnlocked
                  ? (isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white)
                  : (isDark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.black.withOpacity(0.06)),
          border: Border.all(
            color: isCurrent
                ? Colors.transparent
                : isUnlocked
                    ? diffColor.withOpacity(0.4)
                    : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isUnlocked && !isCurrent
              ? [
                  BoxShadow(
                    color: diffColor.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : isCurrent
                  ? [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
        ),
        child: Center(
          child: isUnlocked
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$level',
                      style: TextStyle(
                        color: isCurrent
                            ? Colors.white
                            : isDark
                                ? Colors.white
                                : const Color(0xFF1A1A2E),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (!isCurrent)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: diffColor,
                        ),
                      ),
                  ],
                )
              : Icon(
                  Icons.lock_rounded,
                  color: isDark ? Colors.white24 : Colors.black26,
                  size: 20,
                ),
        ),
      ),
    );
  }
}

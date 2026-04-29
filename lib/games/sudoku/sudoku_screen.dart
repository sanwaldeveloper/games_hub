import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:games_hub/games/sudoku/sudoku_controller.dart';
import 'package:games_hub/games/sudoku/sudoku_board.dart';

class SudokuScreen extends StatelessWidget {
  const SudokuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SudokuController(),
      child: const _SudokuRoot(),
    );
  }
}

// ─── Root widget (theme + scaffold) ───────────────────────────────────────────
class _SudokuRoot extends StatefulWidget {
  const _SudokuRoot();

  @override
  State<_SudokuRoot> createState() => _SudokuRootState();
}

class _SudokuRootState extends State<_SudokuRoot> {
  bool _darkMode = false;
  bool _gameStarted = false;
  String _selectedDifficulty = 'Easy';

  // Difficulty configs (match puzzle style)
  static const _difficulties = [
    {'label': 'Easy', 'subtitle': 'Gentle start · 36 clues', 'emoji': '😊', 'color': Color(0xFF2ED573)},
    {'label': 'Medium', 'subtitle': 'Balanced challenge · 32 clues', 'emoji': '🤔', 'color': Color(0xFFFFB830)},
    {'label': 'Hard', 'subtitle': 'Tough grid · 28 clues', 'emoji': '🔥', 'color': Color(0xFFFF4757)},
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: _buildLight(),
      darkTheme: _buildDark(),
      home: _gameStarted
          ? _GameScreen(
              difficulty: _selectedDifficulty,
              onBackToSelect: () => setState(() => _gameStarted = false),
              onToggleDark: () => setState(() => _darkMode = !_darkMode),
              isDark: _darkMode,
            )
          : _SelectScreen(
              difficulties: _difficulties,
              onSelectDifficulty: (difficulty) {
                setState(() {
                  _selectedDifficulty = difficulty;
                  _gameStarted = true;
                });
              },
              onToggleDark: () => setState(() => _darkMode = !_darkMode),
              isDark: _darkMode,
            ),
    );
  }

  ThemeData _buildLight() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F4FF),
      );

  ThemeData _buildDark() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90D9),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0D1117),
      );
}

// ─── Difficulty Selection Screen (Styled like Sliding Puzzle) ─────────────
class _SelectScreen extends StatelessWidget {
  final List<Map<String, dynamic>> difficulties;
  final Function(String) onSelectDifficulty;
  final VoidCallback onToggleDark;
  final bool isDark;

  const _SelectScreen({
    required this.difficulties,
    required this.onSelectDifficulty,
    required this.onToggleDark,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF0F1117) : const Color(0xFFF0F4FF);
    final surfaceColor = isDark ? const Color(0xFF1A1D27) : Colors.white;
    final cardColor = isDark ? const Color(0xFF20232F) : Colors.white;
    final cardHighColor = isDark ? const Color(0xFF272B3A) : const Color(0xFFE2E8F0);
    final textPriColor = isDark ? const Color(0xFFF1F2F6) : const Color(0xFF1E293B);
    final textSecColor = isDark ? const Color(0xFF8B91A7) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with dark mode toggle
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                     onTap: () => Navigator.of(context, rootNavigator: true).pop(),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: cardHighColor, width: 1),
                      ),
                      child: const Icon(Icons.arrow_back_ios_rounded, size: 16, color: Color(0xFF8B91A7)),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: textSecColor),
                    onPressed: onToggleDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Title
            const Text('🧩', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Sudoku',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: textPriColor, letterSpacing: -0.5),
            ),
            const SizedBox(height: 6),
            Text(
              'Select Difficulty',
              style: TextStyle(fontSize: 15, color: textSecColor),
            ),

            const SizedBox(height: 40),

            // Difficulty buttons — emoji pair style
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: difficulties.map((d) {
                  final color = d['color'] as Color;
                  final label = d['label'] as String;
                  final subtitle = d['subtitle'] as String;
                  final emoji = d['emoji'] as String;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: GestureDetector(
                      onTap: () => onSelectDifficulty(label),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            color.withOpacity(0.18),
                            color.withOpacity(0.07),
                          ]),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: color.withOpacity(0.45), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: 30)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(label,
                                    style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  Text(subtitle,
                                    style: TextStyle(color: textSecColor, fontSize: 12)),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.6), size: 16),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Main game screen (Updated with puzzle-like stats bar) ────────────────
class _GameScreen extends StatelessWidget {
  final String difficulty;
  final VoidCallback onBackToSelect;
  final VoidCallback onToggleDark;
  final bool isDark;

  const _GameScreen({
    required this.difficulty,
    required this.onBackToSelect,
    required this.onToggleDark,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<SudokuController>();

    // Initialize game with selected difficulty if not already
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ctrl.difficulty != difficulty || ctrl.userBoard.isEmpty) {
        ctrl.newGame(difficulty: difficulty);
      }
    });

    if (ctrl.isComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCompletionDialog(context, ctrl);
      });
    }

    final bgColor = isDark ? const Color(0xFF0F1117) : const Color(0xFFF0F4FF);
    final surfaceColor = isDark ? const Color(0xFF1A1D27) : Colors.white;
    final cardColor = isDark ? const Color(0xFF20232F) : Colors.white;
    final cardHighColor = isDark ? const Color(0xFF272B3A) : const Color(0xFFE2E8F0);
    final textPriColor = isDark ? const Color(0xFFF1F2F6) : const Color(0xFF1E293B);
    final difficultyColor = _getDifficultyColor(difficulty);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar (matching puzzle style)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(bottom: BorderSide(color: cardHighColor, width: 1)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onBackToSelect,
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: cardHighColor, width: 1),
                      ),
                      child: const Icon(Icons.arrow_back_ios_rounded, size: 16, color: Color(0xFF8B91A7)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Sudoku',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textPriColor)),
                  const Spacer(),
                  IconButton(
                    icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: textPriColor),
                    onPressed: onToggleDark,
                  ),
                  const SizedBox(width: 4),
                  // Difficulty chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: difficultyColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: difficultyColor.withOpacity(0.3), width: 1),
                    ),
                    child: Text(
                      difficulty,
                      style: TextStyle(color: difficultyColor, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Stats row (puzzle style)
            _buildStatsRow(context, ctrl, difficultyColor),

            const SizedBox(height: 12),

            // Sudoku Board
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SudokuBoard(),
            ),

            const SizedBox(height: 12),

            // Action buttons (Undo, Erase, Hint, Pause)
            _buildActionBar(context, ctrl),

            const SizedBox(height: 8),

            // Number pad
            _buildNumberPad(context, ctrl),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, SudokuController ctrl, Color accentColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF20232F) : Colors.white;
    final cardHighColor = isDark ? const Color(0xFF272B3A) : const Color(0xFFE2E8F0);
    final textPriColor = isDark ? const Color(0xFFF1F2F6) : const Color(0xFF1E293B);
    final textSecColor = isDark ? const Color(0xFF8B91A7) : const Color(0xFF64748B);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statCard('Time', ctrl.formattedTime, Icons.timer_rounded, accentColor, cardColor, cardHighColor, textPriColor, textSecColor),
        _statCard('Errors', '${ctrl.errorCount}', Icons.close_rounded, Colors.redAccent, cardColor, cardHighColor, textPriColor, textSecColor),
        _statCard('Hints', '${ctrl.hintsRemaining}', Icons.lightbulb_outline, Colors.amber, cardColor, cardHighColor, textPriColor, textSecColor),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, Color cardColor, Color cardHighColor, Color textPriColor, Color textSecColor) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardHighColor, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(value,
            style: TextStyle(color: textPriColor, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label,
            style: TextStyle(color: textSecColor, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context, SudokuController ctrl) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF20232F) : Colors.white;
    final cardHighColor = isDark ? const Color(0xFF272B3A) : const Color(0xFFE2E8F0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionButton(context, Icons.undo_rounded, 'Undo', ctrl.canUndo ? ctrl.undo : null, cardColor, cardHighColor),
          _actionButton(context, Icons.backspace_outlined, 'Erase', ctrl.clearCell, cardColor, cardHighColor),
          _actionButton(context, Icons.lightbulb_outline_rounded, 'Hint (${ctrl.hintsRemaining})', ctrl.hintsRemaining > 0 ? ctrl.useHint : null, cardColor, cardHighColor, accent: Colors.amber),
          _actionButton(context, ctrl.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, ctrl.isPaused ? 'Resume' : 'Pause', ctrl.togglePause, cardColor, cardHighColor),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, VoidCallback? onTap, Color cardColor, Color cardHighColor, {Color? accent}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = onTap != null;
    final color = enabled
        ? (accent ?? Theme.of(context).colorScheme.primary)
        : (isDark ? const Color(0xFF4A506A) : const Color(0xFF94A3B8));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 72,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cardHighColor, width: 1),
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad(BuildContext context, SudokuController ctrl) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF20232F) : Colors.white;
    final cardHighColor = isDark ? const Color(0xFF272B3A) : const Color(0xFFE2E8F0);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(9, (i) {
          final number = i + 1;
          final selVal = (ctrl.selectedRow >= 0 && ctrl.selectedCol >= 0)
              ? ctrl.userBoard[ctrl.selectedRow][ctrl.selectedCol]
              : 0;
          final isActive = selVal == number;

          return GestureDetector(
            onTap: () => ctrl.enterNumber(number),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 36,
              height: 48,
              decoration: BoxDecoration(
                color: isActive ? primaryColor : cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cardHighColor, width: 1),
              ),
              child: Center(
                child: Text('$number',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : primaryColor,
                    )),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, SudokuController ctrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CompletionDialog(
        time: ctrl.formattedTime,
        difficulty: ctrl.difficulty,
        errors: ctrl.errorCount,
        onPlayAgain: () {
          ctrl.restartGame();
          Navigator.pop(context);
        },
        onNewGame: () {
          Navigator.pop(context);
          _showDifficultyPicker(context, ctrl);
        },
      ),
    );
  }

  void _showDifficultyPicker(BuildContext context, SudokuController ctrl) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1D27) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Choose Difficulty', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Easy', 'Medium', 'Hard'].map((d) {
            return ListTile(
              title: Text(d),
              onTap: () {
                Navigator.pop(context);
                ctrl.newGame(difficulty: d);
                // Update the parent to reflect new difficulty
                onBackToSelect.call();
                // Re-enter with new difficulty
                Future.delayed(const Duration(milliseconds: 100), () {
                  // This is handled by the parent widget state
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy': return const Color(0xFF2ED573);
      case 'Medium': return const Color(0xFFFFB830);
      case 'Hard': return const Color(0xFFFF4757);
      default: return const Color(0xFFFFB830);
    }
  }
}

// ─── Completion dialog (updated style) ─────────────────────────────────────────
class _CompletionDialog extends StatelessWidget {
  final String time;
  final String difficulty;
  final int errors;
  final VoidCallback onPlayAgain;
  final VoidCallback onNewGame;

  const _CompletionDialog({
    required this.time,
    required this.difficulty,
    required this.errors,
    required this.onPlayAgain,
    required this.onNewGame,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF20232F) : Colors.white;
    final textPriColor = isDark ? const Color(0xFFF1F2F6) : const Color(0xFF1E293B);
    final textSecColor = isDark ? const Color(0xFF8B91A7) : const Color(0xFF64748B);

    return AlertDialog(
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        '🎉 Congratulations!',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          _row('Difficulty', difficulty, textPriColor, textSecColor),
          _row('Time', time, textPriColor, textSecColor),
          _row('Errors', '$errors', textPriColor, textSecColor),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: onPlayAgain,
          child: const Text('Play Again', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        FilledButton(
          onPressed: onNewGame,
          child: const Text('New Game'),
        ),
      ],
    );
  }

  Widget _row(String label, String value, Color textPriColor, Color textSecColor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: textSecColor, fontSize: 15)),
            Text(value, style: TextStyle(color: textPriColor, fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      );
}
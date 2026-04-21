import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:games_hub/games/sudoku/sudoku_controller.dart';
import 'package:games_hub/games/sudoku/sudoku_board.dart';

/// ─── Entry point ──────────────────────────────────────────────────────────
/// GameHub se sirf yahi class call karni hai:
///   Navigator.push(context, MaterialPageRoute(builder: (_) => const SudokuScreen()));
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: _buildLight(),
      darkTheme: _buildDark(),
      home: _GameScreen(
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

// ─── Main game screen ──────────────────────────────────────────────────────────
class _GameScreen extends StatelessWidget {
  final VoidCallback onToggleDark;
  final bool isDark;

  const _GameScreen({required this.onToggleDark, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<SudokuController>();

    if (ctrl.isComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCompletionDialog(context, ctrl);
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(onToggleDark: onToggleDark, isDark: isDark),
            const _StatusBar(),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const SudokuBoard(),
            ),
            const SizedBox(height: 12),
            const _ActionBar(),
            const SizedBox(height: 8),
            const _NumberPad(),
            const SizedBox(height: 8),
          ],
        ),
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
      ),
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final VoidCallback onToggleDark;
  final bool isDark;

  const _Header({required this.onToggleDark, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<SudokuController>();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
      child: Row(
        children: [
          // Back button to return to GameHub
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SUDOKU',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: theme.colorScheme.primary,
                  )),
              Text(ctrl.difficulty,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  )),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: onToggleDark,
          ),
          _DifficultyButton(),
        ],
      ),
    );
  }
}

// ─── Difficulty selector ────────────────────────────────────────────────────────
class _DifficultyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<SudokuController>();
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu_rounded),
      onSelected: (val) {
        if (val == 'new') {
          _showDifficultyPicker(context);
        } else if (val == 'restart') {
          ctrl.restartGame();
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'new', child: Text('New Game')),
        const PopupMenuItem(value: 'restart', child: Text('Restart')),
      ],
    );
  }

  void _showDifficultyPicker(BuildContext context) {
    final ctrl = context.read<SudokuController>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Choose Difficulty'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Easy', 'Medium', 'Hard'].map((d) {
            return ListTile(
              title: Text(d),
              onTap: () {
                Navigator.pop(context);
                ctrl.newGame(difficulty: d);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Status bar ────────────────────────────────────────────────────────────────
class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<SudokuController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF161B27) : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatusItem(
              icon: ctrl.isPaused ? Icons.play_arrow : Icons.timer_outlined,
              label: ctrl.formattedTime,
              onTap: ctrl.togglePause,
            ),
            _StatusItem(
              icon: Icons.close_rounded,
              label: '${ctrl.errorCount} Errors',
              color: Colors.red[400],
            ),
            _StatusItem(
              icon: Icons.lightbulb_outline,
              label: '${ctrl.hintsRemaining} Hints',
              color: Colors.amber[600],
              onTap: ctrl.useHint,
            ),
            _AutoCheckToggle(),
          ],
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _StatusItem({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 18, color: c),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: c)),
        ],
      ),
    );
  }
}

class _AutoCheckToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<SudokuController>();
    return GestureDetector(
      onTap: ctrl.toggleAutoCheck,
      child: Column(
        children: [
          Icon(
            ctrl.autoCheck ? Icons.check_circle : Icons.check_circle_outline,
            size: 18,
            color: ctrl.autoCheck ? Colors.green : Colors.grey,
          ),
          const SizedBox(height: 2),
          Text('Auto-check',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: ctrl.autoCheck ? Colors.green : Colors.grey)),
        ],
      ),
    );
  }
}

// ─── Action bar ────────────────────────────────────────────────────────────────
class _ActionBar extends StatelessWidget {
  const _ActionBar();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<SudokuController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionBtn(
              icon: Icons.undo_rounded,
              label: 'Undo',
              onTap: ctrl.canUndo ? ctrl.undo : null),
          _ActionBtn(
              icon: Icons.backspace_outlined,
              label: 'Erase',
              onTap: ctrl.clearCell),
          _ActionBtn(
              icon: Icons.lightbulb_outline_rounded,
              label: 'Hint (${ctrl.hintsRemaining})',
              onTap: ctrl.hintsRemaining > 0 ? ctrl.useHint : null,
              accent: Colors.amber[600]),
          _ActionBtn(
              icon: ctrl.isPaused
                  ? Icons.play_arrow_rounded
                  : Icons.pause_rounded,
              label: ctrl.isPaused ? 'Resume' : 'Pause',
              onTap: ctrl.togglePause),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? accent;

  const _ActionBtn(
      {required this.icon, required this.label, this.onTap, this.accent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final enabled = onTap != null;
    final color = enabled
        ? (accent ?? theme.colorScheme.primary)
        : theme.colorScheme.onSurface.withOpacity(0.3);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 72,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B27) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
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
}

// ─── Number pad ────────────────────────────────────────────────────────────────
class _NumberPad extends StatelessWidget {
  const _NumberPad();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(9, (i) => _NumberKey(number: i + 1)),
      ),
    );
  }
}

class _NumberKey extends StatelessWidget {
  final int number;

  const _NumberKey({required this.number});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<SudokuController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          color: isActive
              ? theme.colorScheme.primary
              : (isDark ? const Color(0xFF161B27) : Colors.white),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Center(
          child: Text('$number',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : theme.colorScheme.primary,
              )),
        ),
      ),
    );
  }
}

// ─── Completion dialog ─────────────────────────────────────────────────────────
class _CompletionDialog extends StatelessWidget {
  final String time;
  final String difficulty;
  final int errors;

  const _CompletionDialog(
      {required this.time, required this.difficulty, required this.errors});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<SudokuController>();
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 8),
          Text('Puzzle Solved!',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary)),
          const SizedBox(height: 16),
          _row('Difficulty', difficulty),
          _row('Time', time),
          _row('Errors', '$errors'),
          const SizedBox(height: 20),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            ctrl.restartGame();
          },
          child: const Text('Play Again'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            _pickDifficulty(context, ctrl);
          },
          child: const Text('New Game'),
        ),
      ],
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );

  void _pickDifficulty(BuildContext context, SudokuController ctrl) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Choose Difficulty'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Easy', 'Medium', 'Hard'].map((d) {
            return ListTile(
              title: Text(d),
              onTap: () {
                Navigator.pop(context);
                ctrl.newGame(difficulty: d);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

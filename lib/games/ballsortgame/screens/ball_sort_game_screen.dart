import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/ball_sort_controller.dart';
import '../models/ball_model.dart';
import '../widgets/tube_widget.dart';
import '../widgets/win_overlay.dart';
import '../widgets/ball_arc_animation.dart';
import 'level_select_screen.dart';

class _FlyingBall {
  final BallModel ball;
  final Offset start;
  final Offset end;
  _FlyingBall({required this.ball, required this.start, required this.end});
}

class BallSortGameScreen extends StatefulWidget {
  const BallSortGameScreen({super.key});

  @override
  State<BallSortGameScreen> createState() => _BallSortGameScreenState();
}

class _BallSortGameScreenState extends State<BallSortGameScreen> {
  final Map<int, GlobalKey> _tubeKeys = {};
  _FlyingBall? _flyingBall;
  bool _animating = false;

  static const int _tubesPerRow = 5;

  void _ensureKeys(int tubeCount) {
    for (int i = 0; i < tubeCount; i++) {
      _tubeKeys.putIfAbsent(i, () => GlobalKey());
    }
  }

  Offset? _getTubeTopCenter(int index) {
    final ctx = _tubeKeys[index]?.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final pos = box.localToGlobal(Offset.zero);
    return Offset(pos.dx + box.size.width / 2, pos.dy + 4);
  }

  Future<void> _onTubeTapped(BuildContext context, int tubeIndex) async {
    if (_animating) return;
    final ctrl = context.read<BallSortController>();
    final state = ctrl.state;
    if (state == null || state.isWon) return;

    final selectedIndex = state.selectedTubeIndex;
    final tubes = state.level.tubes;

    // Nothing selected yet
    if (selectedIndex == null) {
      final tube = tubes[tubeIndex];
      if (tube.isEmpty || tube.isLocked) {
        HapticFeedback.lightImpact();
        return;
      }
      ctrl.onTubeTapped(tubeIndex);
      return;
    }

    // Deselect same tube
    if (selectedIndex == tubeIndex) {
      ctrl.onTubeTapped(tubeIndex);
      return;
    }

    final fromTube = tubes[selectedIndex];
    final toTube = tubes[tubeIndex];

    // Validate move
    if (fromTube.isEmpty || fromTube.isLocked) {
      ctrl.onTubeTapped(tubeIndex);
      return;
    }

    final ball = fromTube.topBall!;
    final isValidTarget = !toTube.isFull &&
        (toTube.isEmpty || toTube.topBall!.colorIndex == ball.colorIndex);

    if (!isValidTarget) {
      HapticFeedback.heavyImpact();
      _showInvalidFeedback(
        context,
        toTube.isFull
            ? 'Tube is full!'
            : (toTube.isLocked ? 'Tube is complete! 🎉' : 'Colors don\'t match!'),
      );
      // Switch selection if target is a valid source
      if (!toTube.isEmpty && !toTube.isLocked) {
        ctrl.onTubeTapped(tubeIndex);
      }
      return;
    }

    // Animate then commit
    final startPos = _getTubeTopCenter(selectedIndex);
    final endPos = _getTubeTopCenter(tubeIndex);

    if (startPos != null && endPos != null) {
      setState(() {
        _animating = true;
        _flyingBall = _FlyingBall(ball: ball, start: startPos, end: endPos);
      });

      // Commit move (ball disappears from source in state)
      ctrl.onTubeTapped(tubeIndex);

      await Future.delayed(const Duration(milliseconds: 530));

      if (mounted) {
        setState(() {
          _flyingBall = null;
          _animating = false;
        });
      }
    } else {
      ctrl.onTubeTapped(tubeIndex);
    }
  }

  void _showInvalidFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFEF5350),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BallSortController>(
      builder: (context, ctrl, _) {
        if (!ctrl.isInitialized || ctrl.state == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final state = ctrl.state!;
        final isDark = ctrl.isDarkMode;
        final level = state.level;
        final tubes = level.tubes;
        _ensureKeys(tubes.length);

        final bgColor =
            isDark ? const Color(0xFF12121F) : const Color(0xFFF0F0F8);
        final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.grid_view_rounded, color: textColor),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: ctrl,
                    child: const LevelSelectScreen(),
                  ),
                ),
              ),
            ),
            title: Column(
              children: [
                Text(
                  'Level ${level.levelNumber}',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${state.moves} moves',
                  style: TextStyle(
                    color: textColor.withOpacity(0.45),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: textColor,
                ),
                onPressed: ctrl.toggleDarkMode,
              ),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ActionChip(
                          icon: Icons.undo_rounded,
                          label: 'Undo',
                          enabled: ctrl.canUndo && !_animating,
                          isDark: isDark,
                          onTap: (!ctrl.canUndo || _animating) ? null : ctrl.undo,
                        ),
                        const SizedBox(width: 12),
                        _ActionChip(
                          icon: Icons.refresh_rounded,
                          label: 'Restart',
                          enabled: !_animating,
                          isDark: isDark,
                          onTap:
                              _animating ? null : () => _confirmRestart(context, ctrl),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (ctx, constraints) => _buildTubesArea(
                        context: ctx,
                        ctrl: ctrl,
                        tubes: tubes,
                        selectedIndex: state.selectedTubeIndex,
                        constraints: constraints,
                        isDark: isDark,
                        capacity: level.tubeCapacity,
                      ),
                    ),
                  ),
                ],
              ),
              // Arc animation layer
              if (_flyingBall != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: BallArcAnimationOverlay(
                      ball: _flyingBall!.ball,
                      startPosition: _flyingBall!.start,
                      endPosition: _flyingBall!.end,
                      onComplete: () {
                        if (mounted) {
                          setState(() {
                            _flyingBall = null;
                            _animating = false;
                          });
                        }
                      },
                    ),
                  ),
                ),
              // Win overlay
              if (state.isWon)
                WinOverlay(
                  levelNumber: level.levelNumber,
                  moves: state.moves,
                  hasNextLevel: level.levelNumber < ctrl.totalLevels,
                  onNextLevel: () async => await ctrl.goToNextLevel(),
                  onLevelSelect: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: ctrl,
                        child: const LevelSelectScreen(),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTubesArea({
    required BuildContext context,
    required BallSortController ctrl,
    required List tubes,
    required int? selectedIndex,
    required BoxConstraints constraints,
    required bool isDark,
    required int capacity,
  }) {
    final int total = tubes.length;
    final int rows = (total / _tubesPerRow).ceil();

    // Available space minus padding
    final double availW = constraints.maxWidth - 32;
    final double availH = constraints.maxHeight - (rows > 1 ? 40 : 20);

    // Each tube width = ballSize + 14 (padding). 5 per row + 8px gap between = 4 gaps
    // availW = 5 * tubeWidth + 4 * 8  =>  tubeWidth = (availW - 32) / 5
    // tubeWidth = ballSize + 14  =>  ballSize = tubeWidth - 14
    double ballSizeByWidth = ((availW - 32) / _tubesPerRow) - 14;

    // Each tube height = ballSize * capacity + 2*(capacity-1) + 16 + 20 lift space
    // rows * tubeH + (rows-1)*20 <= availH
    // tubeH = ballSize*capacity + gap*(cap-1) + 16
    // ballSizeByHeight: ballSize = (availH/(rows) - 20*(rows-1)/rows - 16 - gap*(cap-1)) / capacity
    final double gapSum = 2.0 * (capacity - 1);
    double ballSizeByHeight =
        ((availH / rows) - (rows > 1 ? 20.0 : 0) - 36 - gapSum) / capacity;

    // Use the smaller of the two to ensure it fits both ways
    double ballSize = ballSizeByWidth.clamp(22.0, 48.0);
    if (ballSizeByHeight < ballSize) {
      ballSize = ballSizeByHeight.clamp(22.0, 48.0);
    }

    // Split into rows
    final List<List<int>> rowGroups = [];
    for (int r = 0; r < rows; r++) {
      final start = r * _tubesPerRow;
      final end = (start + _tubesPerRow).clamp(0, total);
      rowGroups.add(List.generate(end - start, (i) => start + i));
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int r = 0; r < rowGroups.length; r++) ...[
              if (r > 0) const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int k = 0; k < rowGroups[r].length; k++) ...[
                    if (k > 0) const SizedBox(width: 8),
                    TubeWidget(
                      key: _tubeKeys[rowGroups[r][k]],
                      tube: tubes[rowGroups[r][k]],
                      tubeIndex: rowGroups[r][k],
                      isSelected: selectedIndex == rowGroups[r][k],
                      onTap: () => _onTubeTapped(context, rowGroups[r][k]),
                      ballSize: ballSize,
                      capacity: capacity,
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmRestart(BuildContext context, BallSortController ctrl) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restart Level?'),
        content: const Text('This will reset all progress for this level.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctrl.restartLevel();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child:
                const Text('Restart', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final bool isDark;
  final VoidCallback? onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFF6C63FF).withOpacity(isDark ? 0.18 : 0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: enabled
                ? const Color(0xFF6C63FF).withOpacity(0.55)
                : Colors.grey.withOpacity(0.25),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: enabled ? const Color(0xFF6C63FF) : Colors.grey),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: enabled ? const Color(0xFF6C63FF) : Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
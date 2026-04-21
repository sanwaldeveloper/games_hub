import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  ENTRY POINT  (keep your MaterialApp wrapper)
// ─────────────────────────────────────────────
class EmojiPairMasterApp extends StatelessWidget {
  const EmojiPairMasterApp({super.key});

  @override
  Widget build(BuildContext context) => const HomeScreen();
}

// ─────────────────────────────────────────────
//  DIFFICULTY CONFIG
// ─────────────────────────────────────────────
enum Difficulty { easy, medium, hard }

class DifficultyConfig {
  final String label;
  final int gridCols;
  final int gridRows;
  final int timeSeconds;
  final Color color;
  final String emoji;

  const DifficultyConfig({
    required this.label,
    required this.gridCols,
    required this.gridRows,
    required this.timeSeconds,
    required this.color,
    required this.emoji,
  });

  int get totalTiles => gridCols * gridRows;
  int get pairCount => totalTiles ~/ 2;
}

const Map<Difficulty, DifficultyConfig> difficultyConfigs = {
  Difficulty.easy: DifficultyConfig(
    label: 'Easy',
    gridCols: 4,
    gridRows: 3,
    timeSeconds: 60,
    color: Color(0xFF4CAF50),
    emoji: '😊',
  ),
  Difficulty.medium: DifficultyConfig(
    label: 'Medium',
    gridCols: 4,
    gridRows: 4,
    timeSeconds: 45,
    color: Color(0xFFFF9800),
    emoji: '🤔',
  ),
  Difficulty.hard: DifficultyConfig(
    label: 'Hard',
    gridCols: 5,
    gridRows: 4,
    timeSeconds: 30,
    color: Color(0xFFF44336),
    emoji: '🔥',
  ),
};

// ─────────────────────────────────────────────
//  EMOJI POOL
// ─────────────────────────────────────────────
const List<String> allEmojis = [
  '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼',
  '🐨', '🐯', '🦁', '🐮', '🐷', '🐸', '🐵', '🐔',
  '🦆', '🦉', '🦋', '🐝', '🐛', '🐞', '🦎', '🐬',
  '🌸', '🌺', '🌻', '🍎', '🍊', '🍋', '🍇', '🍓',
  '🎈', '🎉', '🎊', '⭐', '🌟', '💫', '🌈', '☁️',
];

// ─────────────────────────────────────────────
//  TILE MODEL  — immutable snapshot per rebuild
// ─────────────────────────────────────────────
/// FIX #1: Make EmojiTile an IMMUTABLE value object.
/// The GameState will replace tile instances rather than mutating them,
/// which guarantees didUpdateWidget receives genuinely different objects.
class EmojiTile {
  final int id;
  final String emoji;
  final bool isFlipped;
  final bool isMatched;

  const EmojiTile({
    required this.id,
    required this.emoji,
    this.isFlipped = false,
    this.isMatched = false,
  });

  /// Returns a new tile with only the changed fields updated.
  EmojiTile copyWith({bool? isFlipped, bool? isMatched}) => EmojiTile(
        id: id,
        emoji: emoji,
        isFlipped: isFlipped ?? this.isFlipped,
        isMatched: isMatched ?? this.isMatched,
      );
}

// ─────────────────────────────────────────────
//  GAME STATE  (ChangeNotifier)
// ─────────────────────────────────────────────
/// FIX #2: Replace tiles list entries with NEW objects (copyWith) so
/// Flutter's widget diff sees a real change and calls didUpdateWidget.
class GameState extends ChangeNotifier {
  List<EmojiTile> tiles = [];
  int score = 0;
  int streak = 0;
  int timeLeft = 60;
  bool isGameOver = false;
  bool isWon = false;
  Difficulty difficulty = Difficulty.easy;

  // FIX #3: Track locking state separately — no canFlip bool on tiles.
  bool _locked = false;
  int? _firstIndex;
  Timer? _timer;

  int get matchedPairs => tiles.where((t) => t.isMatched).length ~/ 2;
  int get totalPairs => tiles.length ~/ 2;

  void startGame(Difficulty diff) {
    difficulty = diff;
    score = 0;
    streak = 0;
    isGameOver = false;
    isWon = false;
    _locked = false;
    _firstIndex = null;
    _timer?.cancel();

    final config = difficultyConfigs[diff]!;
    timeLeft = config.timeSeconds;

    final emojisCopy = List<String>.from(allEmojis)..shuffle(Random());
    final selected = emojisCopy.take(config.pairCount).toList();
    final doubled = [...selected, ...selected]..shuffle(Random());

    tiles = List.generate(
      doubled.length,
      (i) => EmojiTile(id: i, emoji: doubled[i]),
    );

    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (timeLeft > 0) {
        timeLeft--;
        notifyListeners();
      } else {
        _timer?.cancel();
        isGameOver = true;
        notifyListeners();
      }
    });
  }

  // ── Core tap handler ──────────────────────────────────────────────
  void flipTile(int index) {
    // FIX #4: Guard: ignore taps when locked, or tile already open/matched.
    if (_locked) return;
    final tile = tiles[index];
    if (tile.isFlipped || tile.isMatched) return;

    // Flip this tile (replace with new object so widgets rebuild)
    _setTile(index, tile.copyWith(isFlipped: true));

    if (_firstIndex == null) {
      // ── First card tapped ────────────────────────────────────────
      _firstIndex = index;
    } else {
      // ── Second card tapped ───────────────────────────────────────
      // FIX #5: Lock immediately so no third card can be tapped.
      _locked = true;

      final firstTile = tiles[_firstIndex!];

      if (firstTile.emoji == tile.emoji) {
        // ✅ MATCH — mark both matched after short delay
        streak++;
        score += 10 + (streak * 2);
        Future.delayed(const Duration(milliseconds: 350), () {
          _setTile(_firstIndex!, tiles[_firstIndex!].copyWith(isMatched: true));
          _setTile(index, tiles[index].copyWith(isMatched: true));
          _firstIndex = null;
          _locked = false;

          if (tiles.every((t) => t.isMatched)) {
            _timer?.cancel();
            isWon = true;
          }
          notifyListeners();
        });
      } else {
        // ❌ NO MATCH — flip both back after 1 second
        streak = 0;
        Future.delayed(const Duration(milliseconds: 1000), () {
          _setTile(_firstIndex!, tiles[_firstIndex!].copyWith(isFlipped: false));
          _setTile(index, tiles[index].copyWith(isFlipped: false));
          _firstIndex = null;
          _locked = false;
          notifyListeners();
        });
      }
    }
  }

  /// Replace tile at [index] with [updated] and notify.
  void _setTile(int index, EmojiTile updated) {
    // Rebuild list with new object at index so widgets get didUpdateWidget.
    tiles = [
      for (int i = 0; i < tiles.length; i++) i == index ? updated : tiles[i],
    ];
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// ─────────────────────────────────────────────
//  HOME SCREEN
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;
  int _highScore = 0;

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

  void _startGame(Difficulty diff) {
    final state = GameState()..startGame(diff);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(gameState: state)),
    ).then((finalScore) {
      if (finalScore is int && finalScore > _highScore) {
        setState(() => _highScore = finalScore);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0E17), Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ScaleTransition(
                scale: _pulse,
                child: const Text('🎮', style: TextStyle(fontSize: 70)),
              ),
              const SizedBox(height: 16),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                ).createShader(bounds),
                child: const Text(
                  'Emoji Pair\nMaster',
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
                'Match emojis, beat the clock!',
                style:
                    TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
              ),
              const SizedBox(height: 30),
              if (_highScore > 0) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFFFD700).withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text('Best Score: $_highScore',
                          style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text('SELECT DIFFICULTY',
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
              ),
              const SizedBox(height: 16),
              ...Difficulty.values.map((diff) {
                final config = difficultyConfigs[diff]!;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                  child: _DifficultyButton(
                      config: config, onTap: () => _startGame(diff)),
                );
              }),
              const Spacer(),
              Text('Tap two matching emojis to clear them!',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.3), fontSize: 13)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DIFFICULTY BUTTON
// ─────────────────────────────────────────────
class _DifficultyButton extends StatelessWidget {
  final DifficultyConfig config;
  final VoidCallback onTap;

  const _DifficultyButton({required this.config, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            config.color.withOpacity(0.25),
            config.color.withOpacity(0.1),
          ]),
          borderRadius: BorderRadius.circular(18),
          border:
              Border.all(color: config.color.withOpacity(0.5), width: 1.5),
        ),
        child: Row(
          children: [
            Text(config.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(config.label,
                      style: TextStyle(
                          color: config.color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  Text(
                      '${config.gridCols}×${config.gridRows} grid · ${config.timeSeconds}s',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5), fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: config.color.withOpacity(0.7), size: 18),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  GAME SCREEN
// ─────────────────────────────────────────────
class GameScreen extends StatefulWidget {
  final GameState gameState;
  const GameScreen({super.key, required this.gameState});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    widget.gameState.addListener(_onStateChange);
  }

  void _onStateChange() {
    if (!mounted) return;
    setState(() {});
    if (widget.gameState.isWon || widget.gameState.isGameOver) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showResultDialog();
      });
    }
  }

  @override
  void dispose() {
    widget.gameState.removeListener(_onStateChange);
    widget.gameState.dispose();
    super.dispose();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(
        isWon: widget.gameState.isWon,
        score: widget.gameState.score,
        matchedPairs: widget.gameState.matchedPairs,
        totalPairs: widget.gameState.totalPairs,
        onReplay: () {
          Navigator.pop(context);
          widget.gameState.startGame(widget.gameState.difficulty);
        },
        onHome: () {
          Navigator.pop(context);
          Navigator.pop(context, widget.gameState.score);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gs = widget.gameState;
    final config = difficultyConfigs[gs.difficulty]!;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0E17), Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context, gs.score),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const Spacer(),
                    _StatChip(
                        icon: '⭐',
                        value: gs.score.toString(),
                        label: 'Score'),
                    const SizedBox(width: 12),
                    _StatChip(
                        icon: '🔥',
                        value: gs.streak.toString(),
                        label: 'Streak'),
                  ],
                ),
              ),
              // Progress & timer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${gs.matchedPairs}/${gs.totalPairs} pairs',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14)),
                        _TimerDisplay(
                            timeLeft: gs.timeLeft,
                            totalTime: config.timeSeconds),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: gs.totalPairs > 0
                            ? gs.matchedPairs / gs.totalPairs
                            : 0,
                        backgroundColor: Colors.white12,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(config.color),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── GRID ──────────────────────────────────────────────
              // FIX #6: Use a unique ValueKey on each tile widget so Flutter
              // always creates a fresh widget state when the tile list rebuilds.
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: config.gridCols,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: gs.tiles.length,
                    itemBuilder: (_, i) {
                      final tile = gs.tiles[i];
                      return _EmojiTileWidget(
                        // KEY = tile id, so the same widget instance is
                        // reused across rebuilds and didUpdateWidget fires.
                        key: ValueKey(tile.id),
                        tile: tile,
                        onTap: () => gs.flipTile(i),
                        accentColor: config.color,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  EMOJI TILE WIDGET
// ─────────────────────────────────────────────
class _EmojiTileWidget extends StatefulWidget {
  final EmojiTile tile;
  final VoidCallback onTap;
  final Color accentColor;

  const _EmojiTileWidget({
    super.key,
    required this.tile,
    required this.onTap,
    required this.accentColor,
  });

  @override
  State<_EmojiTileWidget> createState() => _EmojiTileWidgetState();
}

class _EmojiTileWidgetState extends State<_EmojiTileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _flip;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _flip = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    // FIX #7: Initialise animation to correct state immediately (e.g. on
    // replay when a matched tile might be recreated already flipped).
    if (widget.tile.isFlipped || widget.tile.isMatched) {
      _ctrl.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_EmojiTileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // FIX #8: Compare VALUE fields from the immutable tile objects.
    // Because tiles are replaced (not mutated), old vs new values differ.
    final wasOpen = oldWidget.tile.isFlipped || oldWidget.tile.isMatched;
    final isOpen = widget.tile.isFlipped || widget.tile.isMatched;

    if (!wasOpen && isOpen) {
      _ctrl.forward();   // face-down → face-up
    } else if (wasOpen && !isOpen) {
      _ctrl.reverse();   // face-up → face-down (unmatched flip-back)
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Matched tiles are completely non-interactive
      onTap: widget.tile.isMatched ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _flip,
        builder: (_, __) {
          final showFront = _flip.value >= 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(pi * _flip.value),
            child: showFront
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildFront(),
                  )
                : _buildBack(),
          );
        },
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6C63FF).withOpacity(0.6),
            const Color(0xFF3A3680).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF6C63FF).withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1)
        ],
      ),
      child: Center(
        child: Text('?',
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.5))),
      ),
    );
  }

  Widget _buildFront() {
    final isMatched = widget.tile.isMatched;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: isMatched
            ? LinearGradient(colors: [
                widget.accentColor.withOpacity(0.4),
                widget.accentColor.withOpacity(0.2),
              ])
            : const LinearGradient(
                colors: [Color(0xFF2A2A4A), Color(0xFF1E1E38)]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMatched
              ? widget.accentColor.withOpacity(0.8)
              : Colors.white.withOpacity(0.15),
          width: isMatched ? 2 : 1,
        ),
        boxShadow: isMatched
            ? [
                BoxShadow(
                    color: widget.accentColor.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2)
              ]
            : [],
      ),
      child: Center(
        child: Text(widget.tile.emoji,
            style: TextStyle(fontSize: isMatched ? 30 : 28)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  STAT CHIP
// ─────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String icon, value, label;
  const _StatChip(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text(label,
                  style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TIMER DISPLAY
// ─────────────────────────────────────────────
class _TimerDisplay extends StatelessWidget {
  final int timeLeft, totalTime;
  const _TimerDisplay({required this.timeLeft, required this.totalTime});

  @override
  Widget build(BuildContext context) {
    final urgent = timeLeft <= 10;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: urgent
            ? Colors.red.withOpacity(0.2)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: urgent
                ? Colors.red.withOpacity(0.6)
                : Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Text(urgent ? '⚠️' : '⏱', style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text('${timeLeft}s',
              style: TextStyle(
                  color: urgent ? Colors.red : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  RESULT DIALOG
// ─────────────────────────────────────────────
class _ResultDialog extends StatefulWidget {
  final bool isWon;
  final int score, matchedPairs, totalPairs;
  final VoidCallback onReplay, onHome;

  const _ResultDialog({
    required this.isWon,
    required this.score,
    required this.matchedPairs,
    required this.totalPairs,
    required this.onReplay,
    required this.onHome,
  });

  @override
  State<_ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends State<_ResultDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isWon
                  ? [const Color(0xFF1A3A1A), const Color(0xFF0D2A0D)]
                  : [const Color(0xFF3A1A1A), const Color(0xFF2A0D0D)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: widget.isWon
                  ? const Color(0xFF4CAF50).withOpacity(0.5)
                  : const Color(0xFFF44336).withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.isWon ? '🎉' : '😢',
                  style: const TextStyle(fontSize: 60)),
              const SizedBox(height: 12),
              Text(
                widget.isWon ? 'You Win!' : 'Time Up!',
                style: TextStyle(
                  color: widget.isWon
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFF44336),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.matchedPairs}/${widget.totalPairs} pairs matched',
                style: const TextStyle(color: Colors.white60, fontSize: 15),
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('FINAL SCORE',
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                            letterSpacing: 2)),
                    const SizedBox(height: 4),
                    Text('${widget.score}',
                        style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 48,
                            fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                        label: '🏠 Home',
                        onTap: widget.onHome,
                        color: Colors.white24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DialogButton(
                      label: '🔄 Replay',
                      onTap: widget.onReplay,
                      color: widget.isWon
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF6C63FF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DIALOG BUTTON
// ─────────────────────────────────────────────
class _DialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _DialogButton(
      {required this.label, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.85),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
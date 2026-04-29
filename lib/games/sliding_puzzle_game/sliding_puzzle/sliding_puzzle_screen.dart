import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'puzzle_logic.dart';
import 'tile_widget.dart';

class _C {
  static const bg       = Color(0xFF0F1117);
  static const surface  = Color(0xFF1A1D27);
  static const card     = Color(0xFF20232F);
  static const cardHigh = Color(0xFF272B3A);
  static const amber    = Color(0xFFFFB830);
  static const red      = Color(0xFFFF4757);
  static const green    = Color(0xFF2ED573);
  static const textPri  = Color(0xFFF1F2F6);
  static const textSec  = Color(0xFF8B91A7);
  static const textHint = Color(0xFF4A506A);
}

class SlidingPuzzleScreen extends StatefulWidget {
  const SlidingPuzzleScreen({super.key});

  @override
  State<SlidingPuzzleScreen> createState() => _SlidingPuzzleScreenState();
}

class _SlidingPuzzleScreenState extends State<SlidingPuzzleScreen>
    with TickerProviderStateMixin {
  late PuzzleLogic _logic;

  Timer? _timer;
  int _seconds = 0;

  Map<int, int> _bestMoves = {3: 0, 4: 0, 5: 0};
  Map<int, int> _bestTimes = {3: 0, 4: 0, 5: 0};

  late AnimationController _winController;
  late Animation<double> _winScale;

  int _selectedSize = 4;

  // ── Difficulty configs ────────────────────────────────────
  static const _difficulties = [
    {'size': 3, 'label': 'Easy', 'subtitle': '3×3 grid · Beginner friendly', 'emoji': '😊', 'color': Color(0xFF2ED573)},
    {'size': 4, 'label': 'Normal', 'subtitle': '4×4 grid · Moderate challenge', 'emoji': '🤔', 'color': Color(0xFFFFB830)},
    {'size': 5, 'label': 'Hard', 'subtitle': '5×5 grid · Experts only!', 'emoji': '🔥', 'color': Color(0xFFFF4757)},
  ];

  bool _gameStarted = false;

  @override
  void initState() {
    super.initState();
    _logic = PuzzleLogic(gridSize: _selectedSize);
    _loadBestScores();
    _winController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _winScale = CurvedAnimation(parent: _winController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _winController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  void _stopTimer() => _timer?.cancel();

  void _resetTimer() {
    _timer?.cancel();
    setState(() => _seconds = 0);
  }

  Future<void> _loadBestScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (int size in [3, 4, 5]) {
        _bestMoves[size] = prefs.getInt('sp_best_moves_$size') ?? 0;
        _bestTimes[size] = prefs.getInt('sp_best_time_$size') ?? 0;
      }
    });
  }

  Future<void> _saveBestScore(int size, int moves, int time) async {
    final prefs = await SharedPreferences.getInstance();
    if (_bestMoves[size] == 0 || moves < _bestMoves[size]!) {
      _bestMoves[size] = moves;
      await prefs.setInt('sp_best_moves_$size', moves);
    }
    if (_bestTimes[size] == 0 || time < _bestTimes[size]!) {
      _bestTimes[size] = time;
      await prefs.setInt('sp_best_time_$size', time);
    }
    setState(() {});
  }

  void _startGame(int size) {
    _resetTimer();
    setState(() {
      _selectedSize = size;
      _logic.changeSize(size);
      _gameStarted = true;
    });
  }

  void _onTileTap(int index) {
    bool valid = _logic.moveTile(index);
    if (!valid) return;
    if (_logic.moves == 1) _startTimer();
    setState(() {});
    if (_logic.solved) {
      _stopTimer();
      _saveBestScore(_selectedSize, _logic.moves, _seconds);
      _winController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 300), _showWinDialog);
    }
  }

  void _restart() {
    _resetTimer();
    setState(() => _logic.reset());
  }

  void _backToSelect() {
    _resetTimer();
    setState(() {
      _gameStarted = false;
    });
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ScaleTransition(
        scale: _winScale,
        child: AlertDialog(
          backgroundColor: _C.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Congratulations 🎉',
            textAlign: TextAlign.center,
            style: TextStyle(color: _C.textPri, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              _dialogRow('Moves', '${_logic.moves}'),
              _dialogRow('Time', _formatTime(_seconds)),
              Divider(color: _C.cardHigh, height: 24),
              _dialogRow(
                'Best Moves',
                _bestMoves[_selectedSize] == 0 ? '—' : '${_bestMoves[_selectedSize]}',
              ),
              _dialogRow(
                'Best Time',
                _bestTimes[_selectedSize] == 0 ? '—' : _formatTime(_bestTimes[_selectedSize]!),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () { Navigator.of(context).pop(); _restart(); },
              child: const Text('Play Again', style: TextStyle(color: _C.amber, fontSize: 15, fontWeight: FontWeight.w700)),
            ),
            TextButton(
              onPressed: () { Navigator.of(context).pop(); Navigator.of(context).pop(); },
              child: const Text('Back to Hub', style: TextStyle(color: _C.textSec, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: _C.textSec, fontSize: 15)),
          Text(value, style: const TextStyle(color: _C.textPri, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color get _selectedColor {
    final d = _difficulties.firstWhere((d) => d['size'] == _selectedSize);
    return d['color'] as Color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: _gameStarted ? _buildGameView() : _buildSelectView(),
      ),
    );
  }

  // ── Difficulty Selection Screen ───────────────────────────
  Widget _buildSelectView() {
    return Column(
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: _C.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _C.cardHigh, width: 1),
                  ),
                  child: const Icon(Icons.arrow_back_ios_rounded, size: 16, color: _C.textSec),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Title
        const Text('🧩', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        const Text(
          'Sliding Puzzle',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: _C.textPri, letterSpacing: -0.5),
        ),
        const SizedBox(height: 6),
        const Text(
          'Select Difficulty',
          style: TextStyle(fontSize: 15, color: _C.textSec),
        ),

        const SizedBox(height: 40),

        // Difficulty buttons — emoji pair style
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: _difficulties.map((d) {
              final color = d['color'] as Color;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GestureDetector(
                  onTap: () => _startGame(d['size'] as int),
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
                        Text(d['emoji'] as String, style: const TextStyle(fontSize: 30)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d['label'] as String,
                                style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(d['subtitle'] as String,
                                style: const TextStyle(color: _C.textSec, fontSize: 12)),
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
    );
  }

  // ── Game View ─────────────────────────────────────────────
  Widget _buildGameView() {
    final color = _selectedColor;
    return Column(
      children: [
        // Top bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _C.surface,
            border: Border(bottom: BorderSide(color: _C.cardHigh, width: 1)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: _backToSelect,
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: _C.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _C.cardHigh, width: 1),
                  ),
                  child: const Icon(Icons.arrow_back_ios_rounded, size: 16, color: _C.textSec),
                ),
              ),
              const SizedBox(width: 12),
              const Text('15 Puzzle',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _C.textPri)),
              const Spacer(),
              // Difficulty chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.3), width: 1),
                ),
                child: Text(
                  _difficulties.firstWhere((d) => d['size'] == _selectedSize)['label'] as String,
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        _buildStatsRow(color),
        const SizedBox(height: 20),
        Expanded(child: _buildGrid()),
        const SizedBox(height: 20),
        _buildControls(color),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStatsRow(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statCard('Moves', '${_logic.moves}', Icons.touch_app_rounded, color),
        _statCard('Time', _formatTime(_seconds), Icons.timer_rounded, color),
        _statCard(
          'Best',
          _bestMoves[_selectedSize] == 0 ? '—' : '${_bestMoves[_selectedSize]}',
          Icons.emoji_events_rounded,
          _C.amber,
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.cardHigh, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(value,
            style: const TextStyle(color: _C.textPri, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label,
            style: const TextStyle(color: _C.textSec, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      const gap = 8.0;
      final available = constraints.maxWidth - 48;
      final tileSize = (available - gap * (_logic.gridSize - 1)) / _logic.gridSize;

      return Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.cardHigh, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_logic.gridSize, (row) {
              return Padding(
                padding: EdgeInsets.only(bottom: row < _logic.gridSize - 1 ? gap : 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_logic.gridSize, (col) {
                    final index = row * _logic.gridSize + col;
                    final value = _logic.board[index];
                    return Padding(
                      padding: EdgeInsets.only(right: col < _logic.gridSize - 1 ? gap : 0),
                      child: SlidingTileWidget(
                        key: ValueKey(value == 0 ? 'empty_$index' : 'tile_$value'),
                        value: value,
                        gridSize: _logic.gridSize,
                        tileSize: tileSize,
                        onTap: () => _onTileTap(index),
                        solved: _logic.solved,
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      );
    });
  }

  Widget _buildControls(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _controlButton(label: 'Shuffle', icon: Icons.shuffle_rounded, color: _C.surface, onPressed: _restart),
        const SizedBox(width: 14),
        _controlButton(label: 'Restart', icon: Icons.refresh_rounded, color: color, onPressed: _restart),
      ],
    );
  }

  Widget _controlButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.cardHigh, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: _C.textPri),
            const SizedBox(width: 8),
            Text(label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _C.textPri)),
          ],
        ),
      ),
    );
  }
}
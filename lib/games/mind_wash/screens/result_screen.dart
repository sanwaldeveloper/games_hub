import 'package:flutter/material.dart';
import '../data/preferences_service.dart';
import '../models/quiz_result.dart';
import '../widgets/app_theme.dart';
import 'mind_wash_screen.dart';

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

class ResultScreen extends StatefulWidget {
  final QuizResult result;
  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late AnimationController _contentController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scoreAnimation = CurvedAnimation(
      parent: _scoreController,
      curve: Curves.elasticOut,
    );
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));
    _startAnimationsAndSave();
  }

  Future<void> _startAnimationsAndSave() async {
    await PreferencesService.saveLevel(widget.result.level);
    await PreferencesService.addToTotalScore(widget.result.score);
    await PreferencesService.incrementQuizzesPlayed();
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      _scoreController.forward();
      _contentController.forward();
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String get _scoreEmoji {
    if (widget.result.score <= 4) return '😔';
    if (widget.result.score <= 7) return '😊';
    return '🎉';
  }

  Color get _scoreColor {
    if (widget.result.score <= 4) return _C.red;
    if (widget.result.score <= 7) return _C.amber;
    return _C.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              ScaleTransition(
                scale: _scoreAnimation,
                child: _buildScoreCircle(),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      Text(
                        widget.result.feedbackMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _C.textPri,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Subject: ${widget.result.subject}',
                        style: const TextStyle(fontSize: 15, color: _C.textSec),
                      ),
                      const SizedBox(height: 28),
                      _buildStatsRow(),
                      const SizedBox(height: 24),
                      _buildLevelCard(),
                      const SizedBox(height: 32),
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCircle() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _scoreColor.withOpacity(0.1),
        border: Border.all(color: _scoreColor, width: 3),
        boxShadow: [
          BoxShadow(color: _scoreColor.withOpacity(0.2), blurRadius: 24, spreadRadius: 4),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_scoreEmoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 4),
          Text(
            '${widget.result.score}/${widget.result.total}',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: _scoreColor),
          ),
          Text(
            'Score',
            style: TextStyle(fontSize: 13, color: _scoreColor.withOpacity(0.7), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final correct = widget.result.score;
    final incorrect = widget.result.total - widget.result.score;
    final percentage = widget.result.percentage.round();

    return Row(
      children: [
        _buildStatCard('✅ Correct', correct.toString(), _C.green),
        const SizedBox(width: 12),
        _buildStatCard('❌ Wrong', incorrect.toString(), _C.red),
        const SizedBox(width: 12),
        _buildStatCard('📊 Score', '$percentage%', _C.amber),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          children: [
            Text(value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 4),
            Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard() {
    final levelNames = {1: 'Beginner', 2: 'Intermediate', 3: 'Expert'};
    final levelColors = {
      1: const Color(0xFF3B82F6),
      2: _C.amber,
      3: _C.green,
    };
    final levelIcons = {1: '🌱', 2: '⭐', 3: '🏆'};

    final level = widget.result.level;
    final color = levelColors[level] ?? const Color(0xFF3B82F6);
    final icon = levelIcons[level] ?? '🌱';
    final name = levelNames[level] ?? 'Beginner';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Level',
                  style: TextStyle(color: _C.textSec, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Level $level – $name',
                  style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MindWashScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.home_rounded, size: 18),
            label: const Text('Back to Home',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Play Again',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              foregroundColor: _C.textPri,
              side: const BorderSide(color: _C.cardHigh, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}
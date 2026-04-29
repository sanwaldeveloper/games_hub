// ============================================================
//  Quiz Screen - Dark Theme (Game Hub Style)
// ============================================================

import 'package:flutter/material.dart';
import '../data/question_repository.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';
import '../widgets/app_theme.dart';
import 'result_screen.dart';

// ── Dark Theme Colors ─────────────────────────────────────
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

class QuizScreen extends StatefulWidget {
  final String subject;
  final bool isMixedMode;

  const QuizScreen({
    super.key,
    required this.subject,
    required this.isMixedMode,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedOption;
  bool _isAnswered = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    List<Question> questions;
    if (widget.isMixedMode) {
      questions = await QuestionRepository.getMixedQuestions();
    } else {
      questions = await QuestionRepository.getQuestionsBySubject(widget.subject);
    }
    if (questions.length > 10) questions = questions.take(10).toList();
    if (mounted) setState(() { _questions = questions; _isLoading = false; });
  }

  void _onOptionTap(String option) {
    if (_isAnswered) return;
    final isCorrect = option == _questions[_currentIndex].answer;
    setState(() {
      _selectedOption = option;
      _isAnswered = true;
      if (isCorrect) _score++;
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _goToNextQuestion();
    });
  }

  void _goToNextQuestion() {
    if (_currentIndex + 1 >= _questions.length) {
      _navigateToResult();
    } else {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _isAnswered = false;
      });
    }
  }

  void _navigateToResult() {
    final result = QuizResult(
      score: _score,
      total: _questions.length,
      subject: widget.subject,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
    );
  }

  Color _getSubjectColor() {
    if (widget.isMixedMode) return AppTheme.primaryColor;
    return AppTheme.subjectColors[widget.subject] ?? AppTheme.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : _questions.isEmpty
                ? _buildEmptyState()
                : _buildQuizContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _C.amber, strokeWidth: 3),
          const SizedBox(height: 16),
          const Text('Loading Questions...',
              style: TextStyle(color: _C.textSec, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.quiz_outlined, size: 64, color: _C.textHint),
          const SizedBox(height: 16),
          const Text('No questions available',
              style: TextStyle(fontSize: 18, color: _C.textSec)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Go Back', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    final question = _questions[_currentIndex];
    final subjectColor = _getSubjectColor();

    return Column(
      children: [
        _buildTopBar(subjectColor),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressBar(subjectColor),
                const SizedBox(height: 24),
                _buildQuestionCard(question, subjectColor),
                const SizedBox(height: 20),
                ...question.options.map((option) =>
                    _buildOptionButton(option, question, subjectColor)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Top Bar ───────────────────────────────────────────────
  Widget _buildTopBar(Color subjectColor) {
    final emoji = widget.isMixedMode
        ? '🎲'
        : (AppTheme.subjectEmojis[widget.subject] ?? '📝');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _C.surface,
        border: Border(bottom: BorderSide(color: _C.cardHigh, width: 1)),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: _C.card,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: const Text('Quit Quiz?',
                      style: TextStyle(color: _C.textPri, fontWeight: FontWeight.w700)),
                  content: const Text(
                    'Are you sure you want to quit? Your progress will be lost.',
                    style: TextStyle(color: _C.textSec),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Continue',
                          style: TextStyle(color: _C.amber, fontWeight: FontWeight.w600)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: const Text('Quit',
                          style: TextStyle(color: _C.red, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
            },
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

          // Subject name
          Expanded(
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  widget.isMixedMode ? 'Mixed Mode' : widget.subject,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: subjectColor,
                  ),
                ),
              ],
            ),
          ),

          // Score chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _C.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _C.green.withOpacity(0.3), width: 1),
            ),
            child: Text(
              '✅  $_score',
              style: const TextStyle(
                color: _C.green,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress Bar ──────────────────────────────────────────
  Widget _buildProgressBar(Color subjectColor) {
    final progress = (_currentIndex + 1) / _questions.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${_currentIndex + 1} of ${_questions.length}',
              style: const TextStyle(fontSize: 12, color: _C.textSec, fontWeight: FontWeight.w500),
            ),
            Text(
              '${(_currentIndex + 1 / _questions.length * 100).round()}%',
              style: TextStyle(fontSize: 12, color: subjectColor, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: _C.cardHigh,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: subjectColor,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [BoxShadow(color: subjectColor.withOpacity(0.4), blurRadius: 6)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Question Card ─────────────────────────────────────────
  Widget _buildQuestionCard(Question question, Color subjectColor) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0), end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Container(
        key: ValueKey(_currentIndex),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: subjectColor.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(color: subjectColor.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: subjectColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: subjectColor.withOpacity(0.3), width: 1),
              ),
              child: Text(
                question.level.toUpperCase(),
                style: TextStyle(
                  color: subjectColor, fontSize: 10,
                  fontWeight: FontWeight.w800, letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              question.question,
              style: const TextStyle(
                color: _C.textPri, fontSize: 17,
                fontWeight: FontWeight.w700, height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Option Button ─────────────────────────────────────────
  Widget _buildOptionButton(String option, Question question, Color subjectColor) {
    final isSelected = _selectedOption == option;
    final isCorrect = option == question.answer;

    Color borderColor = _C.cardHigh;
    Color bgColor = _C.card;
    Color textColor = _C.textPri;
    IconData? trailingIcon;

    if (_isAnswered) {
      if (isCorrect) {
        borderColor = _C.green;
        bgColor = _C.green.withOpacity(0.12);
        textColor = _C.green;
        trailingIcon = Icons.check_circle_rounded;
      } else if (isSelected) {
        borderColor = _C.red;
        bgColor = _C.red.withOpacity(0.12);
        textColor = _C.red;
        trailingIcon = Icons.cancel_rounded;
      }
    } else if (isSelected) {
      borderColor = subjectColor;
      bgColor = subjectColor.withOpacity(0.12);
      textColor = subjectColor;
    }

    return GestureDetector(
      onTap: () => _onOptionTap(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(option,
                style: TextStyle(
                  color: textColor, fontSize: 14, fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailingIcon != null)
              Icon(trailingIcon, color: textColor, size: 20),
          ],
        ),
      ),
    );
  }
}
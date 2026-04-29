// ============================================================
//  Reusable Widgets
//  Small UI components used across multiple screens
// ============================================================

import 'package:flutter/material.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────
//  Subject Card Widget
//  Shown on home screen for each subject button
// ─────────────────────────────────────────────────────────────
class SubjectCard extends StatefulWidget {
  final String subject;
  final VoidCallback onTap;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onTap,
  });

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.forward();
  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.subjectColors[widget.subject] ?? AppTheme.primaryColor;
    final icon = AppTheme.subjectIcons[widget.subject] ?? Icons.quiz;
    final emoji = AppTheme.subjectEmojis[widget.subject] ?? '📝';

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Icon(icon, color: Colors.white70, size: 22),
              const SizedBox(height: 6),
              Text(
                widget.subject,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Option Button Widget
//  The 4 answer buttons on the quiz screen
// ─────────────────────────────────────────────────────────────
class OptionButton extends StatefulWidget {
  final String option;
  final String? selectedOption;    // What the user selected
  final String correctAnswer;      // The correct answer
  final bool isAnswered;           // Has the user answered yet?
  final VoidCallback onTap;

  const OptionButton({
    super.key,
    required this.option,
    required this.selectedOption,
    required this.correctAnswer,
    required this.isAnswered,
    required this.onTap,
  });

  @override
  State<OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<OptionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Determine the button's background color after answering
  Color _getBackgroundColor() {
    if (!widget.isAnswered) return Colors.white;

    if (widget.option == widget.correctAnswer) {
      return AppTheme.correctColor; // Always highlight correct answer
    }

    if (widget.option == widget.selectedOption) {
      return AppTheme.wrongColor; // Highlight wrong selection in red
    }

    return Colors.white;
  }

  // Determine the text color
  Color _getTextColor() {
    if (!widget.isAnswered) return AppTheme.textDark;

    if (widget.option == widget.correctAnswer ||
        widget.option == widget.selectedOption) {
      return Colors.white;
    }

    return AppTheme.textLight;
  }

  // Determine border color
  Color _getBorderColor() {
    if (!widget.isAnswered) return const Color(0xFFDDE3F0);

    if (widget.option == widget.correctAnswer) return AppTheme.correctColor;
    if (widget.option == widget.selectedOption) return AppTheme.wrongColor;

    return const Color(0xFFDDE3F0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isAnswered ? null : (_) => _controller.forward(),
      onTapUp: widget.isAnswered
          ? null
          : (_) {
              _controller.reverse();
              widget.onTap();
            },
      onTapCancel: widget.isAnswered ? null : () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: _getBorderColor(), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.option,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _getTextColor(),
                  ),
                ),
              ),
              if (widget.isAnswered && widget.option == widget.correctAnswer)
                const Icon(Icons.check_circle, color: Colors.white, size: 22),
              if (widget.isAnswered &&
                  widget.option == widget.selectedOption &&
                  widget.option != widget.correctAnswer)
                const Icon(Icons.cancel, color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Progress Bar Widget
//  Shows question progress (e.g., 3/10)
// ─────────────────────────────────────────────────────────────
class QuizProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final Color color;

  const QuizProgressBar({
    super.key,
    required this.current,
    required this.total,
    this.color = AppTheme.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final progress = current / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question $current of $total',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textLight,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Level Badge Widget
//  Shows user's current level
// ─────────────────────────────────────────────────────────────
class LevelBadge extends StatelessWidget {
  final int level;

  const LevelBadge({super.key, required this.level});

  String get _levelLabel {
    switch (level) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Intermediate';
      case 3:
        return 'Expert';
      default:
        return 'Beginner';
    }
  }

  Color get _levelColor {
    switch (level) {
      case 1:
        return const Color(0xFF3498DB); // Blue
      case 2:
        return const Color(0xFFF39C12); // Orange
      case 3:
        return const Color(0xFF27AE60); // Green
      default:
        return const Color(0xFF3498DB);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _levelColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _levelColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: _levelColor, size: 16),
          const SizedBox(width: 4),
          Text(
            'Level $level – $_levelLabel',
            style: TextStyle(
              color: _levelColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

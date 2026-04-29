// ============================================================
//  Quiz Result Model
//  Holds the result data after completing a quiz
// ============================================================

class QuizResult {
  final int score;
  final int total;
  final String subject; // 'Mixed' for mixed mode

  QuizResult({
    required this.score,
    required this.total,
    required this.subject,
  });

  /// Calculate level based on score
  int get level {
    if (score <= 4) return 1;
    if (score <= 7) return 2;
    return 3;
  }

  /// Get a feedback message based on score
  String get feedbackMessage {
    if (score <= 4) return 'Keep Practicing! You can do better! 💪';
    if (score <= 7) return 'Good Job! Almost there! 👍';
    return 'Excellent! You are a star! ⭐';
  }

  /// Percentage score
  double get percentage => (score / total) * 100;
}

// ============================================================
//  Question Model
//  Represents a single quiz question with all its data
// ============================================================

class Question {
  final String subject;
  final String question;
  final List<String> options;
  final String answer;
  final String level; // easy, medium, hard

  Question({
    required this.subject,
    required this.question,
    required this.options,
    required this.answer,
    this.level = 'easy',
  });

  /// Create a Question from a JSON map (loaded from assets)
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      subject: json['subject'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      answer: json['answer'] ?? '',
      level: json['level'] ?? 'easy',
    );
  }
}

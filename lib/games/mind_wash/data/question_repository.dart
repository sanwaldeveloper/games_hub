// ============================================================
//  Question Repository
//  Loads questions from the local JSON file in assets

import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionRepository {
  // Cached list of all questions (loaded once)
  static List<Question>? _allQuestions;

  /// Load all questions from the JSON file in assets
  static Future<List<Question>> loadAllQuestions() async {
    if (_allQuestions != null) {
      return _allQuestions!;
    }

    // Load the JSON string from assets
    final String jsonString =
        await rootBundle.loadString('assets/questions.json');

    // Decode the JSON
    final List<dynamic> jsonList = json.decode(jsonString);

    // Convert each JSON object to a Question model
    _allQuestions = jsonList.map((json) => Question.fromJson(json)).toList();

    return _allQuestions!;
  }

  /// Get all questions for a specific subject
  static Future<List<Question>> getQuestionsBySubject(String subject) async {
    final all = await loadAllQuestions();
    final filtered = all.where((q) => q.subject == subject).toList();
    filtered.shuffle(); // Shuffle so questions appear in different order
    return filtered;
  }

  /// Get 10 mixed questions (2 from each subject)
  static Future<List<Question>> getMixedQuestions() async {
    final all = await loadAllQuestions();

    // List of all subjects
    final subjects = [
      'Pak Study',
      'Math',
      'Urdu',
      'English',
      'General Science',
    ];

    final List<Question> mixedQuestions = [];
    final Random random = Random();

    for (final subject in subjects) {
      // Get questions for this subject
      final subjectQuestions =
          all.where((q) => q.subject == subject).toList();

      // Shuffle them
      subjectQuestions.shuffle(random);

      // Take 2 questions (or less if not enough)
      final count = subjectQuestions.length >= 2 ? 2 : subjectQuestions.length;
      mixedQuestions.addAll(subjectQuestions.take(count));
    }

    // Shuffle the final mixed list so subjects are interleaved
    mixedQuestions.shuffle(random);

    return mixedQuestions;
  }

  /// Get the list of all unique subjects
  static Future<List<String>> getSubjects() async {
    final all = await loadAllQuestions();
    final Set<String> subjectSet = {};
    for (final q in all) {
      subjectSet.add(q.subject);
    }
    return subjectSet.toList();
  }
}

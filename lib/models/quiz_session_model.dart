import 'dart:convert';

class QuizSessionModel {
  final int? id;
  final int userId;
  final int subjectId;
  final int currentQuestionIndex;
  final List<int> skippedQuestionIds;
  final int correctCount;
  final bool isCompleted;
  final String lastActivity;
  final int totalQuestions;

  QuizSessionModel({
    this.id,
    required this.userId,
    required this.subjectId,
    required this.currentQuestionIndex,
    required this.skippedQuestionIds,
    required this.correctCount,
    required this.isCompleted,
    required this.lastActivity,
    required this.totalQuestions,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'subject_id': subjectId,
      'current_question_index': currentQuestionIndex,
      'skipped_question_ids': jsonEncode(skippedQuestionIds),
      'correct_count': correctCount,
      'is_completed': isCompleted ? 1 : 0,
      'last_activity': lastActivity,
      'total_questions': totalQuestions,
    };
  }

  factory QuizSessionModel.fromMap(Map<String, dynamic> map) {
    return QuizSessionModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      subjectId: map['subject_id'] as int,
      currentQuestionIndex: map['current_question_index'] as int,
      skippedQuestionIds: List<int>.from(jsonDecode(map['skipped_question_ids'] as String)),
      correctCount: map['correct_count'] as int,
      isCompleted: (map['is_completed'] as int) == 1,
      lastActivity: map['last_activity'] as String,
      totalQuestions: map['total_questions'] as int,
    );
  }
}

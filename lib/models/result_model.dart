class ResultModel {
  final int? id;
  final int userId;
  final int subjectId;
  final int totalQuestions;
  final int correctAnswers;
  final int score;
  final String dateTaken;

  ResultModel({
    this.id,
    required this.userId,
    required this.subjectId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.dateTaken,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'subject_id': subjectId,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'score': score,
      'date_taken': dateTaken,
    };
  }

  factory ResultModel.fromMap(Map<String, dynamic> map) {
    return ResultModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      subjectId: map['subject_id'] as int,
      totalQuestions: map['total_questions'] as int,
      correctAnswers: map['correct_answers'] as int,
      score: map['score'] as int,
      dateTaken: map['date_taken'] as String,
    );
  }
}

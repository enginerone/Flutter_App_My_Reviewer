class QuestionModel {
  final int? id;
  final int subjectId;
  final int? topicId;
  final String meaning;
  final String correctTerm;

  QuestionModel({
    this.id,
    required this.subjectId,
    this.topicId,
    required this.meaning,
    required this.correctTerm,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'subject_id': subjectId,
      if (topicId != null) 'topic_id': topicId,
      'meaning': meaning,
      'correct_term': correctTerm,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] as int?,
      subjectId: map['subject_id'] as int,
      topicId: map['topic_id'] as int?,
      meaning: map['meaning'] as String,
      correctTerm: map['correct_term'] as String,
    );
  }
}

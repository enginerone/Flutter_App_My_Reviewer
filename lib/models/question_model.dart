import 'dart:convert';

class QuestionModel {
  final int? id;
  final int subjectId;
  final int? topicId;
  final String meaning;
  final String correctTerm;
  /// 'identification' or 'multiple_choice'
  final String answerType;
  /// Distractor choices (for multiple_choice). The correct term is NOT stored
  /// here — it is merged in at runtime so we always have one source of truth.
  final List<String> choices;

  QuestionModel({
    this.id,
    required this.subjectId,
    this.topicId,
    required this.meaning,
    required this.correctTerm,
    this.answerType = 'identification',
    this.choices = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'subject_id': subjectId,
      if (topicId != null) 'topic_id': topicId,
      'meaning': meaning,
      'correct_term': correctTerm,
      'answer_type': answerType,
      'choices': jsonEncode(choices),
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] as int?,
      subjectId: map['subject_id'] as int,
      topicId: map['topic_id'] as int?,
      meaning: map['meaning'] as String,
      correctTerm: map['correct_term'] as String,
      answerType: (map['answer_type'] as String?) ?? 'identification',
      choices: map['choices'] != null
          ? List<String>.from(jsonDecode(map['choices'] as String))
          : [],
    );
  }
}

class CategoryTopicModel {
  final int? id;
  final int subjectId;
  final String topicName;

  CategoryTopicModel({
    this.id,
    required this.subjectId,
    required this.topicName,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'subject_id': subjectId,
      'topic_name': topicName,
    };
  }

  factory CategoryTopicModel.fromMap(Map<String, dynamic> map) {
    return CategoryTopicModel(
      id: map['id'] as int?,
      subjectId: map['subject_id'] as int,
      topicName: map['topic_name'] as String,
    );
  }

  @override
  String toString() => topicName;
}

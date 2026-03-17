class SubjectModel {
  final int? id;
  final String subjectName;
  final String description;

  SubjectModel({
    this.id,
    required this.subjectName,
    this.description = '',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'subject_name': subjectName,
      'description': description,
    };
  }

  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      id: map['id'] as int?,
      subjectName: map['subject_name'] as String,
      description: (map['description'] as String?) ?? '',
    );
  }

  @override
  String toString() => subjectName;
}

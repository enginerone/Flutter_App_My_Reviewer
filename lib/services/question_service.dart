import '../config/database_helper.dart';
import '../models/subject_model.dart';
import '../models/question_model.dart';

class QuestionService {
  final DatabaseHelper _db = DatabaseHelper();

  // ──────────────────────────── SUBJECTS ────────────────────────────

  Future<int> addSubject(SubjectModel subject) async {
    return _db.insert('subjects', subject.toMap());
  }

  Future<List<SubjectModel>> getAllSubjects() async {
    final rows = await _db.query('subjects', orderBy: 'subject_name ASC');
    return rows.map((r) => SubjectModel.fromMap(r)).toList();
  }

  Future<SubjectModel?> getSubjectById(int id) async {
    final rows = await _db.query('subjects', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return SubjectModel.fromMap(rows.first);
  }

  Future<bool> updateSubject(SubjectModel subject) async {
    final count = await _db.update(
      'subjects',
      subject.toMap(),
      'id = ?',
      [subject.id],
    );
    return count > 0;
  }

  Future<bool> deleteSubject(int id) async {
    // Also delete related questions
    await _db.delete('questions', 'subject_id = ?', [id]);
    final count = await _db.delete('subjects', 'id = ?', [id]);
    return count > 0;
  }

  // ──────────────────────────── QUESTIONS ────────────────────────────

  Future<int> addQuestion(QuestionModel question) async {
    return _db.insert('questions', question.toMap());
  }

  Future<List<QuestionModel>> getQuestionsBySubject(int subjectId, {int? topicId}) async {
    final String whereClause;
    final List<dynamic> whereArgs;

    if (topicId != null) {
      whereClause = 'subject_id = ? AND topic_id = ?';
      whereArgs = [subjectId, topicId];
    } else {
      whereClause = 'subject_id = ?';
      whereArgs = [subjectId];
    }

    final rows = await _db.query(
      'questions',
      where: whereClause,
      whereArgs: whereArgs,
    );
    return rows.map((r) => QuestionModel.fromMap(r)).toList();
  }

  Future<List<QuestionModel>> getAllQuestions() async {
    final rows = await _db.query('questions', orderBy: 'subject_id ASC');
    return rows.map((r) => QuestionModel.fromMap(r)).toList();
  }

  Future<bool> updateQuestion(QuestionModel question) async {
    final count = await _db.update(
      'questions',
      question.toMap(),
      'id = ?',
      [question.id],
    );
    return count > 0;
  }

  Future<bool> deleteQuestion(int id) async {
    final count = await _db.delete('questions', 'id = ?', [id]);
    return count > 0;
  }
}

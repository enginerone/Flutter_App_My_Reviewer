import '../config/database_helper.dart';
import '../models/quiz_session_model.dart';

class QuizSessionService {
  final DatabaseHelper _db = DatabaseHelper();

  Future<int> createSession(QuizSessionModel session) async {
    return await _db.insert('quiz_sessions', session.toMap());
  }

  Future<QuizSessionModel?> getActiveSession(int userId, int subjectId) async {
    final rows = await _db.query(
      'quiz_sessions',
      where: 'user_id = ? AND subject_id = ? AND is_completed = 0',
      whereArgs: [userId, subjectId],
    );
    if (rows.isEmpty) return null;
    return QuizSessionModel.fromMap(rows.first);
  }

  Future<bool> updateSession(QuizSessionModel session) async {
    final count = await _db.update(
      'quiz_sessions',
      session.toMap(),
      'id = ?',
      [session.id],
    );
    return count > 0;
  }

  Future<bool> deleteSession(int id) async {
    final count = await _db.delete('quiz_sessions', 'id = ?', [id]);
    return count > 0;
  }

  Future<void> clearCompletedSessions(int userId) async {
    await _db.delete('quiz_sessions', 'user_id = ? AND is_completed = 1', [userId]);
  }
}

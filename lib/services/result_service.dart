import '../config/database_helper.dart';
import '../models/result_model.dart';

class ResultService {
  final DatabaseHelper _db = DatabaseHelper();

  Future<int> saveResult(ResultModel result) async {
    return _db.insert('results', result.toMap());
  }

  Future<List<ResultModel>> getResultsByUser(int userId) async {
    final rows = await _db.query(
      'results',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date_taken DESC',
    );
    return rows.map((r) => ResultModel.fromMap(r)).toList();
  }

  Future<List<ResultModel>> getResultsBySubject(int subjectId) async {
    final rows = await _db.query(
      'results',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      orderBy: 'date_taken DESC',
    );
    return rows.map((r) => ResultModel.fromMap(r)).toList();
  }
}

import '../config/database_helper.dart';
import '../models/category_topic_model.dart';

class CategoryTopicService {
  final DatabaseHelper _db = DatabaseHelper();

  Future<int> addTopic(CategoryTopicModel topic) async {
    return _db.insert('category_topics', topic.toMap());
  }

  Future<List<CategoryTopicModel>> getTopicsBySubject(int subjectId) async {
    final rows = await _db.query(
      'category_topics',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      orderBy: 'topic_name ASC',
    );
    return rows.map((r) => CategoryTopicModel.fromMap(r)).toList();
  }

  Future<CategoryTopicModel?> getTopicById(int id) async {
    final rows = await _db.query('category_topics', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return CategoryTopicModel.fromMap(rows.first);
  }

  Future<bool> updateTopic(CategoryTopicModel topic) async {
    final count = await _db.update(
      'category_topics',
      topic.toMap(),
      'id = ?',
      [topic.id],
    );
    return count > 0;
  }

  Future<bool> deleteTopic(int id) async {
    // Note: Setting topic_id on related questions to null is handled by the database schema (ON DELETE SET NULL)
    final count = await _db.delete('category_topics', 'id = ?', [id]);
    return count > 0;
  }
}

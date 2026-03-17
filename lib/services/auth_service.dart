import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../config/database_helper.dart';
import '../models/user_model.dart';

class AuthService {
  final DatabaseHelper _db = DatabaseHelper();

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Check if email already exists
    final existing = await _db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
    if (existing.isNotEmpty) return false;

    final user = UserModel(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      password: hashPassword(password),
      role: 'user',
    );

    final result = await _db.insert('users', user.toMap());
    return result > 0;
  }

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    final rows = await _db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email.trim().toLowerCase(), hashPassword(password)],
    );

    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }
}

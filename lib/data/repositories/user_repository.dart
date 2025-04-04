import '../models/user.dart';
import '../database/database_helper.dart';


class UserRepository {
  final DatabaseHelper _databaseHelper;

  UserRepository(this._databaseHelper);

  Future<User> createUser(User user) async {
    final db = await _databaseHelper.database;
    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

  Future<User?> getUserById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<bool> updateUser(User user) async {
    final db = await _databaseHelper.database;
    final count = await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
    return count > 0;
  }
}
import '../models/book.dart';
import '../database/database_helper.dart';

class BookRepository {
  final DatabaseHelper _databaseHelper;

  BookRepository(this._databaseHelper);

  Future<Book> createBook(Book book) async {
    final db = await _databaseHelper.database;
    final id = await db.insert('books', book.toMap());
    return book.copyWith(id: id);
  }

  Future<List<Book>> getBooks() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('books', orderBy: 'name ASC');
    return maps.map((map) => Book.fromMap(map)).toList();
  }

  Future<Book?> getBookById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query('books', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;
    return Book.fromMap(maps.first);
  }

  Future<List<Book>> getBooksByUserId(int userId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'books',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Book.fromMap(map)).toList();
  }

  Future<bool> updateBook(Book book, String newName) async {
    final db = await _databaseHelper.database;
    final count = await db.update(
      'books',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [book.id],
    );
    return count > 0;
  }

  Future<bool> deleteBook(Book book) async {
    final db = await _databaseHelper.database;
    final count =
        await db.delete('books', where: 'id = ?', whereArgs: [book.id]);
    return count > 0;
  }

  Future<bool> deleteAllBooks() async {
    final db = await _databaseHelper.database;
    final count = await db.delete('books');
    return count > 0;
  }
}

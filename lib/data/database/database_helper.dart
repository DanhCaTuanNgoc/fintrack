import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fintrack.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Bảng User
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        premium INTEGER DEFAULT 0
      )
    ''');

    // Bảng Books (Ví/Sổ chi tiêu)
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        balance REAL DEFAULT 0,
        user_id INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Bảng Categories
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT,
        color TEXT,
        type TEXT CHECK(type IN ('income', 'expense')),
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Bảng Transactions
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        note TEXT,
        date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        type TEXT CHECK(type IN ('income', 'expense')),
        category_id INTEGER,
        book_id INTEGER,
        user_id INTEGER,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL,
        FOREIGN KEY (book_id) REFERENCES books (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Thêm một số category mặc định
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {'name': 'Ăn uống', 'type': 'expense', 'icon': '🍔'},
      {'name': 'Di chuyển', 'type': 'expense', 'icon': '🚗'},
      {'name': 'Mua sắm', 'type': 'expense', 'icon': '🛍'},
      {'name': 'Giải trí', 'type': 'expense', 'icon': '🎮'},
      {'name': 'Học tập', 'type': 'expense', 'icon': '📚'},
      {'name': 'Làm đẹp', 'type': 'expense', 'icon': '💅'},
      {'name': 'Lương', 'type': 'income', 'icon': '💰'},
      {'name': 'Thưởng', 'type': 'income', 'icon': '🎁'},
      {'name': 'Đầu tư', 'type': 'income', 'icon': '📈'},
    ];

    for (var category in defaultCategories) {
      await db.insert('categories', category);
    }
  }

  // CRUD operations cho User
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  // CRUD operations cho Books
  Future<int> insertBook(Map<String, dynamic> book) async {
    final db = await database;
    return await db.insert('books', book);
  }

  Future<List<Map<String, dynamic>>> getBooksByUser(int userId) async {
    final db = await database;
    return await db.query(
      'books',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // CRUD operations cho Categories
  Future<List<Map<String, dynamic>>> getCategoriesByType(String type) async {
    final db = await database;
    return await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
    );
  }

  // CRUD operations cho Transactions
  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction);
  }

  Future<List<Map<String, dynamic>>> getTransactionsByBook(int bookId) async {
    final db = await database;
    return await db.query(
      'transactions',
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'date DESC',
    );
  }
}
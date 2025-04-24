import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logging/logging.dart';

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
    final appDocDir = await getApplicationDocumentsDirectory();
    final path = join(appDocDir.path, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // Bảng User
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        premium INTEGER DEFAULT 0
      )
    ''');

    // Bảng Books (Ví/Sổ chi tiêu)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL DEFAULT 0,
        user_id INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Bảng Categories
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT,
        type TEXT CHECK(type IN ('income', 'expense'))
      )
    ''');

    // Bảng Transactions
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
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
    return await db.query('books', where: 'user_id = ?', whereArgs: [userId]);
  }

  // CRUD operations cho Categories
  Future<List<Map<String, dynamic>>> getCategoriesByType(String type) async {
    final db = await database;
    return await db.query('categories', where: 'type = ?', whereArgs: [type]);
  }

  Future<List<Map<String, dynamic>>> getCategoriesById(int id) async {
    final db = await database;
    return await db.query('categories', where: 'id = ?', whereArgs: [id]);
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

  // Hiển thị tất cả dữ liệu trong database
  Future<void> showAllTables() async {
    final db = await database;
    final logger = Logger('DatabaseHelper');

    logger.info('\n=== DATABASE TABLES ===\n');

    // Hiển thị bảng Users
    logger.info('📊 USERS TABLE:');
    logger.info('----------------');
    final users = await db.query('users');
    for (var user in users) {
      logger.info('ID: ${user['id']}');
      logger.info('Name: ${user['name']}');
      logger.info('Email: ${user['email']}');
      logger.info('Premium: ${user['premium'] == 1 ? 'Yes' : 'No'}');
      logger.info('----------------');
    }

    // Hiển thị bảng Books
    logger.info('\n📚 BOOKS TABLE:');
    logger.info('----------------');
    final books = await db.query('books');
    for (var book in books) {
      logger.info('ID: ${book['id']}');
      logger.info('Name: ${book['name']}');
      logger.info('Description: ${book['description']}');
      logger.info('Balance: ${book['balance']}');
      logger.info('User ID: ${book['user_id']}');
      logger.info('Created at: ${book['created_at']}');
      logger.info('----------------');
    }

    // Hiển thị bảng Categories
    logger.info('\n🏷 CATEGORIES TABLE:');
    logger.info('----------------');
    final categories = await db.query('categories');
    for (var category in categories) {
      logger.info('ID: ${category['id']}');
      logger.info('Name: ${category['name']}');
      logger.info('Icon: ${category['icon']}');
      logger.info('Type: ${category['type']}');
      logger.info('----------------');
    }

    // Hiển thị bảng Transactions
    logger.info('\n💰 TRANSACTIONS TABLE:');
    logger.info('----------------');
    final transactions = await db.query('transactions');
    for (var transaction in transactions) {
      logger.info('ID: ${transaction['id']}');
      logger.info('Amount: ${transaction['amount']}');
      logger.info('Note: ${transaction['note']}');
      logger.info('Date: ${transaction['date']}');
      logger.info('Type: ${transaction['type']}');
      logger.info('Category ID: ${transaction['category_id']}');
      logger.info('Book ID: ${transaction['book_id']}');
      logger.info('User ID: ${transaction['user_id']}');
      logger.info('----------------');
    }

    logger.info('\n=== END OF DATABASE ===\n');
  }
}

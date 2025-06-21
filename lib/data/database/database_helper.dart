import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logging/logging.dart';
import 'dart:math';

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

    // Bảng Wallets
    await db.execute("""
    CREATE TABLE IF NOT EXISTS wallets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nameBalance TEXT NOT NULL,
        walletBalance REAL DEFAULT 0,
        type Text,
        user_id INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES books (id) ON DELETE CASCADE
      )
    """);

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

    // Bảng Periodic Invoices
    await db.execute('''
      CREATE TABLE IF NOT EXISTS periodic_invoices (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        start_date TEXT NOT NULL,
        frequency TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        is_paid INTEGER NOT NULL,
        last_paid_date TEXT,
        next_due_date TEXT,
        book_id INTEGER,
        FOREIGN KEY (book_id) REFERENCES books (id) ON DELETE SET NULL
      )
    ''');

    // Bảng Notifications
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        time TEXT NOT NULL,
        is_read INTEGER NOT NULL,
        invoice_id TEXT,
        invoice_due_date TEXT
      )
    ''');

    // Bảng Savings Goals
    await db.execute('''
    CREATE TABLE IF NOT EXISTS savings_goals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      target_amount REAL NOT NULL,
      current_amount REAL DEFAULT 0,
      type TEXT CHECK(type IN ('flexible', 'periodic')) NOT NULL,
      periodic_amount REAL,                         -- Chỉ dùng nếu type = periodic
      periodic_frequency TEXT CHECK(periodic_frequency IN ('daily', 'weekly', 'monthly')),
      started_date TIMESTAMP,                       -- Ngày bắt đầu tiết kiệm
      target_date TIMESTAMP,                        -- Ngày mong muốn đạt mục tiêu
      next_reminder_date TIMESTAMP,                -- Dùng để nhắc lần tiếp theo
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      is_active INTEGER DEFAULT 1
    )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS savings_transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          goal_id INTEGER NOT NULL,
          amount REAL NOT NULL,
          note TEXT,
          saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (goal_id) REFERENCES savings_goals(id) ON DELETE CASCADE
      );
    ''');

    // Bảng Recurring Bills
    await db.execute('''
      CREATE TABLE IF NOT EXISTS recurring_bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        day_of_month INTEGER NOT NULL,
        category TEXT NOT NULL,
        note TEXT,
        is_active INTEGER DEFAULT 1,
        book_id INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        last_paid_date TIMESTAMP,
        FOREIGN KEY (book_id) REFERENCES books (id) ON DELETE CASCADE
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

  // CRUD operations cho Wallets
  Future<int> insertWallet(Map<String, dynamic> wallet) async {
    final db = await database;
    return await db.insert('wallets', wallet);
  }

  Future<List<Map<String, dynamic>>> getWalletByUser(int userId) async {
    final db = await database;
    return await db.query('wallets', where: 'user_id = ?', whereArgs: [userId]);
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

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('categories');
  }

  // Future<void> insertSampleTransactions(int userId, int bookId) async {
  //   final db = await database;
  //   final random = Random();
  //   final now = DateTime.now();

  //   // Lấy danh sách categories
  //   final expenseCategories = await getCategoriesByType('expense');
  //   final incomeCategories = await getCategoriesByType('income');

  //   // Tạo dữ liệu mẫu cho 5 tháng
  //   for (int month = 0; month < 5; month++) {
  //     // Tạo 5-10 giao dịch chi tiêu mỗi tháng
  //     int numExpenses = random.nextInt(6) + 5;
  //     for (int i = 0; i < numExpenses; i++) {
  //       final category =
  //           expenseCategories[random.nextInt(expenseCategories.length)];
  //       final amount = (random.nextDouble() * 5000000)
  //           .roundToDouble(); // Số tiền từ 0-5 triệu
  //       final date = DateTime(
  //         now.year,
  //         now.month - month,
  //         random.nextInt(28) + 1,
  //       );

  //       await db.insert('transactions', {
  //         'amount': amount,
  //         'note': 'Giao dịch chi tiêu mẫu ${i + 1}',
  //         'date': date.toIso8601String(),
  //         'type': 'expense',
  //         'category_id': category['id'],
  //         'book_id': bookId,
  //         'user_id': userId,
  //       });
  //     }

  //     // Tạo 1-3 giao dịch thu nhập mỗi tháng
  //     int numIncomes = random.nextInt(1) + 1;
  //     for (int i = 0; i < numIncomes; i++) {
  //       final category =
  //           incomeCategories[random.nextInt(incomeCategories.length)];
  //       final amount = (random.nextDouble() * 15000).roundToDouble();
  //       final date = DateTime(
  //         now.year,
  //         now.month - month,
  //         random.nextInt(28) + 1,
  //       );

  //       await db.insert('transactions', {
  //         'amount': amount,
  //         'note': 'Giao dịch thu nhập mẫu ${i + 1}',
  //         'date': date.toIso8601String(),
  //         'type': 'income',
  //         'category_id': category['id'],
  //         'book_id': bookId,
  //         'user_id': userId,
  //       });
  //     }
  //   }

  // Thêm một hóa đơn định kỳ mới vào bảng periodic_invoices
  // invoice: Map chứa thông tin hóa đơn (id, name, amount, ...)
  // Trả về id của bản ghi vừa thêm (hoặc ghi đè nếu trùng id)
  Future<int> insertPeriodicInvoice(Map<String, dynamic> invoice) async {
    final db = await database;
    return await db.insert(
      'periodic_invoices',
      invoice,
      conflictAlgorithm: ConflictAlgorithm.replace, // Nếu trùng id thì ghi đè
    );
  }

  // Lấy toàn bộ danh sách hóa đơn định kỳ từ bảng periodic_invoices
  // Trả về List<Map> chứa các bản ghi
  Future<List<Map<String, dynamic>>> getAllPeriodicInvoices() async {
    final db = await database;
    return await db.query('periodic_invoices');
  }

  // Cập nhật thông tin một hóa đơn định kỳ dựa trên id
  // invoice: Map chứa thông tin hóa đơn (phải có trường 'id')
  // Trả về số bản ghi đã được cập nhật (thường là 1)
  Future<int> updatePeriodicInvoice(Map<String, dynamic> invoice) async {
    final db = await database;
    return await db.update(
      'periodic_invoices',
      invoice,
      where: 'id = ?',
      whereArgs: [invoice['id']],
    );
  }

  // Xóa một hóa đơn định kỳ khỏi bảng periodic_invoices dựa trên id
  // id: id của hóa đơn cần xóa
  // Trả về số bản ghi đã bị xóa (thường là 1)
  Future<int> deletePeriodicInvoice(String id) async {
    final db = await database;
    return await db.delete(
      'periodic_invoices',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Cập nhật trạng thái thanh toán của hóa đơn định kỳ
  // id: id của hóa đơn
  // isPaid: trạng thái đã thanh toán hay chưa
  // lastPaidDate: ngày thanh toán gần nhất (tùy chọn)
  // nextDueDate: ngày đến hạn tiếp theo (tùy chọn)
  Future<int> updateInvoicePaidStatus(String id, bool isPaid,
      {DateTime? lastPaidDate, DateTime? nextDueDate}) async {
    final db = await database;
    return await db.update(
      'periodic_invoices',
      {
        'is_paid': isPaid ? 1 : 0,
        'last_paid_date': lastPaidDate?.toIso8601String(),
        'next_due_date': nextDueDate?.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Thêm một thông báo mới vào bảng notifications
  Future<int> insertNotification(Map<String, dynamic> notification) async {
    final db = await database;
    return await db.insert('notifications', notification);
  }

  // Lấy toàn bộ danh sách thông báo
  Future<List<Map<String, dynamic>>> getAllNotifications() async {
    final db = await database;
    return await db.query('notifications', orderBy: 'time DESC');
  }

  // Cập nhật trạng thái đã đọc của thông báo
  Future<int> updateNotificationRead(int id, bool isRead) async {
    final db = await database;
    return await db.update(
      'notifications',
      {'is_read': isRead ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Xóa một thông báo
  Future<int> deleteNotification(int id) async {
    final db = await database;
    return await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }
}

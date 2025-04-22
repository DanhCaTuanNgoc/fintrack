import '/data/database/database_helper.dart';
import '/data/models/transaction.dart';

class TransactionRepository {
  final DatabaseHelper _databaseHelper;

  TransactionRepository(this._databaseHelper);

  Future<Transaction> createTransaction(Transaction transaction) async {
    final db = await _databaseHelper.database;
    final id = await db.insert('transactions', transaction.toMap());
    return transaction.copyWith(id: id);
  }

  Future<List<Transaction>> getTransactions() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('transactions', orderBy: 'date DESC');
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<Transaction?> getTransactionById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Transaction.fromMap(maps.first);
  }

  Future<List<Transaction>> getTransactionsByBookId(int bookId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<List<Transaction>> getTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<List<Transaction>> getTransactionsByType(String type) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<List<Transaction>> searchTransactions(String query) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'note LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<bool> updateTransaction(Transaction transaction) async {
    final db = await _databaseHelper.database;
    final count = await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
    return count > 0;
  }

  Future<bool> deleteTransaction(int id) async {
    final db = await _databaseHelper.database;
    final count = await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  Future<bool> deleteAllTransactions() async {
    final db = await _databaseHelper.database;
    final count = await db.delete('transactions');
    return count > 0;
  }
}

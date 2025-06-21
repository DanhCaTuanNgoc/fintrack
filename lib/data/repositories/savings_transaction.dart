// lib/data/repositories/savings_transaction_repository.dart
import '../database/database_helper.dart';
import '../models/savings_transaction.dart';

class SavingsTransactionRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<SavingsTransaction>> getTransactionsByGoal(int goalId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'savings_transactions',
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'saved_at DESC',
    );
    return maps.map((e) => SavingsTransaction.fromMap(e)).toList();
  }

  Future<int> insertTransaction(SavingsTransaction transaction) async {
    final db = await dbHelper.database;
    return await db.insert('savings_transactions', transaction.toMap());
  }

  Future<void> deleteTransaction(int id) async {
    final db = await dbHelper.database;
    await db.delete('savings_transactions', where: 'id = ?', whereArgs: [id]);
  }
}
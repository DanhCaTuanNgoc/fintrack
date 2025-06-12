

import 'package:fintrack/data/database/database_helper.dart';
import 'package:fintrack/data/models/wallet.dart';

class WalletRepository {
  final DatabaseHelper _databaseHelper;

  WalletRepository(this._databaseHelper);

  Future<Wallet> createWallet(Wallet wallet) async {
    final db = await _databaseHelper.database;
    final id = await db.insert('wallets', wallet.toMap());
    return wallet.copyWith(id: id);
  }

  Future<List<Wallet>> getWallets() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('wallets', orderBy: 'name ASC');
    return maps.map((map) => Wallet.fromMap(map)).toList();
  }

  Future<Wallet?> getWalletById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query('wallets', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;
    return Wallet.fromMap(maps.first);
  }

  Future<List<Wallet>> getWalletsByUserId(int userId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'wallets',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Wallet.fromMap(map)).toList();
  }

  Future<bool> updateWallet(Wallet wallet) async {
    final db = await _databaseHelper.database;
    final count = await db.update(
      'wallets',
      wallet.toMap(),
      where: 'id = ?',
      whereArgs: [wallet.id],
    );
    return count > 0;
  }

  Future<bool> deleteWallet(int id) async {
    final db = await _databaseHelper.database;
    final count = await db.delete('wallets', where: 'id = ?', whereArgs: [id]);
    return count > 0;
  }

  Future<bool> deleteAllWallets() async {
    final db = await _databaseHelper.database;
    final count = await db.delete('wallets');
    return count > 0;
  }
}
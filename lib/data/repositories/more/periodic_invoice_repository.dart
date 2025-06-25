import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database_helper.dart';
import '../../models/more/periodic_invoice.dart';
import '../../../providers/currency_provider.dart';

final periodicInvoiceRepositoryProvider = Provider((ref) {
  return PeriodicInvoiceRepository(DatabaseHelper.instance);
});

class PeriodicInvoiceRepository {
  final DatabaseHelper _databaseHelper;

  PeriodicInvoiceRepository(this._databaseHelper);

  Future<void> addPeriodicInvoice(PeriodicInvoice invoice) async {
    final db = await _databaseHelper.database;
    await db.insert('periodic_invoices', invoice.toMap());
  }

  Future<void> removePeriodicInvoice(String id) async {
    final db = await _databaseHelper.database;
    await db.delete('periodic_invoices', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updatePeriodicInvoice(PeriodicInvoice invoice) async {
    final db = await _databaseHelper.database;
    await db.update('periodic_invoices', invoice.toMap(),
        where: 'id = ?', whereArgs: [invoice.id]);
  }

  Future<List<PeriodicInvoice>> getAllPeriodicInvoices() async {
    final db = await _databaseHelper.database;
    final data = await db.query('periodic_invoices');
    return data.map((e) => PeriodicInvoice.fromMap(e)).toList();
  }

  Future<void> markPeriodicInvoiceAsPaid(String id) async {
    final db = await _databaseHelper.database;
    final data =
        await db.query('periodic_invoices', where: 'id = ?', whereArgs: [id]);
    if (data.isEmpty) return;

    final invoice = PeriodicInvoice.fromMap(data.first);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final updated = invoice.copyWith(
      isPaid: true,
      lastPaidDate: today,
      nextDueDate: invoice.copyWith(lastPaidDate: today).calculateNextDueDate(),
    );
    await db.update('periodic_invoices', updated.toMap(),
        where: 'id = ?', whereArgs: [invoice.id]);
  }

  Future<void> updateInvoicePaidStatus(
    String id,
    bool isPaid, {
    DateTime? lastPaidDate,
    DateTime? nextDueDate,
  }) async {
    final db = await _databaseHelper.database;
    await db.update(
        'periodic_invoices',
        {
          'is_paid': isPaid ? 1 : 0,
          'last_paid_date': lastPaidDate?.toIso8601String(),
          'next_due_date': nextDueDate?.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id]);
  }

  Future<void> updateAllPeriodicInvoiceCurrencies(
    CurrencyType oldCurrency,
    CurrencyType newCurrency,
  ) async {
    final db = await _databaseHelper.database;
    final data = await db.query('periodic_invoices');
    for (final invoiceMap in data) {
      final invoice = PeriodicInvoice.fromMap(invoiceMap);
      double newAmount = convertCurrency(
        invoice.amount,
        oldCurrency,
        newCurrency,
      );
      final updatedInvoice = invoice.copyWith(amount: newAmount);
      await db.update('periodic_invoices', updatedInvoice.toMap(),
          where: 'id = ?', whereArgs: [invoice.id]);
    }
  }
}

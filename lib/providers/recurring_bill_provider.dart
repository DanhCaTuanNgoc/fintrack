import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/recurring_bill.dart';
import '../data/database/database_helper.dart';

final recurringBillsProvider = StateNotifierProvider<RecurringBillsNotifier,
    AsyncValue<List<RecurringBill>>>((ref) {
  return RecurringBillsNotifier(ref);
});

class RecurringBillsNotifier
    extends StateNotifier<AsyncValue<List<RecurringBill>>> {
  RecurringBillsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadRecurringBills();
  }

  final Ref ref;

  Future<void> loadRecurringBills() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query('recurring_bills');
      final bills = maps.map((map) => RecurringBill.fromMap(map)).toList();
      state = AsyncValue.data(bills);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addRecurringBill(RecurringBill bill) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final id = await db.insert('recurring_bills', bill.toMap());
      final newBill = bill.copyWith(id: id);
      state.whenData((bills) {
        state = AsyncValue.data([...bills, newBill]);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateRecurringBill(RecurringBill bill) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'recurring_bills',
        bill.toMap(),
        where: 'id = ?',
        whereArgs: [bill.id],
      );
      state.whenData((bills) {
        state = AsyncValue.data(
          bills.map((b) => b.id == bill.id ? bill : b).toList(),
        );
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteRecurringBill(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete(
        'recurring_bills',
        where: 'id = ?',
        whereArgs: [id],
      );
      state.whenData((bills) {
        state = AsyncValue.data(bills.where((b) => b.id != id).toList());
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAsPaid(RecurringBill bill) async {
    try {
      final updatedBill = bill.copyWith(
        lastPaidDate: DateTime.now(),
      );
      await updateRecurringBill(updatedBill);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

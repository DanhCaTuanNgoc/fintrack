import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/more/periodic_invoice.dart';

// FutureProvider để lấy danh sách hóa đơn định kỳ trực tiếp từ database
final periodicInvoicesProvider =
    FutureProvider<List<PeriodicInvoice>>((ref) async {
  final dbHelper = DatabaseHelper.instance;
  final data = await dbHelper.getAllPeriodicInvoices();
  return data.map((e) => PeriodicInvoice.fromMap(e)).toList();
});

// Hàm thêm hóa đơn định kỳ
Future<void> addPeriodicInvoice(PeriodicInvoice invoice, WidgetRef ref) async {
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.insertPeriodicInvoice(invoice.toMap());
  ref.invalidate(periodicInvoicesProvider);
}

// Hàm xóa hóa đơn định kỳ
Future<void> removePeriodicInvoice(String id, WidgetRef ref) async {
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.deletePeriodicInvoice(id);
  ref.invalidate(periodicInvoicesProvider);
}

// Hàm đánh dấu đã thanh toán
Future<void> markPeriodicInvoiceAsPaid(String id, WidgetRef ref) async {
  final dbHelper = DatabaseHelper.instance;
  final data = await dbHelper.getAllPeriodicInvoices();
  final invoice =
      data.map((e) => PeriodicInvoice.fromMap(e)).firstWhere((e) => e.id == id);
  final updated = invoice.copyWith(
    isPaid: true,
    lastPaidDate: DateTime.now(),
    nextDueDate: invoice.calculateNextDueDate(),
  );
  await dbHelper.updatePeriodicInvoice(updated.toMap());
  ref.invalidate(periodicInvoicesProvider);
}

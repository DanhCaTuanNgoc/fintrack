import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/more/periodic_invoice.dart';

// StateNotifierProvider để quản lý trạng thái hóa đơn định kỳ
final periodicInvoicesProvider =
    StateNotifierProvider<PeriodicInvoicesNotifier, List<PeriodicInvoice>>(
        (ref) {
  return PeriodicInvoicesNotifier();
});

class PeriodicInvoicesNotifier extends StateNotifier<List<PeriodicInvoice>> {
  PeriodicInvoicesNotifier() : super([]) {
    _loadFromDb();
  }

  Future<void> _loadFromDb() async {
    final data = await DatabaseHelper.instance.getAllPeriodicInvoices();
    state = data.map((e) => PeriodicInvoice.fromMap(e)).toList();
  }

  // Phương thức để làm mới dữ liệu
  Future<void> refresh() async {
    await _loadFromDb();
  }

  // Thêm hóa đơn định kỳ mới
  Future<void> addPeriodicInvoice(PeriodicInvoice invoice) async {
    await DatabaseHelper.instance.insertPeriodicInvoice(invoice.toMap());
    await _loadFromDb();
  }

  // Xóa hóa đơn định kỳ
  Future<void> removePeriodicInvoice(String id) async {
    await DatabaseHelper.instance.deletePeriodicInvoice(id);
    await _loadFromDb();
  }

  // Đánh dấu hóa đơn đã thanh toán
  Future<void> markPeriodicInvoiceAsPaid(String id) async {
    final data = await DatabaseHelper.instance.getAllPeriodicInvoices();
    final invoice = data
        .map((e) => PeriodicInvoice.fromMap(e))
        .firstWhere((e) => e.id == id);
    final updated = invoice.copyWith(
      isPaid: true,
      lastPaidDate: DateTime.now(),
      nextDueDate: invoice.calculateNextDueDate(),
    );
    await DatabaseHelper.instance.updatePeriodicInvoice(updated.toMap());
    await _loadFromDb();
  }

  // Cập nhật trạng thái hóa đơn định kỳ
  Future<void> updateInvoicePaidStatus(
    String id,
    bool isPaid, {
    DateTime? lastPaidDate,
    DateTime? nextDueDate,
  }) async {
    await DatabaseHelper.instance.updateInvoicePaidStatus(
      id,
      isPaid,
      lastPaidDate: lastPaidDate,
      nextDueDate: nextDueDate,
    );
    await _loadFromDb();
  }

  // Làm mới trạng thái hóa đơn định kỳ nếu đã đến hạn
  Future<void> refreshPeriodicInvoices() async {
    final now = DateTime.now();
    for (final invoice in state) {
      final nextDue = invoice.nextDueDate ?? invoice.calculateNextDueDate();
      // Nếu hóa đơn đã thanh toán và đã đến hạn mới thì chuyển về chưa thanh toán và cập nhật nextDueDate
      if (invoice.isPaid &&
          (now.isAfter(nextDue) ||
              (now.year == nextDue.year &&
                  now.month == nextDue.month &&
                  now.day == nextDue.day))) {
        await DatabaseHelper.instance.updateInvoicePaidStatus(
          invoice.id,
          false,
          lastPaidDate: null,
          nextDueDate: invoice.calculateNextDueDate(),
        );
      }
    }
    await _loadFromDb();
  }
}

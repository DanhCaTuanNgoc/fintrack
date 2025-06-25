import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/more/periodic_invoice.dart';
import '../../data/repositories/more/periodic_invoice_repository.dart';

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
    final data = await PeriodicInvoiceRepository().getAllPeriodicInvoices();
    state = data;
  }

  // Phương thức để làm mới dữ liệu
  Future<void> refresh() async {
    await _loadFromDb();
  }

  // Thêm hóa đơn định kỳ mới
  Future<void> addPeriodicInvoice(PeriodicInvoice invoice) async {
    await PeriodicInvoiceRepository().addPeriodicInvoice(invoice);
    await _loadFromDb();
  }

  // Xóa hóa đơn định kỳ
  Future<void> removePeriodicInvoice(String id) async {
    await PeriodicInvoiceRepository().removePeriodicInvoice(id);
    await _loadFromDb();
  }

  // Đánh dấu hóa đơn đã thanh toán
  Future<void> markPeriodicInvoiceAsPaid(String id) async {
    final data = await PeriodicInvoiceRepository().getAllPeriodicInvoices();
    final invoice = data.firstWhere((e) => e.id == id);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final updated = invoice.copyWith(
      isPaid: true,
      lastPaidDate: today,
      nextDueDate: invoice.copyWith(lastPaidDate: today).calculateNextDueDate(),
    );
    await PeriodicInvoiceRepository().updatePeriodicInvoice(updated);
    await _loadFromDb();
  }

  // Cập nhật trạng thái hóa đơn định kỳ
  Future<void> updateInvoicePaidStatus(
    String id,
    bool isPaid, {
    DateTime? lastPaidDate,
    DateTime? nextDueDate,
  }) async {
    await PeriodicInvoiceRepository().updateInvoicePaidStatus(
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
    final today = DateTime(now.year, now.month, now.day);
    for (final invoice in state) {
      final nextDue = invoice.nextDueDate ?? invoice.calculateNextDueDate();
      // Nếu hóa đơn đã thanh toán và đã đến hạn mới thì chuyển về chưa thanh toán và cập nhật nextDueDate
      if (invoice.isPaid &&
          (today.isAfter(nextDue) ||
              (today.year == nextDue.year &&
                  today.month == nextDue.month &&
                  today.day == nextDue.day))) {
        await PeriodicInvoiceRepository().updateInvoicePaidStatus(
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

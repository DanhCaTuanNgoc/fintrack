import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/more/periodic_invoice.dart';

// Provider để quản lý danh sách hóa đơn định kỳ
final periodicInvoicesProvider =
    StateNotifierProvider<PeriodicInvoicesNotifier, List<PeriodicInvoice>>(
        (ref) {
  return PeriodicInvoicesNotifier();
});

class PeriodicInvoicesNotifier extends StateNotifier<List<PeriodicInvoice>> {
  PeriodicInvoicesNotifier() : super([]);

  void addInvoice(PeriodicInvoice invoice) {
    final nextDueDate = invoice.calculateNextDueDate();
    state = [...state, invoice.copyWith(nextDueDate: nextDueDate)];
  }

  void removeInvoice(String id) {
    state = state.where((invoice) => invoice.id != id).toList();
  }

  void markAsPaid(String id) {
    state = state.map((invoice) {
      if (invoice.id == id) {
        final nextDueDate = invoice.calculateNextDueDate();
        return invoice.copyWith(
          isPaid: true,
          lastPaidDate: DateTime.now(),
          nextDueDate: nextDueDate,
        );
      }
      return invoice;
    }).toList();
  }
}

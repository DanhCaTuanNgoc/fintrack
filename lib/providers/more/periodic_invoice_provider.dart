import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/more/periodic_invoice.dart';
import '../../data/repositories/more/periodic_invoice_repository.dart';
import '../../data/database/database_helper.dart';

// StateNotifierProvider để quản lý trạng thái hóa đơn định kỳ
final periodicInvoicesProvider =
    AsyncNotifierProvider<PeriodicInvoicesNotifier, List<PeriodicInvoice>>(() {
  return PeriodicInvoicesNotifier();
});

class PeriodicInvoicesNotifier extends AsyncNotifier<List<PeriodicInvoice>> {
  Future<List<PeriodicInvoice>> _fetchInvoices() async {
    final repository = ref.read(periodicInvoiceRepositoryProvider);
    return await repository.getAllPeriodicInvoices();
  }

  @override
  FutureOr<List<PeriodicInvoice>> build() async {
    return _fetchInvoices();
  }

  Future<void> addPeriodicInvoice(PeriodicInvoice invoice) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(periodicInvoiceRepositoryProvider);
      await repository.addPeriodicInvoice(invoice);
      return _fetchInvoices();
    });
  }

  Future<void> removePeriodicInvoice(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(periodicInvoiceRepositoryProvider);
      await repository.removePeriodicInvoice(id);
      return _fetchInvoices();
    });
  }

  Future<void> markPeriodicInvoiceAsPaid(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(periodicInvoiceRepositoryProvider);
      final invoices = await repository.getAllPeriodicInvoices();
      final invoice = invoices.firstWhere((e) => e.id == id);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final updatedInvoice = invoice.copyWith(
        isPaid: true,
        lastPaidDate: today,
        nextDueDate:
            invoice.copyWith(lastPaidDate: today).calculateNextDueDate(),
      );

      await repository.updatePeriodicInvoice(updatedInvoice);
      return _fetchInvoices();
    });
  }

  Future<void> refreshPeriodicInvoices() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(periodicInvoiceRepositoryProvider);
      final invoices = await repository.getAllPeriodicInvoices();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (final invoice in invoices) {
        final nextDue = invoice.nextDueDate ?? invoice.calculateNextDueDate();
        if (invoice.isPaid &&
            (today.isAfter(nextDue) || today.isAtSameMomentAs(nextDue))) {
          final refreshedInvoice = invoice.copyWith(
              isPaid: false, nextDueDate: invoice.calculateNextDueDate());
          await repository.updatePeriodicInvoice(refreshedInvoice);
        }
      }
      return _fetchInvoices();
    });
  }
}

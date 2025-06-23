import '../../database/database_helper.dart';
import '../../models/more/periodic_invoice.dart';
import '../../../providers/currency_provider.dart';

class PeriodicInvoiceRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<void> addPeriodicInvoice(PeriodicInvoice invoice) async {
    await dbHelper.insertPeriodicInvoice(invoice.toMap());
  }

  Future<void> removePeriodicInvoice(String id) async {
    await dbHelper.deletePeriodicInvoice(id);
  }

  Future<void> updatePeriodicInvoice(PeriodicInvoice invoice) async {
    await dbHelper.updatePeriodicInvoice(invoice.toMap());
  }

  Future<List<PeriodicInvoice>> getAllPeriodicInvoices() async {
    final data = await dbHelper.getAllPeriodicInvoices();
    return data.map((e) => PeriodicInvoice.fromMap(e)).toList();
  }

  Future<void> markPeriodicInvoiceAsPaid(String id) async {
    final data = await dbHelper.getAllPeriodicInvoices();
    final invoice = data
        .map((e) => PeriodicInvoice.fromMap(e))
        .firstWhere((e) => e.id == id);
    final updated = invoice.copyWith(
      isPaid: true,
      lastPaidDate: DateTime.now(),
      nextDueDate: invoice.calculateNextDueDate(),
    );
    await dbHelper.updatePeriodicInvoice(updated.toMap());
  }

  Future<void> updateInvoicePaidStatus(
    String id,
    bool isPaid, {
    DateTime? lastPaidDate,
    DateTime? nextDueDate,
  }) async {
    await dbHelper.updateInvoicePaidStatus(
      id,
      isPaid,
      lastPaidDate: lastPaidDate,
      nextDueDate: nextDueDate,
    );
  }

  Future<void> updateAllPeriodicInvoiceCurrencies(
    CurrencyType oldCurrency,
    CurrencyType newCurrency,
  ) async {
    final data = await dbHelper.getAllPeriodicInvoices();
    for (final invoice in data.map((e) => PeriodicInvoice.fromMap(e))) {
      double newAmount = convertCurrency(
        invoice.amount,
        oldCurrency,
        newCurrency,
      );
      final updatedInvoice = invoice.copyWith(amount: newAmount);
      await dbHelper.updatePeriodicInvoice(updatedInvoice.toMap());
    }
  }
}

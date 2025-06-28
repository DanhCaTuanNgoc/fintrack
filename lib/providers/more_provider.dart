import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'currency_provider.dart';
import 'more/transaction_provider.dart';
import '../data/database/database_helper.dart';
import '../data/models/more/periodic_invoice.dart';
import 'package:flutter/material.dart';
import 'book_provider.dart';
import '../data/repositories/more/periodic_invoice_repository.dart';

// ================= MORE SCREEN UTILS =================
Future<int> loadThemeColor() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('theme_color') ?? 0;
}

Future<void> removeAllData(WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  Logger.root.info('\x1B[32mSuccessfully cleared SharedPreferences\x1B[0m');
  await ref.read(booksProvider.notifier).deleteAllBooks();
}

Future<void> updateCurrencyAndData(
  BuildContext context,
  WidgetRef ref,
  CurrencyType newCurrency,
) async {
  final oldCurrency = ref.read(currencyProvider);
  if (oldCurrency != newCurrency) {
    await updateAllTransactionCurrencies(ref, oldCurrency, newCurrency);
    await updateAllPeriodicInvoiceCurrencies(ref, oldCurrency, newCurrency);
    await ref.read(currencyProvider.notifier).setCurrency(newCurrency);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã chuyển sang \\${newCurrency.displayName} và cập nhật tất cả giao dịch, hóa đơn định kỳ',
        ),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }
}

Future<void> updateAllTransactionCurrencies(
  WidgetRef ref,
  CurrencyType oldCurrency,
  CurrencyType newCurrency,
) async {
  final repository = ref.read(transactionRepositoryProvider);
  final transactions = await repository.getTransactions();
  for (final transaction in transactions) {
    double newAmount = convertCurrency(
      transaction.amount,
      oldCurrency,
      newCurrency,
    );
    final updatedTransaction = transaction.copyWith(amount: newAmount);
    await repository.updateTransaction(updatedTransaction);
  }
}

final _periodicInvoiceRepo = PeriodicInvoiceRepository(DatabaseHelper.instance);

Future<void> updateAllPeriodicInvoiceCurrencies(
  WidgetRef ref,
  CurrencyType oldCurrency,
  CurrencyType newCurrency,
) async {
  await _periodicInvoiceRepo.updateAllPeriodicInvoiceCurrencies(
      oldCurrency, newCurrency);
}

Future<void> addPeriodicInvoice(WidgetRef ref, PeriodicInvoice invoice) async {
  await _periodicInvoiceRepo.addPeriodicInvoice(invoice);
}

Future<void> removePeriodicInvoice(WidgetRef ref, String id) async {
  await _periodicInvoiceRepo.removePeriodicInvoice(id);
}

Future<void> updatePeriodicInvoice(
    WidgetRef ref, PeriodicInvoice invoice) async {
  await _periodicInvoiceRepo.updatePeriodicInvoice(invoice);
}

Future<List<PeriodicInvoice>> getAllPeriodicInvoices(WidgetRef ref) async {
  return await _periodicInvoiceRepo.getAllPeriodicInvoices();
}

Future<void> markPeriodicInvoiceAsPaid(WidgetRef ref, String id) async {
  await _periodicInvoiceRepo.markPeriodicInvoiceAsPaid(id);
}

Future<void> updateInvoicePaidStatus(
  WidgetRef ref,
  String id,
  bool isPaid, {
  DateTime? lastPaidDate,
  DateTime? nextDueDate,
}) async {
  await _periodicInvoiceRepo.updateInvoicePaidStatus(
    id,
    isPaid,
    lastPaidDate: lastPaidDate,
    nextDueDate: nextDueDate,
  );
}

// ... giữ lại các hàm tiện ích cho transaction và periodic invoice như trước ...

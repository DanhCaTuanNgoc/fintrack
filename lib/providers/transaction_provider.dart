import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< HEAD
<<<<<<< Updated upstream
import '../data/database/database_helper.dart';
=======
>>>>>>> develop
import '../data/models/transaction.dart';
=======
import '../data/models/more/transaction.dart';
>>>>>>> Stashed changes
import '../data/repositories/transaction_repository.dart';
import 'currency_provider.dart';
import './database_provider.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return TransactionRepository(dbHelper);
});

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, AsyncValue<List<Transaction>>>((
  ref,
) {
  return TransactionsNotifier(ref);
});

class TransactionsNotifier
    extends StateNotifier<AsyncValue<List<Transaction>>> {
  TransactionsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  final Ref ref;

  Future<void> loadTransactions() async {
    try {
      final repository = ref.read(transactionRepositoryProvider);
      final transactions = await repository.getTransactions();
      state = AsyncValue.data(transactions);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createTransaction({
    required double amount,
    required String note,
    required String type,
    required int categoryId,
    required int bookId,
    required int userId,
  }) async {
    try {
      final repository = ref.read(transactionRepositoryProvider);
      final transaction = Transaction(
        amount: amount,
        note: note,
        type: type,
        categoryId: categoryId,
        bookId: bookId,
        userId: userId,
        date: DateTime.now(),
      );
      await repository.createTransaction(transaction);
      await loadTransactions();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateAllTransactionCurrencies(
    CurrencyType oldCurrency,
    CurrencyType newCurrency,
  ) async {
    try {
      state.whenData((transactions) async {
        final repository = ref.read(transactionRepositoryProvider);

        // Cập nhật mỗi giao dịch với số tiền đã được chuyển đổi
        for (final transaction in transactions) {
          double newAmount = convertCurrency(
            transaction.amount,
            oldCurrency,
            newCurrency,
          );

          // Cập nhật giao dịch với số tiền mới
          final updatedTransaction = transaction.copyWith(amount: newAmount);
          await repository.updateTransaction(updatedTransaction);
        }

        // Tải lại danh sách giao dịch sau khi cập nhật
        await loadTransactions();
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      final repository = ref.read(transactionRepositoryProvider);
      await repository.updateTransaction(transaction);
      await loadTransactions();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      final repository = ref.read(transactionRepositoryProvider);
      await repository.deleteTransaction(id);
      await loadTransactions();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteAllTransactions() async {
    try {
      final repository = ref.read(transactionRepositoryProvider);
      await repository.deleteAllTransactions();
      await loadTransactions();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> getTransactionByDate(DateTime datekey) async {
    try {
      final repository = ref.read(transactionRepositoryProvider);
      await repository.getTransactionsByDate(datekey);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

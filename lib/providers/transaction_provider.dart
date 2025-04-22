import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/database_helper.dart';
import '../data/models/transaction.dart';
import '../data/repositories/transaction_repository.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return TransactionRepository(dbHelper);
});

final transactionsProvider = StateNotifierProvider<TransactionsNotifier, AsyncValue<List<Transaction>>>((ref) {
  return TransactionsNotifier(ref);
});

class TransactionsNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
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
      );
      await repository.createTransaction(transaction);
      await loadTransactions();
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
}

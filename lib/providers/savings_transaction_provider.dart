import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/savings_transaction.dart';
import '../data/repositories/savings_transaction.dart';

final savingsTransactionRepositoryProvider =
    Provider((ref) => SavingsTransactionRepository());

final savingsTransactionsProvider = StateNotifierProvider.family<
    SavingsTransactionsNotifier, List<SavingsTransaction>, int>(
  (ref, goalId) => SavingsTransactionsNotifier(
    repository: ref.read(savingsTransactionRepositoryProvider),
    goalId: goalId,
  ),
);

class SavingsTransactionsNotifier
    extends StateNotifier<List<SavingsTransaction>> {
  final SavingsTransactionRepository repository;
  final int goalId;

  SavingsTransactionsNotifier({required this.repository, required this.goalId})
      : super([]) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = await repository.getTransactionsByGoal(goalId);
  }

  Future<void> addTransaction(SavingsTransaction transaction) async {
    await repository.insertTransaction(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await repository.deleteTransaction(id);
    await loadTransactions();
  }
}

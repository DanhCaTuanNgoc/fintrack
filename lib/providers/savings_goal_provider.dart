import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/savings_goal.dart';
import '../data/database/database_helper.dart';

final savingsGoalsProvider =
    StateNotifierProvider<SavingsGoalsNotifier, AsyncValue<List<SavingsGoal>>>(
        (ref) {
  return SavingsGoalsNotifier(ref);
});

class SavingsGoalsNotifier
    extends StateNotifier<AsyncValue<List<SavingsGoal>>> {
  SavingsGoalsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadSavingsGoals();
  }

  final Ref ref;

  Future<void> loadSavingsGoals() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'savings_goals',
        orderBy: 'created_at DESC',
      );
      final goals = maps.map((map) => SavingsGoal.fromMap(map)).toList();
      state = AsyncValue.data(goals);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addSavingsGoal(SavingsGoal goal) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final id = await db.insert('savings_goals', goal.toMap());
      final newGoal = goal.copyWith(id: id);
      state.whenData((goals) {
        state = AsyncValue.data([newGoal, ...goals]);
      });
      print("add successfully");
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'savings_goals',
        goal.toMap(),
        where: 'id = ?',
        whereArgs: [goal.id],
      );

      // Cập nhật state với dữ liệu mới
      state.whenData((goals) {
        final updatedGoals =
            goals.map((g) => g.id == goal.id ? goal : g).toList();
        state = AsyncValue.data(updatedGoals);
      });

    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteSavingsGoal(SavingsGoal goal) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete(
        'savings_goals',
        where: 'id = ?',
        whereArgs: [goal.id],
      );
      state.whenData((goals) {
        state = AsyncValue.data(
          goals.where((g) => g.id != goal.id).toList(),
        );
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addAmountToGoal(int goalId, double amount) async {
    try {
      state.whenData((goals) {
        final goalIndex = goals.indexWhere((g) => g.id == goalId);
        if (goalIndex != -1) {
          final goal = goals[goalIndex];
          final updatedGoal = goal.copyWith(
            currentAmount: goal.currentAmount + amount,
          );

          // Update in database
          updateSavingsGoal(updatedGoal);
        }
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  List<SavingsGoal> getFlexibleGoals() {
    return state.when(
      data: (goals) => goals.where((g) => g.type == 'flexible').toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  List<SavingsGoal> getPeriodicGoals() {
    return state.when(
      data: (goals) => goals.where((g) => g.type == 'periodic').toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }
}

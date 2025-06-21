// lib/data/models/savings_transaction.dart
class SavingsTransaction {
  final int? id;
  final int goalId;
  final double amount;
  final String? note;
  final DateTime savedAt;

  SavingsTransaction({
    this.id,
    required this.goalId,
    required this.amount,
    this.note,
    required this.savedAt,
  });

  factory SavingsTransaction.fromMap(Map<String, dynamic> map) {
    return SavingsTransaction(
      id: map['id'],
      goalId: map['goal_id'],
      amount: map['amount'],
      note: map['note'],
      savedAt: DateTime.parse(map['saved_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'amount': amount,
      'note': note,
      'saved_at': savedAt.toIso8601String(),
    };
  }
}
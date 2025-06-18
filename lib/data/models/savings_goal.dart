class SavingsGoal {
  final int? id;
  final String name;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final String type; // 'flexible' or 'periodic'
  final int? bookId;
  final DateTime createdAt;
  final DateTime? targetDate;
  final double? periodicAmount; // For periodic savings
  final String? periodicFrequency; // 'daily', 'weekly', 'monthly'
  final bool isActive;

  SavingsGoal({
    this.id,
    required this.name,
    required this.description,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.type,
    this.bookId,
    DateTime? createdAt,
    this.targetDate,
    this.periodicAmount,
    this.periodicFrequency,
    this.isActive = true,
  }) : this.createdAt = createdAt ?? DateTime.now();

  SavingsGoal copyWith({
    int? id,
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    String? type,
    int? bookId,
    DateTime? createdAt,
    DateTime? targetDate,
    double? periodicAmount,
    String? periodicFrequency,
    bool? isActive,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      type: type ?? this.type,
      bookId: bookId ?? this.bookId,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      periodicAmount: periodicAmount ?? this.periodicAmount,
      periodicFrequency: periodicFrequency ?? this.periodicFrequency,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'type': type,
      'book_id': bookId,
      'created_at': createdAt.toIso8601String(),
      'target_date': targetDate?.toIso8601String(),
      'periodic_amount': periodicAmount,
      'periodic_frequency': periodicFrequency,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      targetAmount: map['target_amount'],
      currentAmount: map['current_amount'],
      type: map['type'],
      bookId: map['book_id'],
      createdAt: DateTime.parse(map['created_at']),
      targetDate: map['target_date'] != null
          ? DateTime.parse(map['target_date'])
          : null,
      periodicAmount: map['periodic_amount'],
      periodicFrequency: map['periodic_frequency'],
      isActive: map['is_active'] == 1,
    );
  }

  // Helper methods
  double get progressPercentage =>
      targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0;

  double get remainingAmount => targetAmount - currentAmount;

  bool get isCompleted => currentAmount >= targetAmount;

  String get progressText =>
      '${currentAmount.toStringAsFixed(0)} / ${targetAmount.toStringAsFixed(0)}';
}

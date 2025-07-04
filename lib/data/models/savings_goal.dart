class SavingsGoal {
  final int? id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String type; // 'flexible' or 'periodic'
  final DateTime createdAt;
  final DateTime? startedDate;
  final DateTime? targetDate;
  final double? periodicAmount; // For periodic savings
  final String? periodicFrequency; // 'daily', 'weekly', 'monthly'
  final DateTime? nextReminderDate; // Dùng để nhắc lần tiếp theo
  final bool isActive;

  SavingsGoal({
    this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.type,
    DateTime? createdAt,
    this.startedDate,
    this.targetDate,
    this.periodicAmount,
    this.periodicFrequency,
    this.nextReminderDate,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  SavingsGoal copyWith({
    int? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    String? type,
    DateTime? createdAt,
    DateTime? targetDate,
    DateTime? startedDate,
    double? periodicAmount,
    String? periodicFrequency,
    DateTime? nextReminderDate,
    bool? isActive,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      startedDate: startedDate ?? this.startedDate,
      periodicAmount: periodicAmount ?? this.periodicAmount,
      periodicFrequency: periodicFrequency ?? this.periodicFrequency,
      nextReminderDate: nextReminderDate ?? this.nextReminderDate,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'started_date': startedDate?.toIso8601String(),
      'target_date': targetDate?.toIso8601String(),
      'periodic_amount': periodicAmount,
      'periodic_frequency': periodicFrequency,
      'next_reminder_date': nextReminderDate?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'],
      name: map['name'],
      targetAmount: map['target_amount'],
      currentAmount: map['current_amount'],
      type: map['type'],
      createdAt: DateTime.parse(map['created_at']),
      startedDate: map['started_date'] != null
          ? DateTime.parse(map['started_date'])
          : null,
      targetDate: map['target_date'] != null
          ? DateTime.parse(map['target_date'])
          : null,
      periodicAmount: map['periodic_amount'],
      periodicFrequency: map['periodic_frequency'],
      nextReminderDate: map['next_reminder_date'] != null
          ? DateTime.parse(map['next_reminder_date'])
          : null,
      isActive: map['is_active'] == 1,
    );
  }

  // Helper methods
  double get progressPercentage =>
      targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0;

  double get remainingAmount => targetAmount - currentAmount;

  bool get isCompleted {
    final now = DateTime.now();
    if (currentAmount >= targetAmount) {
      if (targetDate == null ||
          now.isBefore(targetDate!) ||
          now.isAtSameMomentAs(targetDate!)) {
        return true;
      }
    }
    return false;
  }

  // Tính toán ngày nhắc nhở tiếp theo dựa trên tần suất
  DateTime calculateNextReminderDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Nếu là mục tiêu linh hoạt, nhắc nhở hàng tuần
    if (type == 'flexible') {
      return DateTime(
        today.year,
        today.month,
        today.day + 7,
      );
    }

    // Nếu là mục tiêu định kỳ, tính theo tần suất
    if (type == 'periodic' && periodicFrequency != null) {
      switch (periodicFrequency!) {
        case 'daily':
          return DateTime(
            today.year,
            today.month,
            today.day + 1,
          );
        case 'weekly':
          return DateTime(
            today.year,
            today.month,
            today.day + 7,
          );
        case 'monthly':
          int nextMonth = today.month + 1;
          int nextYear = today.year;
          if (nextMonth > 12) {
            nextMonth = 1;
            nextYear++;
          }
          // Đảm bảo ngày hợp lệ
          int day = today.day;
          while (day > 28) {
            try {
              DateTime(nextYear, nextMonth, day);
              break;
            } catch (e) {
              day--;
            }
          }
          return DateTime(nextYear, nextMonth, day);
        default:
          return DateTime(
            today.year,
            today.month,
            today.day + 7,
          );
      }
    }

    // Mặc định nhắc nhở hàng tuần
    return DateTime(
      today.year,
      today.month,
      today.day + 7,
    );
  }

  // Kiểm tra xem có cần nhắc nhở không
  bool needsReminder() {
    if (isCompleted || !isActive) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextReminder = nextReminderDate ?? calculateNextReminderDate();

    return today.isAfter(nextReminder) ||
        (today.year == nextReminder.year &&
            today.month == nextReminder.month &&
            today.day == nextReminder.day);
  }

  // Kiểm tra xem mục tiêu có sắp đến hạn không (trước 7 ngày)
  bool isAlmostDue({int daysBefore = 7}) {
    if (isCompleted || !isActive || targetDate == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target =
        DateTime(targetDate!.year, targetDate!.month, targetDate!.day);
    final diff = target.difference(today).inDays;

    return diff > 0 && diff <= daysBefore;
  }
}

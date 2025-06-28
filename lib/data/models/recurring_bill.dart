class RecurringBill {
  final int? id;
  final String title;
  final double amount;
  final int dayOfMonth;
  final String category;
  final String note;
  final bool isActive;
  final int bookId;
  final DateTime createdAt;
  final DateTime? lastPaidDate;

  RecurringBill({
    this.id,
    required this.title,
    required this.amount,
    required this.dayOfMonth,
    required this.category,
    required this.note,
    this.isActive = true,
    required this.bookId,
    DateTime? createdAt,
    this.lastPaidDate,
  }) : this.createdAt = createdAt ?? DateTime.now();

  RecurringBill copyWith({
    int? id,
    String? title,
    double? amount,
    int? dayOfMonth,
    String? category,
    String? note,
    bool? isActive,
    int? bookId,
    DateTime? createdAt,
    DateTime? lastPaidDate,
  }) {
    return RecurringBill(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      category: category ?? this.category,
      note: note ?? this.note,
      isActive: isActive ?? this.isActive,
      bookId: bookId ?? this.bookId,
      createdAt: createdAt ?? this.createdAt,
      lastPaidDate: lastPaidDate ?? this.lastPaidDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'day_of_month': dayOfMonth,
      'category': category,
      'note': note,
      'is_active': isActive ? 1 : 0,
      'book_id': bookId,
      'created_at': createdAt.toIso8601String(),
      'last_paid_date': lastPaidDate?.toIso8601String(),
    };
  }

  factory RecurringBill.fromMap(Map<String, dynamic> map) {
    return RecurringBill(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      dayOfMonth: map['day_of_month'],
      category: map['category'],
      note: map['note'],
      isActive: map['is_active'] == 1,
      bookId: map['book_id'],
      createdAt: DateTime.parse(map['created_at']),
      lastPaidDate: map['last_paid_date'] != null
          ? DateTime.parse(map['last_paid_date'])
          : null,
    );
  }
}

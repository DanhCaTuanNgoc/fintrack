class NotificationItem {
  final int? id;
  final String title;
  final String message;
  final DateTime time;
  final bool isRead;
  final String? invoiceId;
  final DateTime? invoiceDueDate;
  final String? goalId;

  NotificationItem({
    this.id,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
    this.invoiceId,
    this.invoiceDueDate,
    this.goalId,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'],
      title: map['title'],
      message: map['message'],
      time: DateTime.parse(map['time']),
      isRead: map['is_read'] == 1,
      invoiceId: map['invoice_id'],
      invoiceDueDate: map['invoice_due_date'] != null
          ? DateTime.tryParse(map['invoice_due_date'])
          : null,
      goalId: map['goal_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'time': time.toIso8601String(),
      'is_read': isRead ? 1 : 0,
      'invoice_id': invoiceId,
      'invoice_due_date': invoiceDueDate?.toIso8601String(),
      'goal_id': goalId,
    };
  }

  NotificationItem copyWith({
    int? id,
    String? title,
    String? message,
    DateTime? time,
    bool? isRead,
    String? invoiceId,
    DateTime? invoiceDueDate,
    String? goalId,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      invoiceId: invoiceId ?? this.invoiceId,
      invoiceDueDate: invoiceDueDate ?? this.invoiceDueDate,
      goalId: goalId ?? this.goalId,
    );
  }
}

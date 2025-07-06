import '../../../utils/localization.dart';

enum NotificationType {
  periodicInvoice,
  savingsGoal,
  savingsGoalDue,
  savingsGoalCompleted,
}

class NotificationItem {
  final int? id;
  final NotificationType type;
  final DateTime time;
  final bool isRead;
  final String? invoiceId;
  final DateTime? invoiceDueDate;
  final String? goalId;
  final String? itemName; // Tên hóa đơn hoặc mục tiêu tiết kiệm
  final double? amount; // Số tiền (cho mục tiêu tiết kiệm định kỳ)
  final int? remainingDays; // Số ngày còn lại (cho mục tiêu sắp đến hạn)

  NotificationItem({
    this.id,
    required this.type,
    required this.time,
    this.isRead = false,
    this.invoiceId,
    this.invoiceDueDate,
    this.goalId,
    this.itemName,
    this.amount,
    this.remainingDays,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${map['type']}',
        orElse: () => NotificationType.periodicInvoice,
      ),
      time: DateTime.parse(map['time']),
      isRead: map['is_read'] == 1,
      invoiceId: map['invoice_id'],
      invoiceDueDate: map['invoice_due_date'] != null
          ? DateTime.tryParse(map['invoice_due_date'])
          : null,
      goalId: map['goal_id'],
      itemName: map['item_name'],
      amount: map['amount'] != null ? double.parse(map['amount']) : null,
      remainingDays: map['remaining_days'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'time': time.toIso8601String(),
      'is_read': isRead ? 1 : 0,
      'invoice_id': invoiceId,
      'invoice_due_date': invoiceDueDate?.toIso8601String(),
      'goal_id': goalId,
      'item_name': itemName,
      'amount': amount?.toString(),
      'remaining_days': remainingDays,
    };
  }

  NotificationItem copyWith({
    int? id,
    NotificationType? type,
    DateTime? time,
    bool? isRead,
    String? invoiceId,
    DateTime? invoiceDueDate,
    String? goalId,
    String? itemName,
    double? amount,
    int? remainingDays,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      invoiceId: invoiceId ?? this.invoiceId,
      invoiceDueDate: invoiceDueDate ?? this.invoiceDueDate,
      goalId: goalId ?? this.goalId,
      itemName: itemName ?? this.itemName,
      amount: amount ?? this.amount,
      remainingDays: remainingDays ?? this.remainingDays,
    );
  }

  // Phương thức để tạo title và message theo ngôn ngữ hiện tại
  String getTitle(AppLocalizations l10n) {
    switch (type) {
      case NotificationType.periodicInvoice:
        return l10n.periodicInvoices;
      case NotificationType.savingsGoal:
      case NotificationType.savingsGoalDue:
      case NotificationType.savingsGoalCompleted:
        return l10n.savingsGoals;
    }
  }

  String getMessage(AppLocalizations l10n) {
    switch (type) {
      case NotificationType.periodicInvoice:
        if (invoiceDueDate != null) {
          final now = DateTime.now();
          final diff = invoiceDueDate!
              .difference(DateTime(now.year, now.month, now.day))
              .inDays;
          if (diff > 0 && diff <= 2) {
            return '${l10n.invoiceName} "$itemName" ${l10n.overdue}: ${invoiceDueDate!.day}/${invoiceDueDate!.month}/${invoiceDueDate!.year}';
          } else {
            return '${l10n.invoiceName} "$itemName" ${l10n.overdue}';
          }
        }
        return '${l10n.invoiceName} "$itemName" ${l10n.overdue}';

      case NotificationType.savingsGoal:
        if (amount != null) {
          return '${l10n.savingsGoals}: "$itemName" - ${l10n.periodicAmount}: ${amount!.toStringAsFixed(0)} VND';
        }
        return '${l10n.savingsGoals}: "$itemName"';

      case NotificationType.savingsGoalDue:
        if (remainingDays != null) {
          return '${l10n.savingsGoals}: "$itemName" - ${l10n.deadline}: $remainingDays ${l10n.daysAgoWith(remainingDays!.abs())}';
        }
        return '${l10n.savingsGoals}: "$itemName" - ${l10n.deadline}';

      case NotificationType.savingsGoalCompleted:
        return '${l10n.completed}: "$itemName" 🎉';
    }
  }
}

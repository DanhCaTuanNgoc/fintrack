import '../../database/database_helper.dart';
import '../../models/more/notification_item.dart';

class NotificationRepository {
  final DatabaseHelper _databaseHelper;

  NotificationRepository(this._databaseHelper);

  Future<List<NotificationItem>> getAllNotifications() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('notifications', orderBy: 'time DESC');
    return maps.map((map) => NotificationItem.fromMap(map)).toList();
  }

  Future<void> addNotification(NotificationItem notification) async {
    final db = await _databaseHelper.database;
    await db.insert('notifications', notification.toMap());
  }

  Future<void> updateNotificationRead(int id, bool isRead) async {
    final db = await _databaseHelper.database;
    await db.update('notifications', {'is_read': isRead ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteNotification(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markAllAsRead(List<NotificationItem> notifications) async {
    for (final n in notifications) {
      if (!n.isRead && n.id != null) {
        await updateNotificationRead(n.id!, true);
      }
    }
  }

  Future<void> markAsRead(NotificationItem notification) async {
    if (!notification.isRead && notification.id != null) {
      await updateNotificationRead(notification.id!, true);
    }
  }

  Future<void> addInvoiceDueNotification({
    required String invoiceName,
    required double amount,
    required DateTime dueDate,
    required String invoiceId,
    required List<NotificationItem> currentNotifications,
  }) async {
    // Check if a similar notification for this invoice and due date already exists and is unread
    NotificationItem? existingNotification;
    for (var item in currentNotifications) {
      if (item.invoiceId == invoiceId &&
          item.invoiceDueDate != null &&
          DateTime(item.invoiceDueDate!.year, item.invoiceDueDate!.month,
                  item.invoiceDueDate!.day) ==
              DateTime(dueDate.year, dueDate.month, dueDate.day) &&
          !item.isRead) {
        existingNotification = item;
        break;
      }
    }
    if (existingNotification != null) {
      return; // Do not add duplicate notification
    }
    final notification = NotificationItem(
      title: 'Hóa đơn đến hạn',
      message:
          'Hóa đơn "$invoiceName" với số tiền \\${amount.toStringAsFixed(0)}đ đã đến hạn thanh toán',
      time: DateTime.now(),
      isRead: false,
      invoiceId: invoiceId,
      invoiceDueDate: dueDate,
    );
    await addNotification(notification);
  }
}

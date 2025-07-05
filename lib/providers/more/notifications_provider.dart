import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/more/notification_item.dart';
import '../../data/repositories/more/notification_repository.dart';
import '../../data/database/database_helper.dart';

// Provider để quản lý trạng thái loading
final notificationsLoadingProvider = StateProvider<bool>((ref) => true);

// Provider để quản lý trạng thái thông báo
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationItem>>((ref) {
  return NotificationsNotifier(ref);
});

class NotificationsNotifier extends StateNotifier<List<NotificationItem>> {
  final Ref ref;

  NotificationsNotifier(this.ref) : super([]) {
    _loadFromDb();
  }

  Future<void> _loadFromDb() async {
    ref.read(notificationsLoadingProvider.notifier).state = true;
    try {
      final data = await NotificationRepository(DatabaseHelper.instance)
          .getAllNotifications();
      state = data;
    } finally {
      ref.read(notificationsLoadingProvider.notifier).state = false;
    }
  }

  // Phương thức để làm mới dữ liệu
  Future<void> refresh() async {
    await _loadFromDb();
  }

  // Phương thức để invalidate và reload
  Future<void> invalidate() async {
    await _loadFromDb();
  }

  Future<void> addInvoiceDueNotification(String invoiceName, double amount,
      DateTime dueDate, String invoiceId) async {
    // Check if a similar notification for this invoice and due date already exists and is unread
    NotificationItem? existingNotification;
    for (var item in state) {
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
      type: NotificationType.periodicInvoice,
      time: DateTime.now(),
      isRead: false,
      invoiceId: invoiceId,
      invoiceDueDate: dueDate,
      itemName: invoiceName,
    );
    await NotificationRepository(DatabaseHelper.instance)
        .addNotification(notification);
    await _loadFromDb();
  }

  Future<void> markAllAsRead() async {
    for (final n in state) {
      if (!n.isRead && n.id != null) {
        await NotificationRepository(DatabaseHelper.instance)
            .updateNotificationRead(n.id!, true);
      }
    }
    await _loadFromDb();
  }

  Future<void> markAsRead(int index) async {
    final n = state[index];
    if (!n.isRead && n.id != null) {
      await NotificationRepository(DatabaseHelper.instance)
          .updateNotificationRead(n.id!, true);
      await _loadFromDb();
    }
  }

  Future<void> deleteNotification(int index) async {
    final n = state[index];
    if (n.id != null) {
      await NotificationRepository(DatabaseHelper.instance)
          .deleteNotification(n.id!);
      await _loadFromDb();
    }
  }

  Future<void> deleteAllReadNotifications() async {
    final readNotifications =
        state.where((n) => n.isRead && n.id != null).toList();
    if (readNotifications.isEmpty) {
      return;
    }
    final repository = NotificationRepository(DatabaseHelper.instance);
    for (final n in readNotifications) {
      await repository.deleteNotification(n.id!);
    }
    await _loadFromDb();
  }
}

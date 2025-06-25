import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/more/notification_item.dart';
import '../../data/repositories/more/notification_repository.dart';

// Provider để quản lý trạng thái thông báo
final notificationsProvider = StateNotifierProvider<NotificationsNotifier,
    AsyncValue<List<NotificationItem>>>((ref) {
  return NotificationsNotifier();
});

// Provider để lấy số thông báo chưa đọc
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.when(
    data: (notificationsList) =>
        notificationsList.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<NotificationItem>>> {
  NotificationsNotifier() : super(const AsyncValue.loading()) {
    _loadFromDb();
  }

  Future<void> _loadFromDb() async {
    try {
      state = const AsyncValue.loading();
      final data = await NotificationRepository().getAllNotifications();
      state = AsyncValue.data(data);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Phương thức để làm mới dữ liệu
  Future<void> refresh() async {
    await _loadFromDb();
  }

  Future<void> addInvoiceDueNotification(String invoiceName, double amount,
      DateTime dueDate, String invoiceId) async {
    // Check if a similar notification for this invoice and due date already exists and is unread
    final currentState = state;
    if (currentState is! AsyncData || currentState.value == null) return;

    NotificationItem? existingNotification;
    for (var item in currentState.value!) {
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
          'Hóa đơn "$invoiceName" với số tiền ${amount.toStringAsFixed(0)}đ đã đến hạn thanh toán',
      time: DateTime.now(),
      isRead: false,
      invoiceId: invoiceId,
      invoiceDueDate: dueDate,
    );
    await NotificationRepository().addNotification(notification);
    await _loadFromDb();
  }

  Future<void> markAllAsRead() async {
    final currentState = state;
    if (currentState is! AsyncData || currentState.value == null) return;

    for (final n in currentState.value!) {
      if (!n.isRead && n.id != null) {
        await NotificationRepository().updateNotificationRead(n.id!, true);
      }
    }
    await _loadFromDb();
  }

  Future<void> markAsRead(int index) async {
    final currentState = state;
    if (currentState is! AsyncData || currentState.value == null) return;

    final notifications = currentState.value!;
    if (index >= 0 && index < notifications.length) {
      final n = notifications[index];
      if (!n.isRead && n.id != null) {
        await NotificationRepository().updateNotificationRead(n.id!, true);
        await _loadFromDb();
      }
    }
  }

  Future<void> deleteNotification(int index) async {
    final currentState = state;
    if (currentState is! AsyncData || currentState.value == null) return;

    final notifications = currentState.value!;
    if (index >= 0 && index < notifications.length) {
      final n = notifications[index];
      if (n.id != null) {
        await NotificationRepository().deleteNotification(n.id!);
        await _loadFromDb();
      }
    }
  }

  Future<void> deleteAllReadNotifications() async {
    final currentState = state;
    if (currentState is! AsyncData || currentState.value == null) return;

    final readNotifications =
        currentState.value!.where((n) => n.isRead && n.id != null).toList();
    for (final n in readNotifications) {
      await NotificationRepository().deleteNotification(n.id!);
    }
    await _loadFromDb();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/more/notification_item.dart';

// Provider để quản lý trạng thái thông báo
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationItem>>((ref) {
  return NotificationsNotifier();
});

class NotificationsNotifier extends StateNotifier<List<NotificationItem>> {
  NotificationsNotifier() : super([]) {
    _loadFromDb();
  }

  Future<void> _loadFromDb() async {
    final data = await DatabaseHelper.instance.getAllNotifications();
    state = data.map((e) => NotificationItem.fromMap(e)).toList();
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
      title: 'Hóa đơn đến hạn',
      message:
          'Hóa đơn "$invoiceName" với số tiền ${amount.toStringAsFixed(0)}đ đã đến hạn thanh toán',
      time: DateTime.now(),
      isRead: false,
      invoiceId: invoiceId,
      invoiceDueDate: dueDate,
    );
    await DatabaseHelper.instance.insertNotification(notification.toMap());
    await _loadFromDb();
  }

  Future<void> markAllAsRead() async {
    for (final n in state) {
      if (!n.isRead && n.id != null) {
        await DatabaseHelper.instance.updateNotificationRead(n.id!, true);
      }
    }
    await _loadFromDb();
  }

  Future<void> markAsRead(int index) async {
    final n = state[index];
    if (!n.isRead && n.id != null) {
      await DatabaseHelper.instance.updateNotificationRead(n.id!, true);
      await _loadFromDb();
    }
  }

  Future<void> deleteNotification(int index) async {
    final n = state[index];
    if (n.id != null) {
      await DatabaseHelper.instance.deleteNotification(n.id!);
      await _loadFromDb();
    }
  }
}

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);
    final loading = notifications.isEmpty;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Thông báo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF2D3142),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Color(0xFF2D3142)),
            onPressed: () => notifier.markAllAsRead(),
            tooltip: 'Đánh dấu tất cả đã đọc',
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(
                  child: Text(
                    'Không có thông báo nào',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return NotificationTile(
                      notification: notification,
                      onTap: () => notifier.markAsRead(index),
                      onDelete: () => notifier.deleteNotification(index),
                    );
                  },
                ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationTile({
    Key? key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  String _getTimeAgo() {
    final difference = DateTime.now().difference(notification.time);
    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.title + notification.time.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: notification.isRead
                        ? const Color(0xFFF8F9FA)
                        : const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.notifications,
                    color: notification.isRead
                        ? const Color(0xFF9E9E9E)
                        : const Color(0xFF4CAF50),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: notification.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                          color: const Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getTimeAgo(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

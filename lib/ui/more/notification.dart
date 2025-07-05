import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/more/notification_item.dart';
import '../../providers/more/notifications_provider.dart';
import '../../utils/localization.dart';
import '../widget/loadingWidget/notification_skeleton.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    // Tự động refresh khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).invalidate();
    });
    // Tự động refresh mỗi 30 giây
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      ref.read(notificationsProvider.notifier).invalidate();
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);
    final isLoading = ref.watch(notificationsLoadingProvider);
    final notifier = ref.read(notificationsProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.notifications,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            color: const Color(0xFF2D3142),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh,
                color: const Color(0xFF2D3142), size: 24.sp),
            onPressed: () {
              notifier.invalidate();
            },
            tooltip: l10n.refresh,
          ),
          IconButton(
            icon: Icon(Icons.done_all,
                color: const Color(0xFF2D3142), size: 24.sp),
            onPressed: () => notifier.markAllAsRead(),
            tooltip: l10n.markAllAsRead,
          ),
          IconButton(
            icon: Icon(Icons.delete_sweep,
                color: const Color(0xFFE57373), size: 24.sp),
            onPressed: () => notifier.deleteAllReadNotifications(),
            tooltip: l10n.deleteAllRead,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          notifier.invalidate();
        },
        child: isLoading
            ? const NotificationSkeleton()
            : notifications.isEmpty
                ? Center(
                    child: Text(
                      l10n.noNotifications,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: const Color(0xFF2D3142),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16.w),
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

  String _getTimeAgo(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final difference = DateTime.now().difference(notification.time);
    if (difference.inDays > 0) {
      return l10n.daysAgoWith(difference.inDays);
    } else if (difference.inHours > 0) {
      return l10n.hoursAgoWith(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return l10n.minutesAgoWith(difference.inMinutes);
    } else {
      return l10n.justNow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dismissible(
      key: Key(
          '${notification.type}_${notification.time.millisecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        color: Colors.red,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 28.sp,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: EdgeInsets.only(bottom: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: 0,
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: notification.isRead
                        ? const Color(0xFFF8F9FA)
                        : const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.notifications,
                    color: notification.isRead
                        ? const Color(0xFF9E9E9E)
                        : const Color(0xFF4CAF50),
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.getTitle(l10n),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: notification.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                          color: const Color(0xFF2D3142),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        notification.getMessage(l10n),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _getTimeAgo(context),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF9E9E9E),
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

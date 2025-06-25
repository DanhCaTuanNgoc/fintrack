import 'package:workmanager/workmanager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/more/periodic_invoice_provider.dart';
import '../data/models/more/periodic_invoice.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../data/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

// Khởi tạo plugin thông báo
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Hàm xử lý chính cho các tác vụ chạy ngầm
// Được gọi bởi Workmanager khi có task cần thực thi
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'checkPeriodicInvoices':
        try {
          // Khởi tạo thông báo với cấu hình đầy đủ
          const AndroidInitializationSettings initializationSettingsAndroid =
              AndroidInitializationSettings('@mipmap/ic_launcher');

          const InitializationSettings initializationSettings =
              InitializationSettings(android: initializationSettingsAndroid);

          // Khởi tạo và kiểm tra
          final initialized = await flutterLocalNotificationsPlugin
              .initialize(initializationSettings);

          if (initialized == null || !initialized) {
            return false;
          }

          // Lấy danh sách hóa đơn định kỳ trực tiếp từ database
          final dbHelper = DatabaseHelper.instance;
          final data = await dbHelper.getAllPeriodicInvoices();
          final invoices = data.map((e) => PeriodicInvoice.fromMap(e)).toList();

          // Tạo notification channel với cấu hình đầy đủ
          const AndroidNotificationChannel channel = AndroidNotificationChannel(
            'periodic_invoices',
            'Hóa đơn định kỳ',
            description: 'Thông báo về hóa đơn định kỳ',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            enableLights: true,
          );

          // Tạo channel
          await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.createNotificationChannel(channel);

          // Cấu hình notification details với cấu hình mạnh mẽ hơn
          final AndroidNotificationDetails androidPlatformChannelSpecifics =
              AndroidNotificationDetails(
            'periodic_invoices',
            'Hóa đơn định kỳ',
            channelDescription: 'Thông báo về hóa đơn định kỳ',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
            enableLights: true,
            icon: '@mipmap/ic_launcher',
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            color: Color(0xFF6C63FF),
            category: AndroidNotificationCategory.reminder,
            visibility: NotificationVisibility.public,
            autoCancel: true,
            ongoing: false,
            silent: false,
            // Thêm cấu hình để đảm bảo hiển thị
            fullScreenIntent: true,
            timeoutAfter: 30000, // 30 giây
            showProgress: false,
            indeterminate: false,
            onlyAlertOnce: false,
            vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
            ledColor: Color(0xFF6C63FF),
            ledOnMs: 1000,
            ledOffMs: 500,
          );
          final NotificationDetails platformChannelSpecifics =
              NotificationDetails(android: androidPlatformChannelSpecifics);
          for (final invoice in invoices) {
            final nextDue =
                invoice.nextDueDate ?? invoice.calculateNextDueDate();
            final now = DateTime.now();

            // Hóa đơn chưa thanh toán
            if (!invoice.isPaid) {
              // Sắp đến hạn (trước 2 ngày)
              final diff = nextDue
                  .difference(DateTime(now.year, now.month, now.day))
                  .inDays;
              if (diff > 0 && diff <= 2) {
                final notificationId =
                    DateTime.now().millisecondsSinceEpoch % 100000;

                await flutterLocalNotificationsPlugin.show(
                  notificationId,
                  'Hóa đơn sắp đến hạn',
                  'Hóa đơn ${invoice.name} sẽ đến hạn vào ${nextDue.day}/${nextDue.month}/${nextDue.year}',
                  platformChannelSpecifics,
                );

                // Lưu thông báo vào database
                await DatabaseHelper.instance.insertNotification({
                  'title': 'Hóa đơn sắp đến hạn',
                  'message':
                      'Hóa đơn ${invoice.name} sẽ đến hạn vào ${nextDue.day}/${nextDue.month}/${nextDue.year}',
                  'time': DateTime.now().toIso8601String(),
                  'is_read': 0,
                  'invoice_id': invoice.id,
                  'invoice_due_date': nextDue.toIso8601String(),
                });
              }
              // Đã quá hạn
              else if (now.isAfter(nextDue) ||
                  (now.year == nextDue.year &&
                      now.month == nextDue.month &&
                      now.day == nextDue.day)) {
                final notificationId =
                    DateTime.now().millisecondsSinceEpoch % 100000 + 1;

                await flutterLocalNotificationsPlugin.show(
                  notificationId,
                  'Hóa đơn quá hạn',
                  'Hóa đơn ${invoice.name} đã quá hạn thanh toán',
                  platformChannelSpecifics,
                );

                // Lưu thông báo vào database
                await DatabaseHelper.instance.insertNotification({
                  'title': 'Hóa đơn quá hạn',
                  'message': 'Hóa đơn ${invoice.name} đã quá hạn thanh toán',
                  'time': DateTime.now().toIso8601String(),
                  'is_read': 0,
                  'invoice_id': invoice.id,
                  'invoice_due_date': nextDue.toIso8601String(),
                });

                // Cập nhật trạng thái hóa đơn thành quá hạn
                await DatabaseHelper.instance.updateInvoicePaidStatus(
                  invoice.id,
                  false, // isPaid = false (chưa thanh toán)
                  nextDueDate: nextDue, // cập nhật ngày đến hạn
                );
              }
            }
            // Hóa đơn đã thanh toán
            else {
              // Nếu đã đến hạn mới
              if (now.isAfter(nextDue) ||
                  (now.year == nextDue.year &&
                      now.month == nextDue.month &&
                      now.day == nextDue.day)) {
                final notificationId =
                    DateTime.now().millisecondsSinceEpoch % 100000 + 2;

                await flutterLocalNotificationsPlugin.show(
                  notificationId,
                  'Đến hạn thanh toán mới',
                  'Hóa đơn ${invoice.name} đã đến hạn thanh toán mới',
                  platformChannelSpecifics,
                );

                // Lưu thông báo vào database
                await DatabaseHelper.instance.insertNotification({
                  'title': 'Đến hạn thanh toán mới',
                  'message':
                      'Hóa đơn ${invoice.name} đã đến hạn thanh toán mới',
                  'time': DateTime.now().toIso8601String(),
                  'is_read': 0,
                  'invoice_id': invoice.id,
                  'invoice_due_date': nextDue.toIso8601String(),
                });

                // Cập nhật trạng thái hóa đơn thành chưa thanh toán khi đến hạn mới
                await DatabaseHelper.instance.updateInvoicePaidStatus(
                  invoice.id,
                  false, // isPaid = false (chưa thanh toán)
                  nextDueDate: nextDue, // giữ nguyên ngày đến hạn
                );
              }
            }
          }

          return true; // Task thực hiện thành công
        } catch (e) {
          return false;
        }
      default:
        return false; // Không xử lý task không xác định
    }
  });
}

// Lớp quản lý các tác vụ chạy ngầm
class BackgroundService {
  // Khởi tạo Workmanager và đăng ký hàm callback
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  // Đăng ký task kiểm tra hóa đơn định kỳ
  static Future<void> registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      'checkPeriodicInvoices', // Tên  task
      'checkPeriodicInvoices', // Tên task (phảigiống nhau)
      frequency: const Duration(minutes: 15), // Tần suất chạy task
      initialDelay: const Duration(seconds: 10),
      constraints: Constraints(
        // Các điều kiện để chạy task
        networkType: NetworkType.not_required, // Không yêu cầu kết nối mạng
      ),
    );
  }
}

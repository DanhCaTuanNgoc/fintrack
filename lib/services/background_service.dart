import 'package:workmanager/workmanager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/more/periodic_invoice_provider.dart';
import '../data/models/more/periodic_invoice.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../data/database/database_helper.dart';

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
          // Khởi tạo thông báo
          const AndroidInitializationSettings initializationSettingsAndroid =
              AndroidInitializationSettings('@mipmap/ic_launcher');
          const InitializationSettings initializationSettings =
              InitializationSettings(android: initializationSettingsAndroid);
          await flutterLocalNotificationsPlugin
              .initialize(initializationSettings);

          // Tạo một container mới để sử dụng các providers
          // Vì task chạy trong một isolate riêng biệt
          final container = ProviderContainer();
          try {
            // Lấy danh sách hóa đơn định kỳ từ provider (FutureProvider)
            final invoices =
                await container.read(periodicInvoicesProvider.future);
            final now = DateTime.now();

            // Duyệt qua từng hóa đơn để kiểm tra
            const AndroidNotificationDetails androidPlatformChannelSpecifics =
                AndroidNotificationDetails(
              'periodic_invoices',
              'Hóa đơn định kỳ',
              channelDescription: 'Thông báo về hóa đơn định kỳ',
              importance: Importance.max,
              priority: Priority.high,
            );
            const NotificationDetails platformChannelSpecifics =
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
                  await flutterLocalNotificationsPlugin.show(
                    0,
                    'Hóa đơn sắp đến hạn',
                    'Hóa đơn ${invoice.name} sẽ đến hạn vào ${nextDue.day}/${nextDue.month}/${nextDue.year}',
                    platformChannelSpecifics,
                  );
                }
                // Đã đến hạn hoặc quá hạn
                else if (now.isAfter(nextDue) ||
                    (now.year == nextDue.year &&
                        now.month == nextDue.month &&
                        now.day == nextDue.day)) {
                  await flutterLocalNotificationsPlugin.show(
                    0,
                    'Hóa đơn quá hạn',
                    'Hóa đơn ${invoice.name} đã đến hạn thanh toán',
                    platformChannelSpecifics,
                  );
                }
              }
              // Hóa đơn đã thanh toán
              else {
                // Nếu đã đến hạn mới, chuyển về chưa thanh toán và gửi thông báo
                if (now.isAfter(nextDue) ||
                    (now.year == nextDue.year &&
                        now.month == nextDue.month &&
                        now.day == nextDue.day)) {
                  await DatabaseHelper.instance
                      .updateInvoicePaidStatus(invoice.id, false);
                  await flutterLocalNotificationsPlugin.show(
                    0,
                    'Đến hạn thanh toán mới',
                    'Hóa đơn ${invoice.name} đã đến hạn thanh toán mới',
                    platformChannelSpecifics,
                  );
                }
              }
            }
            return true; // Task thực hiện thành công
          } catch (e) {
            return false; // Task thực hiện thất bại
          } finally {
            // Luôn giải phóng container để tránh rò rỉ bộ nhớ
            container.dispose();
          }
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
      'checkPeriodicInvoices', // Tên task
      'checkPeriodicInvoices', // Tên task (phải giống nhau)
      frequency: const Duration(seconds: 10), // Tần suất chạy task
      constraints: Constraints(
        // Các điều kiện để chạy task
        networkType: NetworkType.not_required, // Không yêu cầu kết nối mạng
        requiresBatteryNotLow: false, // Không yêu cầu pin cao
        requiresCharging: false, // Không yêu cầu đang sạc
        requiresDeviceIdle: false, // Không yêu cầu thiết bị rảnh
        requiresStorageNotLow: false, // Không yêu cầu bộ nhớ trống nhiều
      ),
    );
  }
}

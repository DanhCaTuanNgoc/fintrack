import 'package:workmanager/workmanager.dart';
import '../data/models/savings_goal.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../data/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../data/repositories/more/notification_repository.dart';
import '../data/models/more/notification_item.dart';
import '../data/repositories/more/periodic_invoice_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/localization.dart';
import '../utils/languages.dart';

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
        return await _checkPeriodicInvoices();
      case 'checkSavingsGoals':
        return await _checkSavingsGoals();
      default:
        return false; // Không xử lý task không xác định
    }
  });
}

// Hàm kiểm tra hóa đơn định kỳ
Future<bool> _checkPeriodicInvoices() async {
  try {
    // Lấy ngôn ngữ hiện tại từ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ??
        SupportedLanguages.defaultLanguage.languageCode;
    final appLanguage = SupportedLanguages.fromLanguageCode(languageCode) ??
        SupportedLanguages.defaultLanguage;
    final l10n = AppLocalizations(appLanguage.locale);

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
    final invoices = await PeriodicInvoiceRepository(DatabaseHelper.instance)
        .getAllPeriodicInvoices();

    // Tạo notification channel với cấu hình đầy đủ
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'periodic_invoices',
      // Sử dụng tên kênh theo ngôn ngữ
      'Hóa đơn định kỳ', // Sẽ không hiển thị cho user, chỉ dùng khi tạo channel lần đầu
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
      l10n.periodicInvoices,
      channelDescription: l10n.periodicInvoices,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      enableLights: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      color: const Color(0xFF6C63FF),
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
      ledColor: const Color(0xFF6C63FF),
      ledOnMs: 1000,
      ledOffMs: 500,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    for (final invoice in invoices) {
      final nextDue = invoice.nextDueDate ?? invoice.calculateNextDueDate();
      final now = DateTime.now();

      // Hóa đơn chưa thanh toán
      if (!invoice.isPaid) {
        // Sắp đến hạn (trước 2 ngày)
        final diff =
            nextDue.difference(DateTime(now.year, now.month, now.day)).inDays;
        if (diff > 0 && diff <= 2) {
          final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;

          await flutterLocalNotificationsPlugin.show(
            notificationId,
            l10n.periodicInvoices, // Title
            '${l10n.invoiceName} "${invoice.name}" ${l10n.overdue}: ${nextDue.day}/${nextDue.month}/${nextDue.year}',
            platformChannelSpecifics,
          );

          // Lưu thông báo vào database
          await NotificationRepository(DatabaseHelper.instance)
              .addNotification(NotificationItem(
            title: l10n.periodicInvoices,
            message:
                '${l10n.invoiceName} "${invoice.name}" ${l10n.overdue}: ${nextDue.day}/${nextDue.month}/${nextDue.year}',
            time: DateTime.now(),
            isRead: false,
            invoiceId: invoice.id,
            invoiceDueDate: nextDue,
          ));
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
            l10n.periodicInvoices,
            '${l10n.invoiceName} "${invoice.name}" ${l10n.overdue}',
            platformChannelSpecifics,
          );

          // Lưu thông báo vào database
          await NotificationRepository(DatabaseHelper.instance)
              .addNotification(NotificationItem(
            title: l10n.periodicInvoices,
            message: '${l10n.invoiceName} "${invoice.name}" ${l10n.overdue}',
            time: DateTime.now(),
            isRead: false,
            invoiceId: invoice.id,
            invoiceDueDate: nextDue,
          ));

          // Cập nhật trạng thái hóa đơn thành quá hạn
          await PeriodicInvoiceRepository(DatabaseHelper.instance)
              .updateInvoicePaidStatus(
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
            l10n.periodicInvoices,
            '${l10n.invoiceName} "${invoice.name}" ${l10n.overdue}',
            platformChannelSpecifics,
          );

          // Lưu thông báo vào database
          await NotificationRepository(DatabaseHelper.instance)
              .addNotification(NotificationItem(
            title: l10n.periodicInvoices,
            message: '${l10n.invoiceName} "${invoice.name}" ${l10n.overdue}',
            time: DateTime.now(),
            isRead: false,
            invoiceId: invoice.id,
            invoiceDueDate: nextDue,
          ));

          // Cập nhật trạng thái hóa đơn thành chưa thanh toán khi đến hạn mới
          await PeriodicInvoiceRepository(DatabaseHelper.instance)
              .updateInvoicePaidStatus(
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
}

// Hàm kiểm tra mục tiêu tiết kiệm
Future<bool> _checkSavingsGoals() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ??
        SupportedLanguages.defaultLanguage.languageCode;
    final appLanguage = SupportedLanguages.fromLanguageCode(languageCode) ??
        SupportedLanguages.defaultLanguage;
    final l10n = AppLocalizations(appLanguage.locale);

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

    // Lấy danh sách mục tiêu tiết kiệm từ database
    final dbHelper = DatabaseHelper.instance;
    final data = await dbHelper.getAllSavingsGoals();
    final goals = data.map((e) => SavingsGoal.fromMap(e)).toList();

    // Tạo notification channel cho savings goals
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'savings_goals',
      'Mục tiêu tiết kiệm',
      description: 'Thông báo về mục tiêu tiết kiệm',
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

    // Cấu hình notification details
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'savings_goals',
      l10n.savingsGoals,
      channelDescription: l10n.savingsGoals,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      enableLights: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      color: const Color(0xFF4CAF50),
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
      autoCancel: true,
      ongoing: false,
      silent: false,
      fullScreenIntent: true,
      timeoutAfter: 30000,
      showProgress: false,
      indeterminate: false,
      onlyAlertOnce: false,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      ledColor: const Color(0xFF4CAF50),
      ledOnMs: 1000,
      ledOffMs: 500,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    for (final goal in goals) {
      // Kiểm tra nếu cần nhắc nhở
      if (goal.needsReminder()) {
        final notificationId =
            DateTime.now().millisecondsSinceEpoch % 100000 + 1000;

        String title = l10n.savingsGoals;
        String message = '${l10n.savingsGoals}: "${goal.name}"';

        // Nếu là mục tiêu định kỳ, thêm thông tin về số tiền cần tiết kiệm
        if (goal.type == 'periodic' && goal.periodicAmount != null) {
          message +=
              ' - ${l10n.periodicAmount}: ${goal.periodicAmount!.toStringAsFixed(0)} VND';
        }

        await flutterLocalNotificationsPlugin.show(
          notificationId,
          title,
          message,
          platformChannelSpecifics,
        );

        // Lưu thông báo vào database
        await NotificationRepository(DatabaseHelper.instance)
            .addNotification(NotificationItem(
          title: title,
          message: message,
          time: DateTime.now(),
          isRead: false,
          goalId: goal.id?.toString(),
        ));

        // Cập nhật ngày nhắc nhở tiếp theo
        final nextReminder = goal.calculateNextReminderDate();
        await dbHelper.updateSavingsGoalNextReminder(goal.id!, nextReminder);
      }

      // Kiểm tra nếu mục tiêu sắp đến hạn
      if (goal.isAlmostDue()) {
        final notificationId =
            DateTime.now().millisecondsSinceEpoch % 100000 + 2000;

        final remainingDays =
            goal.targetDate!.difference(DateTime.now()).inDays;

        await flutterLocalNotificationsPlugin.show(
          notificationId,
          l10n.savingsGoals,
          '${l10n.savingsGoals}: "${goal.name}" - ${l10n.deadline}: $remainingDays ${l10n.daysAgoWith(remainingDays.abs())}',
          platformChannelSpecifics,
        );

        // Lưu thông báo vào database
        await NotificationRepository(DatabaseHelper.instance)
            .addNotification(NotificationItem(
          title: l10n.savingsGoals,
          message:
              '${l10n.savingsGoals}: "${goal.name}" - ${l10n.deadline}: $remainingDays ${l10n.daysAgoWith(remainingDays.abs())}',
          time: DateTime.now(),
          isRead: false,
          goalId: goal.id?.toString(),
        ));
      }

      // Kiểm tra nếu mục tiêu đã hoàn thành
      if (goal.isCompleted) {
        final notificationId =
            DateTime.now().millisecondsSinceEpoch % 100000 + 3000;

        await flutterLocalNotificationsPlugin.show(
          notificationId,
          l10n.savingsGoals,
          '${l10n.completed}: "${goal.name}" 🎉',
          platformChannelSpecifics,
        );

        // Lưu thông báo vào database
        await NotificationRepository(DatabaseHelper.instance)
            .addNotification(NotificationItem(
          title: l10n.savingsGoals,
          message: '${l10n.completed}: "${goal.name}" 🎉',
          time: DateTime.now(),
          isRead: false,
          goalId: goal.id?.toString(),
        ));
      }
    }

    return true; // Task thực hiện thành công
  } catch (e) {
    return false;
  }
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

    // Đăng ký task kiểm tra mục tiêu tiết kiệm
    await Workmanager().registerPeriodicTask(
      'checkSavingsGoals', // Tên task
      'checkSavingsGoals', // Tên task (phải giống nhau)
      frequency: const Duration(days: 1),
      initialDelay: const Duration(minutes: 5),
      constraints: Constraints(
        // Các điều kiện để chạy task
        networkType: NetworkType.not_required, // Không yêu cầu kết nối mạng
      ),
    );
  }
}

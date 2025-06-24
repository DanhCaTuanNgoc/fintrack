import 'package:Fintrack/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:Fintrack/data/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'ui/welcome.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/currency_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

import 'services/background_service.dart';

void main() async {
  // Đảm bảo Flutter binding đã được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo thông báo và yêu cầu quyền
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Tạo notification channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'periodic_invoices',
    'Hóa đơn định kỳ',
    description: 'Thông báo về hóa đơn định kỳ',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    enableLights: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Yêu cầu quyền thông báo trên Android 13+
  if (Platform.isAndroid) {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool? grantedNotificationPermission =
        await androidImplementation?.requestNotificationsPermission();

    if (grantedNotificationPermission == true) {
      print('✅ Quyền thông báo đã được cấp');
    } else {
      print('❌ Quyền thông báo bị từ chối');
    }
  }

  // Khởi tạo background service
  // Bước 1: Khởi tạo Workmanager và đăng ký callback
  await BackgroundService.initialize();
  // Bước 2: Đăng ký task kiểm tra hóa đơn định kỳ
  await BackgroundService.registerPeriodicTask();

  // Cấu hình logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.message}');
  });

  // Khóa orientation chỉ cho portrait mode (dọc)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Tùy chỉnh statusBar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Khởi tạo database
  await DatabaseHelper.instance.database;

  //Lưu vào biến local
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasVisited = prefs.getBool('hasVisited') ?? false;

  // Initialize currency provider
  final currencyNotifier = CurrencyNotifier();

  runApp(
    ProviderScope(
      overrides: [currencyProvider.overrideWith((ref) => currencyNotifier)],
      child: MyApp(hasVisited: hasVisited),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasVisited;
  const MyApp({super.key, required this.hasVisited});
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
          textScaleFactor:
              1.0), // Font chữ của thiết bị không ảnh hưởng đến ứng dụng
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fintrack',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          fontFamily: 'Roboto',
          textTheme: GoogleFonts.robotoTextTheme(),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        ),
        home: hasVisited ? const HomePage() : const WelcomeScreen(),
      ),
    );
  }
}

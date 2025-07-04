import 'package:Fintrack/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:Fintrack/data/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'ui/welcome.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/currency_provider.dart';
import 'providers/more/locale_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'utils/localization.dart';
import 'dart:io';

import 'services/background_service.dart';

void main() async {
  // Đảm bảo Flutter binding đã được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // Yêu cầu quyền thông báo trên Android 13+
  if (Platform.isAndroid) {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
  }

  // Khởi tạo background service
  await BackgroundService.initialize();
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
  await DatabaseHelper.instance.showAllTables();
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

class MyApp extends ConsumerWidget {
  final bool hasVisited;
  const MyApp({super.key, required this.hasVisited});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeObjectProvider);

    return ScreenUtilInit(
      designSize: const Size(410, 840), // Samsung A30 design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0)), // Font chữ của thiết bị không ảnh hưởng đến ứng dụng
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Fintrack',
            locale: currentLocale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
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
      },
    );
  }
}

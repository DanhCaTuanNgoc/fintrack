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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.message}');
  });

  // Khóa orientation chỉ cho portrait mode (dọc)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Khởi tạo database
  await DatabaseHelper.instance.database;
  // Insert database ra terminal
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

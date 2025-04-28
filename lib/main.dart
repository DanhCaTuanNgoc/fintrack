import 'package:fintrack/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:fintrack/data/database/database_helper.dart';
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

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Khởi tạo database
  await DatabaseHelper.instance.database;
  await DatabaseHelper.instance.showAllTables();

  final prefs = await SharedPreferences.getInstance();
  final bool hasVisited = prefs.getBool('hasVisited') ?? false;

  // Đảm bảo CurrencyNotifier được khởi tạo từ đầu
  CurrencyNotifier().setCurrency(CurrencyType.vnd);

  runApp(ProviderScope(child: MyApp(hasVisited: hasVisited)));
}

class MyApp extends StatelessWidget {
  final bool hasVisited;
  const MyApp({super.key, required this.hasVisited});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fintrack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Roboto',
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      home: hasVisited ? const HomePage() : const WelcomeScreen(),
    );
  }
}

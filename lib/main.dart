import 'package:fintrack/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:fintrack/data/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'ui/welcome.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.message}');
  });

  // Khởi tạo database
  await DatabaseHelper.instance.database;
  await DatabaseHelper.instance.showAllTables();

  //Checkin
  final prefs = await SharedPreferences.getInstance();
  final bool hasVisited = await prefs.getBool('hasVisited') ?? false;

  runApp(MyApp(hasVisited: hasVisited));
}

class MyApp extends StatelessWidget {
  final bool hasVisited;
  const MyApp({super.key, required this.hasVisited});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fintrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Roboto',
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      home: hasVisited ? HomePage() : WelcomeScreen(),
    );
  }
}

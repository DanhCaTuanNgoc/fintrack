import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'books.dart';
import 'charts.dart';
import 'more.dart';
import 'extra_features_screen.dart';
import '../providers/theme_provider.dart';
import '../utils/localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    checkFirsTime();
  }

  final List<Widget> _screens = [
    const Books(),
    const Charts(),
    // const Wallet(),
    const ExtraFeaturesScreen(),
    const More(),
  ];

  Future<void> checkFirsTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasVisited = await prefs.getBool('hasVisited') ?? false;

    if (!hasVisited) {
      await prefs.setBool('hasVisited', true);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ref.watch(themeColorProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8.r, // Sử dụng .r cho blurRadius
              offset: Offset(0, -2.h), // Sử dụng .h cho offset
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
              top: 4.h, bottom: 4.h), // Thêm padding top và bottom
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.book_outlined,
                    size: 25.w), // Sử dụng .w cho size
                label: l10n.books,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined, size: 25.w),
                label: l10n.charts,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz_outlined, size: 25.w),
                label: l10n.more,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined, size: 25.w),
                label: l10n.settings,
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
            unselectedItemColor: Colors.grey,
            selectedItemColor: themeColor,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedLabelStyle:
                TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 13.sp),
          ),
        ),
      ),
    );
  }
}

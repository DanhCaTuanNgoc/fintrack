import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'books.dart';
import 'wallet.dart';
import 'charts.dart';
import 'more.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    checkFirsTime();
  }

  final List<Widget> _screens = [
    const Books(),
    const Wallet(),
    const Charts(),
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
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: 'Sổ'),
          BottomNavigationBarItem(icon: Icon(Icons.wallet_outlined), label: 'Ví'),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Phân tích',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz_outlined), label: 'Thêm'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Color(0xFF6C63FF),
      ),
    );
  }
}

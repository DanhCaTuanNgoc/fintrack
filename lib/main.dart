import 'package:flutter/material.dart';
import 'ui/Welcome.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _selectedIndex = 0;

//   final List<Widget> _screens = [
//     const Books(),
//     const Wallet(),
//     const Charts(),
//     const More(),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Books'),
//           BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Wallet'),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.chat_rounded),
//             label: 'Chart',
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'More'),
//         ],
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         type: BottomNavigationBarType.fixed,
//         showUnselectedLabels: true,
//         unselectedItemColor: Colors.grey,
//         selectedItemColor: Colors.deepPurple,
//       ),
//     );
//   }
// }

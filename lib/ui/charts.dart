import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ui/more.dart'; // Import để lấy backgroundColorProvider

class Charts extends ConsumerStatefulWidget {
  const Charts({super.key});

  @override
  ConsumerState<Charts> createState() => _ChartsState();
}

class _ChartsState extends ConsumerState<Charts> {
  @override
  Widget build(BuildContext context) {
    // Lấy màu nền từ provider
    final backgroundColor = ref.watch(backgroundColorProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: const CustomAppBar(),
      body: const Center(child: Text('Chart Content')),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Phân tích',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Color(0xFF2D3142),
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

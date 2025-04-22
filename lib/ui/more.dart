import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/book_provider.dart';

class More extends ConsumerStatefulWidget {
  const More({super.key});

  @override
  _MoreState createState() => _MoreState();
}

class _MoreState extends ConsumerState<More> {
  Future<void> removeData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Logger.root.info('\x1B[32mSuccessfully cleared SharedPreferences\x1B[0m');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Color(0xFF2D3142)),
            onPressed: () async {
              await removeData();
              await ref.read(booksProvider.notifier).deleteAllBooks();
            },
          ),
        ],
      ),
      body: const Center(child: Text('More Content')),
    );
  }
}

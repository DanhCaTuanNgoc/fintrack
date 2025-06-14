import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../books.dart';
import '../../data/models/book.dart';
import '../../providers/book_provider.dart';

class CreateBookModal extends ConsumerStatefulWidget {
  final Color themeColor;

  const CreateBookModal({
    super.key,
    required this.themeColor,
  });

  @override
  ConsumerState<CreateBookModal> createState() => _CreateBookModalState();
}

class _CreateBookModalState extends ConsumerState<CreateBookModal> {
  final _formKey = GlobalKey<FormState>();
  final _bookNameController = TextEditingController();

  @override
  void dispose() {
    _bookNameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateBook() async {
    if (_formKey.currentState!.validate()) {
      try {
        final book = Book(
          name: _bookNameController.text,
          balance: 0.0,
          userId: 1, // TODO: Replace with actual user ID
        );

        await ref.read(booksProvider.notifier).createBook(book.name);

        Navigator.pop(context);
      } catch (e) {
        // TODO: Show snackbar/toast
        print('Error creating book: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Tạo sổ chi tiêu mới',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _bookNameController,
                        decoration: InputDecoration(
                          labelText: 'Tên sổ chi tiêu',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.book),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên sổ chi tiêu';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleCreateBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Tạo sổ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

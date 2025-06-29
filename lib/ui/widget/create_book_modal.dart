import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/book.dart';
import '../../providers/book_provider.dart';
import '../../utils/localization.dart';

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
        // Kiểm tra xem tên sổ đã tồn tại chưa
        final books = ref.read(booksProvider).value ?? [];
        final isNameExists = books.any((book) =>
            book.name.toLowerCase() == _bookNameController.text.toLowerCase());

        if (isNameExists) {
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              title: Text(
                AppLocalizations.of(context).bookNameExists,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                AppLocalizations.of(context).pleaseChooseDifferentName,
                style: TextStyle(fontSize: 16.sp),
              ),
              actions: [
                TextButton(
                  onPressed: () => Future.delayed(Duration.zero, () {
                    Navigator.pop(context);
                  }),
                  child: Text(
                    AppLocalizations.of(context).close,
                    style: TextStyle(
                      color: widget.themeColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
          return;
        }

        final book = Book(
          name: _bookNameController.text,
          balance: 0.0,
          userId: 1,
        );

        await ref.read(booksProvider.notifier).createBook(book.name);

        if (!mounted) return;
        Navigator.pop(context);

        // Hiển thị thông báo cho người dùng
        Future.delayed(
          const Duration(milliseconds: 100),
          () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context).updateSuccess,
                    style: TextStyle(fontSize: 15.sp),
                  ),
                  backgroundColor: const Color(0xFF4CAF50),
                ),
              );
            }
          },
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).updateBookError,
              style: TextStyle(fontSize: 15.sp),
            ),
            backgroundColor: Colors.red,
          ),
        );
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                Text(
                  AppLocalizations.of(context).createBook,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3142),
                  ),
                ),
                SizedBox(height: 20.h),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _bookNameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).newBookName,
                          labelStyle: TextStyle(
                            color: widget.themeColor,
                            fontSize: 14.sp,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: widget.themeColor,
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.book,
                            size: 20.w,
                            color: widget.themeColor,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 14.sp,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)
                                .pleaseEnterBookName;
                          }
                          // if (value.trim().length < 3) {
                          //   return 'Tên sổ phải có ít nhất 3 ký tự';
                          // }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _handleCreateBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeColor,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context).createBook,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

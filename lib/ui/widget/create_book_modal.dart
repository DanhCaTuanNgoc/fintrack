import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/book.dart';
import '../../providers/book_provider.dart';
import '../../utils/localization.dart';
import 'custom_snackbar.dart';

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
  String? _nameExistsError;

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
          setState(() {
            _nameExistsError =
                AppLocalizations.of(context).pleaseChooseDifferentName;
          });
          return;
        }

        // Clear error if name is valid
        setState(() {
          _nameExistsError = null;
        });

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
              CustomSnackBar.showSuccess(
                context,
                message: AppLocalizations.of(context).success,
              );
            }
          },
        );
      } catch (e) {
        if (!mounted) return;
        CustomSnackBar.showError(
          context,
          message: AppLocalizations.of(context).updateBookError,
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
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                              color: Colors.red,
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
                          return null;
                        },
                        onChanged: (value) {
                          // Clear error when user starts typing
                          if (_nameExistsError != null) {
                            setState(() {
                              _nameExistsError = null;
                            });
                          }
                        },
                      ),
                      if (_nameExistsError != null) ...[
                        SizedBox(height: 8.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: Colors.red.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade600,
                                size: 16.w,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  _nameExistsError!,
                                  style: TextStyle(
                                    color: Colors.red.shade600,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

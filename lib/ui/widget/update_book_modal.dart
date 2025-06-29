import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/book.dart';
import '../../providers/book_provider.dart';
import '../../utils/localization.dart';
import './custom_snackbar.dart';

class UpdateBookModal extends ConsumerStatefulWidget {
  final Color themeColor;
  final Book book;

  const UpdateBookModal({
    super.key,
    required this.themeColor,
    required this.book,
  });

  @override
  ConsumerState<UpdateBookModal> createState() => _UpdateBookModalState();
}

class _UpdateBookModalState extends ConsumerState<UpdateBookModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _bookNameController;

  @override
  void initState() {
    super.initState();
    _bookNameController = TextEditingController(text: widget.book.name);
  }

  @override
  void dispose() {
    _bookNameController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateBook() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Kiểm tra xem tên sổ đã tồn tại chưa (trừ book hiện tại)
        final books = ref.read(booksProvider).value ?? [];
        final isNameExists = books.any((book) =>
            book.id != widget.book.id &&
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
                  onPressed: () => Navigator.pop(context),
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

        // Kiểm tra xem tên có thay đổi không
        if (_bookNameController.text.trim() == widget.book.name) {
          Navigator.pop(context);
          return;
        }

        // Cập nhật tên book
        await ref.read(booksProvider.notifier).updateBook(
              widget.book,
              _bookNameController.text.trim(),
            );

        if (!mounted) return;
        Navigator.pop(context);

        // Hiển thị thông báo cho người dùng
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            CustomSnackBar.showSuccess(
              context,
              message: AppLocalizations.of(context).updateSuccess,
            );
          }
        });
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
    final l10n = AppLocalizations.of(context);

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
                  l10n.editBookName,
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
                          labelText: l10n.newBookName,
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
                            Icons.edit,
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
                            return l10n.pleaseEnterBookName;
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
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _handleUpdateBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeColor,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      l10n.saveChanges,
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

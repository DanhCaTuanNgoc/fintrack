import 'package:Fintrack/ui/widget/book/update_book_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/models/models_barrel.dart';
import '../../../providers/book_provider.dart';
import '../../../utils/localization.dart';
import 'create_book_modal.dart';
import '../../../providers/providers_barrel.dart';
import '../components/delete_confirmation_dialog.dart';
import '../components/custom_snackbar.dart';

class BookListScreen extends ConsumerWidget {
  final Color themeColor;

  const BookListScreen({
    super.key,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final booksState = ref.watch(booksProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        title: Text(
          l10n.expenseBookList,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () =>
                Future.delayed(Duration.zero, () => {Navigator.pop(context)})),
      ),
      body: booksState.when(
        data: (books) {
          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 64.sp,
                          color: themeColor,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          l10n.noBook,
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _showCreateBookModal(context, themeColor);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          padding: EdgeInsets.symmetric(vertical: 16.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          l10n.createBook,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    final currentBookState = ref.read(currentBookProvider);
                    final isCurrentBook = currentBookState.when(
                      data: (currentBook) => currentBook?.id == book.id,
                      loading: () => false,
                      error: (_, __) => false,
                    );

                    return Container(
                      margin: EdgeInsets.only(bottom: 12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.w,
                        ),
                        leading: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.book,
                            color: themeColor,
                            size: 24.w,
                          ),
                        ),
                        title: Text(
                          book.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isCurrentBook)
                              Icon(
                                Icons.check_circle,
                                color: themeColor,
                                size: 24.w,
                              ),
                            SizedBox(width: 8.w),
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: themeColor,
                                size: 20.w,
                              ),
                              onPressed: () =>
                                  _showEditBookDialog(context, book, ref),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 20.w,
                              ),
                              onPressed: () =>
                                  _showDeleteBookDialog(context, book, ref),
                            ),
                          ],
                        ),
                        onTap: () {
                          ref
                              .read(currentBookProvider.notifier)
                              .setCurrentBook(book);
                          Future.delayed(
                              Duration.zero, () => {Navigator.pop(context)});
                        },
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showCreateBookModal(context, themeColor);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      padding: EdgeInsets.symmetric(vertical: 16.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.createBook,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64.w, color: Colors.red),
              SizedBox(height: 16.h),
              Text(
                'Có lỗi xảy ra: $error',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => ref.refresh(booksProvider),
                child: Text(l10n.tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateBookModal(BuildContext context, Color themeColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateBookModal(themeColor: themeColor),
    );
  }

  void _showEditBookDialog(BuildContext context, Book book, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UpdateBookModal(
        themeColor: themeColor,
        book: book,
      ),
    );
  }

  void _showDeleteBookDialog(BuildContext context, Book book, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    DeleteConfirmationDialog.show(
      context: context,
      title: l10n.confirmDelete,
      message: l10n.confirmDeleteMessage.replaceFirst('{goalName}', book.name),
      onConfirm: () async {
        await ref.read(booksProvider.notifier).deleteBook(book);
        if (context.mounted) {
          CustomSnackBar.showSuccess(
            context,
            message: l10n.success,
          );
        }
      },
      icon: Icons.warning_rounded,
      iconColor: Colors.red.shade600,
      iconBackgroundColor: Colors.red.shade50,
    );
  }
}

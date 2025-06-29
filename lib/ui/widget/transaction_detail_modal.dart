import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/models_barrel.dart';
import '../../providers/providers_barrel.dart';
import '../../utils/category_helper.dart';
import '../../utils/localization.dart';
import './custom_snackbar.dart';

class TransactionDetailModal extends ConsumerWidget {
  final Transaction transaction;
  final Color themeColor;
  final List<Map<String, dynamic>> categories;
  final VoidCallback onEdit;

  const TransactionDetailModal({
    super.key,
    required this.transaction,
    required this.themeColor,
    required this.categories,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = categories.firstWhere(
      (cat) => cat['id'] == transaction.categoryId,
      orElse: () => {'icon': '🏷️', 'name': 'Không xác định'},
    );
    final l10n = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Padding(
        padding: EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 12.h, bottom: 20.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  // Loại giao dịch + số tiền
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: transaction.type == 'expense'
                              ? Colors.red.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          transaction.type == 'expense'
                              ? l10n.expense
                              : l10n.income,
                          style: TextStyle(
                            color: transaction.type == 'expense'
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.w500,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                      Text(
                        '${transaction.type == 'expense' ? '-' : '+'}${formatCurrency(transaction.amount, ref.watch(currencyProvider))}',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: transaction.type == 'expense'
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Danh mục
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          category['icon'],
                          style: TextStyle(fontSize: 18.sp),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        category['name'],
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Ghi chú
                  if (transaction.note.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.note,
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        transaction.note,
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ],
                  SizedBox(height: 24.h),

                  // Ngày giao dịch
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 20.w, color: Colors.grey[600]),
                      SizedBox(width: 8.w),
                      Text(
                        DateFormat('dd/MM/yyyy').format(transaction.date!),
                        style:
                            TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),

                  // Nút thao tác
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final notifier =
                                ref.read(transactionsProvider.notifier);
                            await notifier.deleteTransaction(transaction.id!);
                            CustomSnackBar.showSuccess(
                              context,
                              message: l10n.success,
                            );
                            Future.delayed(Duration.zero, () {
                              Navigator.pop(context);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n.delete,
                            style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onEdit();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n.edit,
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

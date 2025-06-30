import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/models_barrel.dart';
import '../../providers/providers_barrel.dart';
import '../../utils/localization.dart';
import './custom_snackbar.dart';
import '../../utils/get_emoji.dart';

class InvoiceDetailModal extends ConsumerWidget {
  final PeriodicInvoice invoice;
  final Color themeColor;
  final String bookName;
  final VoidCallback onDelete;
  final VoidCallback onPay;

  const InvoiceDetailModal({
    super.key,
    required this.invoice,
    required this.themeColor,
    required this.bookName,
    required this.onDelete,
    required this.onPay,
  });

  String _getFrequencyText(String frequency, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (frequency) {
      case 'daily':
        return l10n.daily;
      case 'weekly':
        return l10n.weekly;
      case 'monthly':
        return l10n.monthly;
      case 'yearly':
        return l10n.yearly;
      default:
        return frequency;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isOverdue = invoice.isOverdue();
    final nextDueDate = invoice.nextDueDate ?? invoice.calculateNextDueDate();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                getIconFromEmoji(invoice.category),
                size: 36.w,
                color: themeColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              invoice.name,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isOverdue
                    ? Colors.red.withOpacity(0.1)
                    : invoice.isPaid
                        ? Colors.green.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                isOverdue
                    ? l10n.overdue
                    : invoice.isPaid
                        ? l10n.paid
                        : l10n.pendingPayment,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: isOverdue
                      ? Colors.red
                      : invoice.isPaid
                          ? Colors.green
                          : Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              formatCurrency(invoice.amount, ref.watch(currencyProvider)),
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: isOverdue
                    ? Colors.red
                    : invoice.isPaid
                        ? Colors.green
                        : themeColor,
              ),
            ),
            SizedBox(height: 18.h),
            _buildDetailRow(Icons.calendar_today, l10n.frequency,
                _getFrequencyText(invoice.frequency, context)),
            SizedBox(height: 10.h),
            _buildDetailRow(Icons.book, l10n.expenseBook, bookName),
            if (nextDueDate != null) ...[
              SizedBox(height: 10.h),
              _buildDetailRow(Icons.schedule, l10n.nextDueDate,
                  DateFormat('dd/MM/yyyy').format(nextDueDate)),
            ],
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () {
                        onDelete();
                        Navigator.pop(context);
                        CustomSnackBar.showSuccess(
                          context,
                          message: l10n.success,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[500],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_outline,
                              color: Colors.white, size: 20.w),
                          SizedBox(width: 6.w),
                          Text(
                            l10n.delete,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: invoice.isPaid
                          ? null
                          : () {
                              onPay();
                              Future.delayed(
                                  Duration.zero, () => Navigator.pop(context));
                              CustomSnackBar.showSuccess(
                                context,
                                message: l10n.success,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        l10n.pay,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.w, color: Colors.grey.shade500),
        SizedBox(width: 12.w),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            fontSize: 14.sp,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

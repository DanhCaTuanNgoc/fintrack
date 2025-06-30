import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/localization.dart';
import './custom_snackbar.dart';

class DeleteConfirmationDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String? confirmText,
    String? cancelText,
    IconData? icon,
    Color? iconColor,
    Color? iconBackgroundColor,
  }) async {
    final l10n = AppLocalizations.of(context);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.sp),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(24.sp),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.sp),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon and Title
                if (icon != null) ...[
                  Container(
                    padding: EdgeInsets.all(16.sp),
                    decoration: BoxDecoration(
                      color: iconBackgroundColor ?? Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 32.sp,
                      color: iconColor ?? Colors.red,
                    ),
                  ),
                  SizedBox(height: 16.sp),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.sp),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.sp),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48.sp,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                            ),
                          ),
                          child: Text(
                            cancelText ?? l10n.cancel,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.sp),
                    Expanded(
                      child: Container(
                        height: 48.sp,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onConfirm();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[500],
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                            ),
                          ),
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                          label: Text(
                            confirmText ?? l10n.delete,
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
      },
    );
  }

  // Convenience method for savings goal deletion
  static Future<void> showSavingsGoalDelete({
    required BuildContext context,
    required String goalName,
    required VoidCallback onConfirm,
    bool isOverdue = false,
    bool isClosed = false,
  }) async {
    final l10n = AppLocalizations.of(context);

    String title;
    IconData icon;
    Color iconColor;
    Color iconBackgroundColor;

    if (isOverdue) {
      title = l10n.savingsOverdue;
      icon = Icons.warning_rounded;
      iconColor = Colors.orange;
      iconBackgroundColor = Colors.orange.withOpacity(0.1);
    } else if (isClosed) {
      title = l10n.savingsClosed;
      icon = Icons.delete_forever_rounded;
      iconColor = Colors.red;
      iconBackgroundColor = Colors.red.withOpacity(0.1);
    } else {
      title = l10n.confirmDelete;
      icon = Icons.delete_forever_rounded;
      iconColor = Colors.red;
      iconBackgroundColor = Colors.red.withOpacity(0.1);
    }

    await show(
      context: context,
      title: title,
      message: l10n.confirmDeleteMessage.replaceFirst('{goalName}', goalName),
      onConfirm: onConfirm,
      icon: icon,
      iconColor: iconColor,
      iconBackgroundColor: iconBackgroundColor,
    );
  }
}

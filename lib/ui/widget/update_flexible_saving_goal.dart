import 'package:Fintrack/providers/providers_barrel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../providers/savings_goal_provider.dart';
import '../../../data/models/savings_goal.dart';
import '../../../providers/currency_provider.dart';
import '../../../utils/localization.dart';
import 'add_flexible_saving_goal.dart';
import './custom_snackbar.dart';
import './delete_confirmation_dialog.dart';

class UpdateFlexibleSavingGoalDialog extends ConsumerStatefulWidget {
  final Color themeColor;
  final SavingsGoal goal;

  const UpdateFlexibleSavingGoalDialog({
    super.key,
    required this.themeColor,
    required this.goal,
  });

  @override
  ConsumerState<UpdateFlexibleSavingGoalDialog> createState() =>
      _UpdateFlexibleSavingGoalDialogState();
}

class _UpdateFlexibleSavingGoalDialogState
    extends ConsumerState<UpdateFlexibleSavingGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  DateTime? _targetDate;
  DateTime? _startedDate;

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị từ goal hiện tại
    _nameController.text = widget.goal.name;
    _targetAmountController.text =
        formatCurrency(widget.goal.targetAmount, ref.read(currencyProvider));
    _targetDate = widget.goal.targetDate;
    _startedDate = widget.goal.startedDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyType = ref.watch(currencyProvider);
    final savingsGoalAsync = ref.watch(savingsGoalsProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16.w,
          right: 16.w,
          top: 16.h,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Center(
                child: Text(
                  l10n.editSavingsGoal,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 26.h),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.savingsBookName,
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 14.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: widget.themeColor,
                            width: 2.w,
                          ),
                        ),
                        prefixIcon: Icon(Icons.savings,
                            color: widget.themeColor, size: 24.sp),
                      ),
                      style: TextStyle(fontSize: 16.sp),
                      validator: (value) => value == null || value.isEmpty
                          ? l10n.enterName
                          : null,
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _targetAmountController,
                      decoration: InputDecoration(
                        labelText: l10n.targetAmountLabel,
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 14.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: widget.themeColor,
                            width: 2.w,
                          ),
                        ),
                        prefixIcon: Icon(Icons.attach_money,
                            color: widget.themeColor, size: 24.sp),
                      ),
                      style: TextStyle(fontSize: 16.sp),
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter(currencyType)],
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return l10n.enterAmount;

                        final amount = getNumericValueFromFormattedText(value);
                        if (amount <= 0)
                          return l10n.amountMustBeGreaterThanZero;

                        // Lấy goal hiện tại từ provider để có dữ liệu mới nhất
                        final currentGoal = savingsGoalAsync.when(
                          data: (goals) => goals.firstWhere(
                            (g) => g.id == widget.goal.id,
                            orElse: () => widget.goal,
                          ),
                          loading: () => widget.goal,
                          error: (_, __) => widget.goal,
                        );

                        // Kiểm tra số tiền mục tiêu mới không được nhỏ hơn số tiền hiện tại
                        if (amount < currentGoal.currentAmount) {
                          return l10n.targetAmountCannotBeLessThanSaved
                              .replaceFirst(
                                  '{savedAmount}',
                                  formatCurrency(
                                      currentGoal.currentAmount, currencyType));
                        }

                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _startedDate ?? now,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(now.year + 10),
                              );
                              if (picked != null) {
                                setState(() => _startedDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: l10n.startDateLabel,
                                labelStyle: TextStyle(
                                    color: Colors.black, fontSize: 14.sp),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: widget.themeColor,
                                    width: 2.w,
                                  ),
                                ),
                                prefixIcon: Icon(Icons.calendar_today,
                                    color: widget.themeColor, size: 24.sp),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.h, horizontal: 0.w),
                                child: Text(
                                  _startedDate == null
                                      ? l10n.chooseDateLabel
                                      : '${_startedDate!.day}/${_startedDate!.month}/${_startedDate!.year}',
                                  style: TextStyle(
                                    color: _startedDate == null
                                        ? Colors.grey
                                        : Colors.black,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _targetDate ?? now,
                                firstDate: now,
                                lastDate: DateTime(now.year + 10),
                              );
                              if (picked != null) {
                                setState(() => _targetDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: l10n.targetDate,
                                labelStyle: TextStyle(
                                    color: Colors.black, fontSize: 14.sp),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: widget.themeColor,
                                    width: 2.w,
                                  ),
                                ),
                                prefixIcon: Icon(Icons.flag,
                                    color: widget.themeColor, size: 24.sp),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.h, horizontal: 0.w),
                                child: Text(
                                  _targetDate == null
                                      ? l10n.chooseDateOptional
                                      : '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}',
                                  style: TextStyle(
                                    color: _targetDate == null
                                        ? Colors.grey
                                        : Colors.black,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Hiển thị thông tin hiện tại với dữ liệu real-time
                    savingsGoalAsync.when(
                      data: (goals) {
                        final currentGoal = goals.firstWhere(
                          (g) => g.id == widget.goal.id,
                          orElse: () => widget.goal,
                        );

                        return Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.currentInformation,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.savedAmount,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    formatCurrency(currentGoal.currentAmount,
                                        currencyType),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: widget.themeColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.progressLabel,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '${currentGoal.progressPercentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: widget.themeColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, __) => Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          l10n.dataLoadError,
                          style: TextStyle(color: Colors.red, fontSize: 14.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Expanded(
              //   child: ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.grey[300],
              //       foregroundColor: Colors.black,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //       padding: const EdgeInsets.symmetric(vertical: 16),
              //     ),
              //     onPressed: () {
              //       Navigator.pop(context);
              //     },
              //     child: const Text('Hủy',
              //         style: TextStyle(
              //             fontWeight: FontWeight.bold, fontSize: 18)),
              //   ),
              // ),
              SizedBox(width: 12.w),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      onPressed: () {
                        _showDeleteConfirmation(context);
                      },
                      child: Text(l10n.delete,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.sp)),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.themeColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final name = _nameController.text.trim();
                          final targetAmount = getNumericValueFromFormattedText(
                              _targetAmountController.text.trim());
                          final startedDate = _startedDate;
                          final targetDate = _targetDate;

                          if (startedDate == null) {
                            CustomSnackBar.showError(
                              context,
                              message: l10n.pleaseSelectStartDate,
                            );
                            return;
                          }

                          final notifier =
                              ref.read(savingsGoalsProvider.notifier);

                          // Tạo goal mới với thông tin đã cập nhật
                          final updatedGoal = widget.goal.copyWith(
                            name: name,
                            targetAmount: targetAmount,
                            targetDate: targetDate,
                            startedDate: startedDate,
                          );

                          await notifier.updateSavingsGoal(updatedGoal);

                          if (mounted) {
                            CustomSnackBar.showSuccess(
                              context,
                              message: l10n.updateSuccess,
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: Text(l10n.update,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.sp)),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20.h,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    DeleteConfirmationDialog.showSavingsGoalDelete(
      context: context,
      goalName: widget.goal.name,
      onConfirm: () async {
        final notifier = ref.read(savingsGoalsProvider.notifier);
        await notifier.deleteSavingsGoal(widget.goal);

        if (mounted) {
          CustomSnackBar.showSuccess(
            context,
            message: AppLocalizations.of(context).deleteSuccess,
          );
          // Đóng modal cập nhật và màn hình flexible savings sau khi xóa thành công
          Future.delayed(Duration.zero, () {
            Navigator.pop(context); // Đóng modal cập nhật
            Navigator.pop(context); // Đóng màn hình flexible savings
          });
        }
      },
    );
  }
}

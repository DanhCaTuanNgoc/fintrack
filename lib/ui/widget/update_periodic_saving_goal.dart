import 'package:Fintrack/providers/providers_barrel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../providers/savings_goal_provider.dart';
import '../../../data/models/savings_goal.dart';
import '../../../providers/currency_provider.dart';
import 'add_flexible_saving_goal.dart';
import '../../../utils/localization.dart';

class UpdatePeriodicSavingGoalDialog extends ConsumerStatefulWidget {
  final Color themeColor;
  final SavingsGoal goal;

  const UpdatePeriodicSavingGoalDialog({
    super.key,
    required this.themeColor,
    required this.goal,
  });

  @override
  ConsumerState<UpdatePeriodicSavingGoalDialog> createState() =>
      _UpdatePeriodicSavingGoalDialogState();
}

class _UpdatePeriodicSavingGoalDialogState
    extends ConsumerState<UpdatePeriodicSavingGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _periodicAmountController = TextEditingController();
  String? _periodicFrequency;
  DateTime? _targetDate;
  DateTime? _startedDate;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.goal.name;
    _targetAmountController.text =
        formatCurrency(widget.goal.targetAmount, ref.read(currencyProvider));
    _periodicAmountController.text = formatCurrency(
        widget.goal.periodicAmount ?? 0, ref.read(currencyProvider));
    _periodicFrequency = widget.goal.periodicFrequency;
    _targetDate = widget.goal.targetDate;
    _startedDate = widget.goal.startedDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _periodicAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyType = ref.watch(currencyProvider);
    final savingsGoalAsync = ref.watch(savingsGoalsProvider);
    final l10n = AppLocalizations.of(context);

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
                  l10n.editPeriodicSavingsGoal,
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
                          color: const Color.fromARGB(255, 0, 0, 0),
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
                      validator: (value) => value == null || value.isEmpty
                          ? l10n.enterName
                          : null,
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _targetAmountController,
                      decoration: InputDecoration(
                        labelText: l10n.targetAmount,
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
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter(currencyType)],
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return l10n.enterAmount;
                        final amount = getNumericValueFromFormattedText(value);
                        if (amount <= 0)
                          return l10n.amountMustBeGreaterThanZero;
                        final currentGoal = savingsGoalAsync.when(
                          data: (goals) => goals.firstWhere(
                            (g) => g.id == widget.goal.id,
                            orElse: () => widget.goal,
                          ),
                          loading: () => widget.goal,
                          error: (_, __) => widget.goal,
                        );
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
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _periodicAmountController,
                            decoration: InputDecoration(
                              labelText: l10n.periodicAmount,
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
                              prefixIcon: Icon(Icons.repeat,
                                  color: widget.themeColor, size: 24.sp),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              CurrencyInputFormatter(currencyType)
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return l10n.enterPeriodicAmount;
                              final amount =
                                  getNumericValueFromFormattedText(value);
                              if (amount <= 0)
                                return l10n.periodicAmountMustBeGreaterThanZero;
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (context) => Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 40.w,
                                        height: 4.h,
                                        margin: EdgeInsets.only(
                                            top: 12.h, bottom: 20.h),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(2.r),
                                        ),
                                      ),
                                      Text(
                                        l10n.chooseFrequency,
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF2D3142),
                                        ),
                                      ),
                                      SizedBox(height: 20.h),
                                      ...['daily', 'weekly', 'monthly']
                                          .map((frequency) {
                                        final labels = {
                                          'daily': l10n.frequencyDaily,
                                          'weekly': l10n.frequencyWeekly,
                                          'monthly': l10n.frequencyMonthly,
                                        };
                                        final icons = {
                                          'daily': Icons.today,
                                          'weekly': Icons.view_week,
                                          'monthly': Icons.calendar_month,
                                        };

                                        return ListTile(
                                          leading: Container(
                                            padding: EdgeInsets.all(8.w),
                                            decoration: BoxDecoration(
                                              color: _periodicFrequency ==
                                                      frequency
                                                  ? widget.themeColor
                                                      .withOpacity(0.1)
                                                  : Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            child: Icon(
                                              icons[frequency],
                                              color: _periodicFrequency ==
                                                      frequency
                                                  ? widget.themeColor
                                                  : Colors.grey[600],
                                              size: 20.sp,
                                            ),
                                          ),
                                          title: Text(
                                            labels[frequency]!,
                                            style: TextStyle(
                                              fontWeight: _periodicFrequency ==
                                                      frequency
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: _periodicFrequency ==
                                                      frequency
                                                  ? widget.themeColor
                                                  : const Color(0xFF2D3142),
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                          trailing:
                                              _periodicFrequency == frequency
                                                  ? Icon(
                                                      Icons.check_circle,
                                                      color: widget.themeColor,
                                                      size: 20.sp,
                                                    )
                                                  : null,
                                          onTap: () {
                                            setState(() {
                                              _periodicFrequency = frequency;
                                            });
                                            Navigator.pop(context);
                                          },
                                        );
                                      }).toList(),
                                      SizedBox(height: 20.h),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: l10n.frequency,
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
                                prefixIcon: Icon(Icons.schedule,
                                    color: widget.themeColor, size: 24.sp),
                                suffixIcon: Icon(Icons.keyboard_arrow_down,
                                    size: 20.sp),
                              ),
                              child: Text(
                                _periodicFrequency == null
                                    ? l10n.frequency
                                    : {
                                        'daily': l10n.frequencyDaily,
                                        'weekly': l10n.frequencyWeekly,
                                        'monthly': l10n.frequencyMonthly,
                                      }[_periodicFrequency]!,
                                style: TextStyle(
                                  color: _periodicFrequency == null
                                      ? Colors.grey
                                      : Colors.black,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                      child: Text(l10n.deleteSavingsBook,
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
                          final periodicAmount =
                              getNumericValueFromFormattedText(
                                  _periodicAmountController.text.trim());
                          final periodicFrequency = _periodicFrequency;
                          final startedDate = _startedDate;
                          final targetDate = _targetDate;

                          if (startedDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(l10n.pleaseSelectStartDate)),
                            );
                            return;
                          }
                          if (periodicFrequency == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(l10n.pleaseSelectFrequency)),
                            );
                            return;
                          }

                          final notifier =
                              ref.read(savingsGoalsProvider.notifier);

                          final updatedGoal = widget.goal.copyWith(
                            name: name,
                            targetAmount: targetAmount,
                            periodicAmount: periodicAmount,
                            periodicFrequency: periodicFrequency,
                            startedDate: startedDate,
                            targetDate: targetDate,
                          );

                          await notifier.updateSavingsGoal(updatedGoal);

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.updateSuccess,
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Future.delayed(Duration.zero, () {
                              Navigator.pop(context);
                            });
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
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.confirmDelete, style: TextStyle(fontSize: 18.sp)),
          content: Text(
            l10n.confirmDeleteMessage
                .replaceFirst('{goalName}', widget.goal.name),
            style: TextStyle(fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel, style: TextStyle(fontSize: 14.sp)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(context).pop();

                final notifier = ref.read(savingsGoalsProvider.notifier);
                await notifier.deleteSavingsGoal(widget.goal);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.deleteSuccess,
                          style: TextStyle(fontSize: 14.sp)),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Future.delayed(Duration.zero, () {
                    Navigator.pop(context);
                  });
                }
              },
              child: Text(l10n.delete, style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        );
      },
    );
  }
}

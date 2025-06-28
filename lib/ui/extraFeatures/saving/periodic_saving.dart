import 'package:Fintrack/providers/providers_barrel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widget/widget_barrel.dart';
import 'deposit_savings_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/localization.dart';

class PeriodicSavingScreen extends ConsumerWidget {
  const PeriodicSavingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color themeColor = ref.watch(themeColorProvider);
    final savingsGoal = ref.watch(savingsGoalsProvider);
    final currencyType = ref.watch(currencyProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).periodicSavings,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30.r),
            onTap: () => Future.delayed(Duration.zero, () {
              Navigator.pop(context);
            }),
            child: Icon(Icons.arrow_back, color: Colors.white, size: 24.w),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 16.h),
              child: savingsGoal.when(
                data: (goals) {
                  final periodicGoals =
                      goals.where((g) => g.type == 'periodic').toList();
                  if (periodicGoals.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.savings,
                            size: 60.w,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            AppLocalizations.of(context).noPeriodicSavings,
                            style:
                                TextStyle(fontSize: 16.sp, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  // Hiển thị danh sách các mục tiêu tiết kiệm linh hoạt
                  return ListView.builder(
                    itemCount: periodicGoals.length,
                    itemBuilder: (context, index) {
                      final goal = periodicGoals[index];
                      return SavingCard(
                        goal: goal,
                        currencyType: currencyType,
                        themeColor: themeColor,
                        onTap: () {
                          bool isOverdue = goal.targetDate != null &&
                              goal.targetDate!.isBefore(DateTime.now()) &&
                              !goal.isCompleted;
                          bool isClosed = !goal.isActive;

                          if (isOverdue || isClosed) {
                            String message = isOverdue
                                ? AppLocalizations.of(context).savingsOverdue
                                : AppLocalizations.of(context).savingsClosed;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                backgroundColor:
                                    isOverdue ? Colors.red : Colors.grey,
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DepositSavingsScreen(
                                  goal: goal,
                                  themeColor: themeColor,
                                  type: 'periodic',
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Text('${AppLocalizations.of(context).error}: $err',
                      style: TextStyle(fontSize: 14.sp)),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1.r,
                  blurRadius: 4.r,
                  offset: Offset(0, -2.h),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showAddSavingGoalModal(context, themeColor);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.of(context).createNewSavings,
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
      // floatingActionButton: Padding(
      //   padding: EdgeInsets.only(bottom: 24.h),
      //   child: FloatingActionButton(
      //     onPressed: () {
      //       _showAddSavingGoalModal(context, themeColor);
      //     },
      //     backgroundColor: themeColor,
      //     elevation: 4,
      //     child: Icon(Icons.add, size: 30.w, color: Colors.white),
      //   ),
      // ),
    );
  }
}

class _AddAmountDialog extends StatefulWidget {
  @override
  State<_AddAmountDialog> createState() => _AddAmountDialogState();
}

class _AddAmountDialogState extends State<_AddAmountDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).enterAmountToDeposit,
          style: TextStyle(fontSize: 18.sp)),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).amountHint,
          hintStyle: TextStyle(fontSize: 14.sp),
        ),
        style: TextStyle(fontSize: 16.sp),
      ),
      actions: [
        TextButton(
          onPressed: () => Future.delayed(Duration.zero, () {
            Navigator.pop(context);
          }),
          child: Text(AppLocalizations.of(context).cancel,
              style: TextStyle(fontSize: 14.sp)),
        ),
        ElevatedButton(
          onPressed: () {
            final value = double.tryParse(_controller.text);
            Future.delayed(Duration.zero, () {
              Navigator.pop(context);
            });
          },
          child: Text(AppLocalizations.of(context).confirm,
              style: TextStyle(fontSize: 14.sp)),
        ),
      ],
    );
  }
}

void _showAddSavingGoalModal(BuildContext context, Color themeColor) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (context) {
      return AddPeriodicSavingGoalDialog(
        themeColor: themeColor,
      );
    },
  );
}

String progressText(
  CurrencyType currency,
  double currentAmount,
  double targetAmount,
) {
  return '${formatCurrency(currentAmount, currency)} / ${formatCurrency(targetAmount, currency)}';
}

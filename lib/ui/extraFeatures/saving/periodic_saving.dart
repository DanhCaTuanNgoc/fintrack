import 'package:Fintrack/providers/providers_barrel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widget/widget_barrel.dart';
import 'deposit_savings_screen.dart';

class PeriodicSavingScreen extends ConsumerWidget {
  const PeriodicSavingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final provider = ref.watch(savingsGoalsProvider.notifier);
    final Color themeColor = ref.watch(themeColorProvider);
    final savingsGoal = ref.watch(savingsGoalsProvider);
    final currencyType = ref.watch(currencyProvider);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: themeColor,
          elevation: 0,
          title: const Text(
            'Tiết kiệm định kỳ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => Future.delayed(Duration.zero, () {
                Navigator.pop(context);
              }),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
              child: savingsGoal.when(
                data: (goals) {
                  final periodicGoals =
                      goals.where((g) => g.type == 'periodic').toList();
                  if (periodicGoals.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.savings, // Hoặc Icons.account_balance_wallet
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Không có sổ tiết kiệm định kỳ nào',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
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
                                  ? 'Sổ tiết kiệm này đã quá hạn.'
                                  : 'Sổ tiết kiệm này đã được đóng.';
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
                      });
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Text('Đã xảy ra lỗi: $err'),
                ),
              ),
            )),
            Container(
              padding: const EdgeInsets.all(16),
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
                    _showAddSavingGoalModal(context, themeColor);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Tạo tiết kiệm mới',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
        // floatingActionButton: Padding(
        //   padding: const EdgeInsets.only(bottom: 24),
        //   child: FloatingActionButton(
        //     onPressed: () {
        //       _showAddSavingGoalModal(context, themeColor);
        //     },
        //     backgroundColor: themeColor,
        //     elevation: 4,
        //     child: const Icon(Icons.add, size: 30, color: Colors.white),
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
      title: const Text('Nhập số tiền muốn nộp'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(hintText: 'Số tiền'),
      ),
      actions: [
        TextButton(
          onPressed: () => Future.delayed(Duration.zero, () {
            Navigator.pop(context);
          }),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            final value = double.tryParse(_controller.text);
            Future.delayed(Duration.zero, () {
              Navigator.pop(context);
            });
          },
          child: const Text('Xác nhận'),
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

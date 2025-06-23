import 'package:Fintrack/providers/providers_barrel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/savings_goal_provider.dart';
import '../../../data/models/savings_goal.dart';
import '../../widget/widget_barrel.dart';
import 'deposit_savings_screen.dart';

class FlexibleSavingsScreen extends ConsumerWidget {
  const FlexibleSavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(savingsGoalsProvider.notifier);
    final Color themeColor = ref.watch(themeColorProvider);
    final savingsGoal = ref.watch(savingsGoalsProvider);
    final currencyType = ref.watch(currencyProvider);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: themeColor,
          elevation: 0,
          title: const Text(
            'Tiết kiệm linh hoạt',
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
              onTap: () => Navigator.pop(context),
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
                  if (goals == null || goals.isEmpty) {
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
                            'Không có sổ tiết kiệm nào',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  // Hiển thị danh sách các mục tiêu tiết kiệm linh hoạt
                  return ListView.builder(
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      final goal = goals[index];
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            final value = double.tryParse(_controller.text);
            Navigator.pop(context, value);
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
      return AddFlexibleSavingGoalDialog(
        themeColor: themeColor,
      );
    },
  );
}

class SavingCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback? onTap;
  final CurrencyType currencyType;
  final Color themeColor;

  const SavingCard({
    super.key,
    required this.goal,
    required this.currencyType,
    required this.themeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percent = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    String statusText;
    Color statusColor;

    if (goal.isCompleted) {
      statusText = 'Đã hoàn thành';
      statusColor = const Color.fromARGB(255, 53, 177, 57);
    } else if (goal.targetDate != null &&
        goal.targetDate!.isBefore(DateTime.now())) {
      statusText = 'Đã quá hạn';
      statusColor = Colors.red;
    } else if (!goal.isActive) {
      statusText = 'Đã đóng';
      statusColor = Colors.grey;
    } else {
      statusText = 'Đang tiến hành';
      statusColor = Colors.blueAccent;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(60),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeColor.withOpacity(0.2),
              themeColor.withOpacity(0.15),
              themeColor.withOpacity(0.1),
              themeColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: themeColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: themeColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: themeColor.withOpacity(0.03),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: themeColor.withOpacity(0.02),
                  ),
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                themeColor,
                                themeColor.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: themeColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.savings_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Goal name và label trên cùng một dòng
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      goal.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1A1A1A),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Target amount
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.flag_outlined,
                            size: 20,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mục tiêu',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatCurrency(goal.targetAmount, currencyType),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Progress section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tiến độ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              '${(percent * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: themeColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Custom progress bar
                        Container(
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade200,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Base track
                              Container(
                                width: double.infinity,
                                height: 10,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              // Progress fill - chỉ hiển thị khi có tiến độ thực sự
                              if (percent > 0)
                                FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: percent,
                                  child: Container(
                                    height: 10,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                        colors: [
                                          themeColor,
                                          themeColor.withOpacity(0.8),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: themeColor.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Amount details
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Đã tiết kiệm',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatCurrency(
                                        goal.currentAmount, currencyType),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: themeColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Còn lại',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatCurrency(
                                        goal.remainingAmount, currencyType),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Target date section
                    if (goal.targetDate != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.access_time_rounded,
                                size: 16,
                                color: Colors.orange.shade700,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ngày hoàn thành dự kiến',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${goal.targetDate!.day}/${goal.targetDate!.month}/${goal.targetDate!.year}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String progressText(
  CurrencyType currency,
  double currentAmount,
  double targetAmount,
) {
  return '${formatCurrency(currentAmount, currency)} / ${formatCurrency(targetAmount, currency)}';
}

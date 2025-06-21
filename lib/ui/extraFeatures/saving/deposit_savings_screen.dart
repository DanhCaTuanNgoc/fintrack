import 'package:Fintrack/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/savings_goal.dart';
import '../../../data/models/savings_transaction.dart';
import '../../../providers/savings_goal_provider.dart';
import '../../../providers/savings_transaction_provider.dart';
import '../../../providers/currency_provider.dart';
import '../../widget/number_pad.dart';
import '../../widget/update_flexible_saving_goal.dart';
import 'savings_history_screen.dart';

class DepositSavingsScreen extends ConsumerStatefulWidget {
  final SavingsGoal goal;
  final Color themeColor;

  const DepositSavingsScreen({
    super.key,
    required this.goal,
    required this.themeColor,
  });

  @override
  ConsumerState<DepositSavingsScreen> createState() =>
      _DepositSavingsScreenState();
}

class _DepositSavingsScreenState extends ConsumerState<DepositSavingsScreen> {
  String _amount = '';
  String _note = '';
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyType = ref.watch(currencyProvider);
    final savingsGoalNotifier = ref.watch(savingsGoalsProvider.notifier);
    final savingsTransactionNotifier =
        ref.watch(savingsTransactionsProvider(widget.goal.id!).notifier);
    final themeColor = ref.watch(themeColorProvider);
    final savingsGoalAsync = ref.watch(savingsGoalsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.themeColor,
        elevation: 0,
        title: const Text(
          'Sổ tiết kiệm linh hoạt',
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
        actions: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                _showUpdateModal(context, themeColor, widget.goal);
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.edit, color: Colors.white),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SavingsHistoryScreen(
                      goal: widget.goal,
                      themeColor: widget.themeColor,
                    ),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.history, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: savingsGoalAsync.when(
        data: (goals) {
          // Tìm goal hiện tại với dữ liệu mới nhất
          final currentGoal = goals.firstWhere(
            (g) => g.id == widget.goal.id,
            orElse: () => widget.goal,
          );

          return Column(
            children: [
              // Header với thông tin mục tiêu
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.themeColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.savings,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentGoal.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // const SizedBox(height: 8),
                    // Text(
                    //   'Tiết kiệm linh hoạt',
                    //   style: TextStyle(
                    //     color: Colors.white.withOpacity(0.8),
                    //     fontSize: 16,
                    //   ),
                    // ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoCard(
                          'Mục tiêu',
                          formatCurrency(
                              currentGoal.targetAmount, currencyType),
                          Icons.flag,
                        ),
                        _buildInfoCard(
                          'Đã tiết kiệm',
                          formatCurrency(
                              currentGoal.currentAmount, currencyType),
                          Icons.account_balance_wallet,
                        ),
                        _buildInfoCard(
                          'Còn lại',
                          formatCurrency(
                              currentGoal.remainingAmount, currencyType),
                          Icons.trending_up,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Progress bar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tiến độ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '${currentGoal.progressPercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.themeColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: currentGoal.progressPercentage / 100,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade300,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(widget.themeColor),
                      ),
                    ),
                  ],
                ),
              ),

              // Amount input section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Amount display
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Số tiền nạp',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _amount.isEmpty
                                  ? '0 ${currencyType.symbol}'
                                  : formatCurrency(
                                      double.tryParse(_amount) ?? 0,
                                      currencyType),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: widget.themeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Number pad
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: NumberPad(
                            onNumberTap: (number) {
                              setState(() {
                                _amount += number;
                              });
                            },
                            onBackspaceTap: () {
                              setState(() {
                                if (_amount.isNotEmpty) {
                                  _amount =
                                      _amount.substring(0, _amount.length - 1);
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Note input
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            hintText: 'Ghi chú (tùy chọn)',
                            border: InputBorder.none,
                            icon: Icon(Icons.note, color: widget.themeColor),
                          ),
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Deposit button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _amount.isNotEmpty &&
                                  double.tryParse(_amount) != null
                              ? () async {
                                  final amount = double.parse(_amount);
                                  if (amount > 0) {
                                    try {
                                      // Tạo transaction mới
                                      final transaction = SavingsTransaction(
                                        goalId: currentGoal.id!,
                                        amount: amount,
                                        note: _noteController.text.isNotEmpty
                                            ? _noteController.text
                                            : null,
                                        savedAt: DateTime.now(),
                                      );

                                      // Thêm transaction
                                      await savingsTransactionNotifier
                                          .addTransaction(transaction);

                                      // Cập nhật số tiền hiện tại của goal
                                      await savingsGoalNotifier.addAmountToGoal(
                                          currentGoal.id!, amount);

                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Đã nạp ${formatCurrency(amount, currencyType)} vào sổ tiết kiệm!',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        Navigator.pop(context);
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('Có lỗi xảy ra: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.themeColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Nạp tiền',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Đã xảy ra lỗi: $err'),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

void _showUpdateModal(
    BuildContext context, Color themeColor, SavingsGoal goal) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => UpdateFlexibleSavingGoalDialog(
      themeColor: themeColor,
      goal: goal,
    ),
  );
}

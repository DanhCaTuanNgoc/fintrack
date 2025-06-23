import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/savings_goal.dart';
import '../../../data/models/savings_transaction.dart';
import '../../../providers/savings_transaction_provider.dart';
import '../../../providers/currency_provider.dart';
import '../../../providers/savings_goal_provider.dart';

class SavingsHistoryScreen extends ConsumerWidget {
  final SavingsGoal goal;
  final Color themeColor;

  const SavingsHistoryScreen({
    super.key,
    required this.goal,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyType = ref.watch(currencyProvider);
    final savingsGoalAsync = ref.watch(savingsGoalsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        title: const Text(
          'Lịch sử tiết kiệm',
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
      body: savingsGoalAsync.when(
        data: (goals) {
          // Tìm goal hiện tại với dữ liệu mới nhất
          final currentGoal = goals.firstWhere(
            (g) => g.id == goal.id,
            orElse: () => goal,
          );

          return Column(
            children: [
              // Header với thông tin tổng quan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      currentGoal.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryCard(
                          'Tổng nạp',
                          formatCurrency(
                              currentGoal.currentAmount, currencyType),
                          Icons.account_balance_wallet,
                        ),
                        _buildSummaryCard(
                          'Mục tiêu',
                          formatCurrency(
                              currentGoal.targetAmount, currencyType),
                          Icons.flag,
                        ),
                        _buildSummaryCard(
                          'Tiến độ',
                          '${currentGoal.progressPercentage.toStringAsFixed(1)}%',
                          Icons.trending_up,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Danh sách giao dịch
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final transactions =
                        ref.watch(savingsTransactionsProvider(goal.id!));

                    if (transactions.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.history,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Chưa có giao dịch nào',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return _buildTransactionCard(transaction, currencyType);
                      },
                    );
                  },
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

  Widget _buildSummaryCard(String title, String value, IconData icon) {
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

  Widget _buildTransactionCard(
      SavingsTransaction transaction, CurrencyType currency) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.savings,
                color: themeColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nạp tiền tiết kiệm',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (transaction.note != null && transaction.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        transaction.note!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _formatDate(transaction.savedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '+${formatCurrency(transaction.amount, currency)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

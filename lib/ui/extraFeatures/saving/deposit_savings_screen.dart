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
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
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
          // Material(
          //   color: Colors.transparent,
          //   child: InkWell(
          //     borderRadius: BorderRadius.circular(30),
          //     onTap: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => SavingsHistoryScreen(
          //             goal: widget.goal,
          //             themeColor: widget.themeColor,
          //           ),
          //         ),
          //       );
          //     },
          //     child: const Padding(
          //       padding: EdgeInsets.all(8.0),
          //       child: Icon(Icons.history, color: Colors.white),
          //     ),
          //   ),
          // ),
        ],
      ),
      body: savingsGoalAsync.when(
        data: (goals) {
          // Tìm goal hiện tại với dữ liệu mới nhất
          final currentGoal = goals.firstWhere(
            (g) => g.id == widget.goal.id,
            orElse: () => widget.goal,
          );

          final savingsTransactionsAsync =
              ref.watch(savingsTransactionsProvider(currentGoal.id!));

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
                    Text(
                      currentGoal.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
                    if (currentGoal.targetDate != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_available,
                              size: 16, color: Colors.grey.shade700),
                          const SizedBox(width: 6),
                          Text(
                            'Ngày mục tiêu: ${_formatDate(currentGoal.targetDate!)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Lịch sử nạp tiền
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Lịch sử nạp tiền',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic),
                ),
              ),
              Expanded(
                child: (savingsTransactionsAsync.isEmpty)
                    ? Center(
                        child: Text(
                          'Chưa có lịch sử nạp tiền',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: savingsTransactionsAsync.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final tx = savingsTransactionsAsync[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '+${formatCurrency(tx.amount, currencyType)}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: widget.themeColor,
                                      ),
                                    ),
                                    Text(
                                      _formatDate(tx.savedAt),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                if (tx.note != null && tx.note!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.note,
                                          size: 18, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          tx.note!,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ]
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // Nút nạp tiền
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
                  height: 56,
                  child: currentGoal.isCompleted
                      ? ElevatedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.check_circle,
                              color: Colors.white),
                          label: const Text(
                            'Đã hoàn thành',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.themeColor,
                            disabledBackgroundColor: widget.themeColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            _showDepositModal(
                                context, widget.themeColor, currentGoal, ref);
                          },
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showDepositModal(
      BuildContext context, Color themeColor, SavingsGoal goal, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _DepositModal(
          themeColor: themeColor,
          goal: goal,
        );
      },
    );
  }
}

class _DepositModal extends ConsumerStatefulWidget {
  final Color themeColor;
  final SavingsGoal goal;

  const _DepositModal({
    required this.themeColor,
    required this.goal,
  });

  @override
  ConsumerState<_DepositModal> createState() => _DepositModalState();
}

class _DepositModalState extends ConsumerState<_DepositModal> {
  String _modalAmount = '';
  String _modalNote = '';
  late final FocusNode _noteFocusNode;

  @override
  void initState() {
    super.initState();
    _noteFocusNode = FocusNode();
    _noteFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _noteFocusNode.removeListener(_onFocusChange);
    _noteFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final bool isKeyboardVisible = _noteFocusNode.hasFocus;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
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
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'Bỏ tiền tiết kiệm',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              if (!isKeyboardVisible) ...[
                Center(
                  child: Text(
                    _modalAmount.isEmpty
                        ? '0 ${currency.symbol}'
                        : formatCurrency(
                            double.tryParse(_modalAmount) ?? 0,
                            currency,
                          ),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                NumberPad(
                  onNumberTap: (number) {
                    setState(() {
                      _modalAmount += number;
                    });
                  },
                  onBackspaceTap: () {
                    setState(() {
                      if (_modalAmount.isNotEmpty) {
                        _modalAmount =
                            _modalAmount.substring(0, _modalAmount.length - 1);
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                focusNode: _noteFocusNode,
                decoration: InputDecoration(
                  labelText: 'Ghi chú (tùy chọn)',
                  labelStyle: TextStyle(color: widget.themeColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: widget.themeColor,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  _modalNote = value;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _modalAmount.isNotEmpty &&
                          double.tryParse(_modalAmount) != null &&
                          double.parse(_modalAmount) > 0
                      ? () async {
                          final amount = double.parse(_modalAmount);
                          final savingsTransactionNotifier = ref.read(
                              savingsTransactionsProvider(widget.goal.id!)
                                  .notifier);
                          final savingsGoalNotifier =
                              ref.read(savingsGoalsProvider.notifier);
                          try {
                            final transaction = SavingsTransaction(
                              goalId: widget.goal.id!,
                              amount: amount,
                              note: _modalNote.isNotEmpty ? _modalNote : null,
                              savedAt: DateTime.now(),
                            );
                            await savingsTransactionNotifier
                                .addTransaction(transaction);
                            await savingsGoalNotifier.addAmountToGoal(
                                widget.goal.id!, amount);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Đã nạp ${formatCurrency(amount, currency)} vào sổ tiết kiệm!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Có lỗi xảy ra: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Xác nhận nạp tiền',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
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

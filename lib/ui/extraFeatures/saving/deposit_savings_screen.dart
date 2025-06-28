import 'package:Fintrack/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/models/savings_goal.dart';
import '../../../data/models/savings_transaction.dart';
import '../../../providers/savings_goal_provider.dart';
import '../../../providers/savings_transaction_provider.dart';
import '../../../providers/currency_provider.dart';
import '../../../utils/localization.dart';
import '../../widget/widget_barrel.dart';

class DepositSavingsScreen extends ConsumerStatefulWidget {
  final SavingsGoal goal;
  final Color themeColor;
  final String type;
  const DepositSavingsScreen({
    super.key,
    required this.goal,
    required this.themeColor,
    required this.type,
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
        title: widget.type == 'flexible'
            ? Text(
                AppLocalizations.of(context).flexibleSavingsBook,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Text(
                AppLocalizations.of(context).periodicSavingsBook,
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
            child: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
          ),
        ),
        actions: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30.r),
              onTap: () {
                _showUpdateModal(context, themeColor, widget.goal, widget.type);
              },
              child: Padding(
                padding: EdgeInsets.all(8.0.w),
                child: Icon(Icons.edit, color: Colors.white, size: 24.sp),
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

          final savingsTransactionsAsync =
              ref.watch(savingsTransactionsProvider(currentGoal.id!));

          return Column(
            children: [
              // Header với thông tin mục tiêu
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: widget.themeColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.r),
                    bottomRight: Radius.circular(30.r),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      currentGoal.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoCard(
                          AppLocalizations.of(context).target,
                          formatCurrency(
                              currentGoal.targetAmount, currencyType),
                          Icons.flag,
                        ),
                        _buildInfoCard(
                          AppLocalizations.of(context).saved,
                          formatCurrency(
                              currentGoal.currentAmount, currencyType),
                          Icons.account_balance_wallet,
                        ),
                        _buildInfoCard(
                          AppLocalizations.of(context).remaining,
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
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context).progress,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '${currentGoal.progressPercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: widget.themeColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: LinearProgressIndicator(
                        value: currentGoal.progressPercentage / 100,
                        minHeight: 12.h,
                        backgroundColor: Colors.grey.shade300,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(widget.themeColor),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Thông tin mục tiêu và định kỳ
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          // Ngày mục tiêu
                          if (currentGoal.targetDate != null) ...[
                            Row(
                              children: [
                                Icon(Icons.event_available,
                                    size: 18.sp, color: widget.themeColor),
                                SizedBox(width: 8.w),
                                Text(
                                  AppLocalizations.of(context).targetDateLabel,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _formatDate(currentGoal.targetDate!),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: widget.themeColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          // Thông tin định kỳ
                          if (widget.type == 'periodic' &&
                              currentGoal.periodicAmount != null &&
                              currentGoal.periodicFrequency != null) ...[
                            if (currentGoal.targetDate != null)
                              SizedBox(height: 12.h),
                            Row(
                              children: [
                                Icon(Icons.repeat,
                                    size: 18.sp, color: widget.themeColor),
                                SizedBox(width: 8.w),
                                Text(
                                  AppLocalizations.of(context)
                                      .periodicDepositLabel,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      formatCurrency(
                                          currentGoal.periodicAmount!,
                                          currencyType),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: widget.themeColor,
                                      ),
                                    ),
                                    Text(
                                      _getFrequencyText(
                                          currentGoal.periodicFrequency!,
                                          context),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Lịch sử nạp tiền
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Text(
                  AppLocalizations.of(context).depositHistory,
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic),
                ),
              ),
              Expanded(
                child: (savingsTransactionsAsync.isEmpty)
                    ? Center(
                        child: Text(
                          AppLocalizations.of(context).noDepositHistory,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16.sp,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        itemCount: savingsTransactionsAsync.length,
                        separatorBuilder: (_, __) => SizedBox(height: 16.h),
                        itemBuilder: (context, index) {
                          final tx = savingsTransactionsAsync[index];
                          return Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.08),
                                  blurRadius: 4.r,
                                  offset: Offset(0, 2.h),
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
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: widget.themeColor,
                                      ),
                                    ),
                                    Text(
                                      _formatDate(tx.savedAt),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                if (tx.note != null && tx.note!.isNotEmpty) ...[
                                  SizedBox(height: 8.h),
                                  Row(
                                    children: [
                                      Icon(Icons.note,
                                          size: 18.sp, color: Colors.grey),
                                      SizedBox(width: 6.w),
                                      Expanded(
                                        child: Text(
                                          tx.note!,
                                          style: TextStyle(
                                            fontSize: 15.sp,
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
                  height: 56.h,
                  child: currentGoal.isCompleted
                      ? ElevatedButton.icon(
                          onPressed: null,
                          icon: Icon(Icons.check_circle,
                              color: Colors.white, size: 24.sp),
                          label: Text(
                            AppLocalizations.of(context).completed,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.themeColor,
                            disabledBackgroundColor: widget.themeColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            _onDepositPressed(
                                context, widget.themeColor, currentGoal, ref);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.themeColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            AppLocalizations.of(context).continueDeposit,
                            style: TextStyle(
                              fontSize: 18.sp,
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
          child: Text('${AppLocalizations.of(context).error}: $err'),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24.sp),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
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

  void _onDepositPressed(BuildContext context, Color themeColor,
      SavingsGoal goal, WidgetRef ref) async {
    if (widget.type == 'periodic') {
      // Lấy lịch sử giao dịch tiết kiệm
      final transactions = ref.read(savingsTransactionsProvider(goal.id!));
      DateTime now = DateTime.now();
      DateTime? lastDeposit;
      if (transactions.isNotEmpty) {
        // Lấy lần nạp gần nhất
        transactions.sort((a, b) => b.savedAt.compareTo(a.savedAt));
        lastDeposit = transactions.first.savedAt;
      } else {
        lastDeposit = goal.startedDate ?? goal.createdAt;
      }
      // Tính ngày nạp tiếp theo
      DateTime nextDepositDate = _calculateNextDepositDate(
          lastDeposit, goal.periodicFrequency ?? 'monthly');
      // Nếu chưa đến ngày nạp tiếp theo thì hỏi xác nhận
      if (now.isBefore(nextDepositDate)) {
        bool? confirm = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r)),
            backgroundColor: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(16.w),
                    child: Icon(Icons.warning_amber_rounded,
                        color: themeColor, size: 48.sp),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    AppLocalizations.of(context).depositBeforeNextPeriod,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    AppLocalizations.of(context)
                        .youAreDepositingBeforeNextPeriod,
                    style: TextStyle(fontSize: 15.sp, color: Colors.black54),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _formatDate(nextDepositDate),
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: themeColor,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: Text(AppLocalizations.of(context).cancel,
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: Text('Tiếp tục',
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        if (confirm != true) return;
      }
    }
    _showDepositModal(context, themeColor, goal, ref);
  }

  DateTime _calculateNextDepositDate(DateTime lastDeposit, String frequency) {
    switch (frequency) {
      case 'daily':
        return lastDeposit.add(const Duration(days: 1));
      case 'weekly':
        return lastDeposit.add(const Duration(days: 7));
      case 'monthly':
        int year = lastDeposit.year;
        int month = lastDeposit.month + 1;
        if (month > 12) {
          month = 1;
          year++;
        }
        int day = lastDeposit.day;
        while (day > 28) {
          try {
            DateTime(year, month, day);
            break;
          } catch (e) {
            day--;
          }
        }
        return DateTime(year, month, day);
      default:
        return lastDeposit.add(const Duration(days: 7));
    }
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
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
                  l10n.depositMoney,
                  style:
                      TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20.h),
              if (!isKeyboardVisible) ...[
                Center(
                  child: Text(
                    _modalAmount.isEmpty
                        ? '0 ${currency.symbol}'
                        : formatCurrency(
                            double.tryParse(_modalAmount) ?? 0,
                            currency,
                          ),
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
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
                SizedBox(height: 16.h),
              ],
              TextField(
                focusNode: _noteFocusNode,
                decoration: InputDecoration(
                  labelText: l10n.noteOptional,
                  labelStyle: TextStyle(color: widget.themeColor),
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
                ),
                onChanged: (value) {
                  _modalNote = value;
                },
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
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
                              Future.delayed(const Duration(milliseconds: 100),
                                  () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.depositSuccessWith(
                                          formatCurrency(amount, currency)),
                                      style: TextStyle(fontSize: 14.sp),
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              });
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${l10n.error}: $e'),
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
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    l10n.confirmDeposit,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

void _showUpdateModal(
    BuildContext context, Color themeColor, SavingsGoal goal, String type) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => type == 'flexible'
        ? UpdateFlexibleSavingGoalDialog(
            themeColor: themeColor,
            goal: goal,
          )
        : UpdatePeriodicSavingGoalDialog(themeColor: themeColor, goal: goal),
  );
}

String _getFrequencyText(String frequency, BuildContext context) {
  final l10n = AppLocalizations.of(context);
  switch (frequency) {
    case 'daily':
      return l10n.daily;
    case 'weekly':
      return l10n.weekly;
    case 'monthly':
      return l10n.monthly;
    default:
      return frequency;
  }
}

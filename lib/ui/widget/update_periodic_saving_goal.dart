import 'package:Fintrack/providers/providers_barrel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/savings_goal_provider.dart';
import '../../../data/models/savings_goal.dart';
import '../../../providers/currency_provider.dart';
import 'add_flexible_saving_goal.dart';

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
                  'Chỉnh sửa sổ tiết kiệm định kỳ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 26),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Tên sổ tiết kiệm',
                        labelStyle: const TextStyle(
                          color: Colors.black,
                        ),
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
                        prefixIcon:
                            Icon(Icons.savings, color: widget.themeColor),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Nhập tên' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _targetAmountController,
                      decoration: InputDecoration(
                        labelText: 'Số tiền mục tiêu',
                        labelStyle: const TextStyle(
                          color: Colors.black,
                        ),
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
                        prefixIcon:
                            Icon(Icons.attach_money, color: widget.themeColor),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter(currencyType)],
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Nhập số tiền';
                        final amount = getNumericValueFromFormattedText(value);
                        if (amount <= 0) return 'Số tiền phải lớn hơn 0';
                        final currentGoal = savingsGoalAsync.when(
                          data: (goals) => goals.firstWhere(
                            (g) => g.id == widget.goal.id,
                            orElse: () => widget.goal,
                          ),
                          loading: () => widget.goal,
                          error: (_, __) => widget.goal,
                        );
                        if (amount < currentGoal.currentAmount) {
                          return 'Số tiền mục tiêu không được nhỏ hơn số tiền đã tiết kiệm (${formatCurrency(currentGoal.currentAmount, currencyType)})';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _periodicAmountController,
                            decoration: InputDecoration(
                              labelText: 'Số tiền định kỳ',
                              labelStyle: const TextStyle(
                                color: Colors.black,
                              ),
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
                              prefixIcon:
                                  Icon(Icons.repeat, color: widget.themeColor),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              CurrencyInputFormatter(currencyType)
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Nhập số tiền định kỳ';
                              final amount =
                                  getNumericValueFromFormattedText(value);
                              if (amount <= 0)
                                return 'Số tiền định kỳ phải lớn hơn 0';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
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
                                        width: 40,
                                        height: 4,
                                        margin: const EdgeInsets.only(
                                            top: 12, bottom: 20),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                      const Text(
                                        'Chọn tần suất',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2D3142),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      ...['daily', 'weekly', 'monthly']
                                          .map((frequency) {
                                        final labels = {
                                          'daily': 'Hàng ngày',
                                          'weekly': 'Hàng tuần',
                                          'monthly': 'Hàng tháng',
                                        };
                                        final icons = {
                                          'daily': Icons.today,
                                          'weekly': Icons.view_week,
                                          'monthly': Icons.calendar_month,
                                        };

                                        return ListTile(
                                          leading: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: _periodicFrequency ==
                                                      frequency
                                                  ? widget.themeColor
                                                      .withOpacity(0.1)
                                                  : Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              icons[frequency],
                                              color: _periodicFrequency ==
                                                      frequency
                                                  ? widget.themeColor
                                                  : Colors.grey[600],
                                              size: 20,
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
                                            ),
                                          ),
                                          trailing:
                                              _periodicFrequency == frequency
                                                  ? Icon(
                                                      Icons.check_circle,
                                                      color: widget.themeColor,
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
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Tần suất',
                                labelStyle:
                                    const TextStyle(color: Colors.black),
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
                                prefixIcon: Icon(Icons.schedule,
                                    color: widget.themeColor),
                                suffixIcon:
                                    const Icon(Icons.keyboard_arrow_down),
                              ),
                              child: Text(
                                _periodicFrequency == null
                                    ? 'Tần suất'
                                    : {
                                        'daily': 'Hàng ngày',
                                        'weekly': 'Hàng tuần',
                                        'monthly': 'Hàng tháng',
                                      }[_periodicFrequency]!,
                                style: TextStyle(
                                  color: _periodicFrequency == null
                                      ? Colors.grey
                                      : Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
                                labelText: 'Ngày bắt đầu',
                                labelStyle:
                                    const TextStyle(color: Colors.black),
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
                                prefixIcon: Icon(Icons.calendar_today,
                                    color: widget.themeColor),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 0),
                                child: Text(
                                  _startedDate == null
                                      ? 'Chọn ngày'
                                      : '${_startedDate!.day}/${_startedDate!.month}/${_startedDate!.year}',
                                  style: TextStyle(
                                    color: _startedDate == null
                                        ? Colors.grey
                                        : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                                labelText: 'Ngày mục tiêu',
                                labelStyle:
                                    const TextStyle(color: Colors.black),
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
                                prefixIcon:
                                    Icon(Icons.flag, color: widget.themeColor),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 0),
                                child: Text(
                                  _targetDate == null
                                      ? 'Chọn ngày (tùy chọn)'
                                      : '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}',
                                  style: TextStyle(
                                    color: _targetDate == null
                                        ? Colors.grey
                                        : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    savingsGoalAsync.when(
                      data: (goals) {
                        final currentGoal = goals.firstWhere(
                          (g) => g.id == widget.goal.id,
                          orElse: () => widget.goal,
                        );
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Thông tin hiện tại:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Đã tiết kiệm:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    formatCurrency(currentGoal.currentAmount,
                                        currencyType),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: widget.themeColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tiến độ:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '${currentGoal.progressPercentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 14,
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
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, __) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: const Text(
                          'Lỗi tải dữ liệu',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        _showDeleteConfirmation(context);
                      },
                      child: const Text('Xóa sổ tiết kiệm',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.themeColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                              const SnackBar(
                                  content: Text('Vui lòng chọn ngày bắt đầu')),
                            );
                            return;
                          }
                          if (periodicFrequency == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Vui lòng chọn tần suất')),
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
                              const SnackBar(
                                content: Text(
                                  'Cập nhật thành công!',
                                  style: TextStyle(fontSize: 14),
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
                      child: const Text('Cập nhật',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text(
            'Bạn có chắc chắn muốn xóa sổ tiết kiệm "${widget.goal.name}"?\n\n'
            'Hành động này không thể hoàn tác và sẽ xóa tất cả lịch sử giao dịch liên quan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
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
                    const SnackBar(
                      content: Text('Đã xóa sổ tiết kiệm!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Future.delayed(Duration.zero, () {
                    Navigator.pop(context);
                  });
                }
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
}

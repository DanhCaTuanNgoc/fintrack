import 'package:Fintrack/providers/providers_barrel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/savings_goal.dart';
import './add_flexible_saving_goal.dart';

class AddPeriodicSavingGoalDialog extends ConsumerStatefulWidget {
  final Color themeColor;
  const AddPeriodicSavingGoalDialog({super.key, required this.themeColor});

  @override
  ConsumerState<AddPeriodicSavingGoalDialog> createState() =>
      _AddPeriodicSavingGoalDialogState();
}

class _AddPeriodicSavingGoalDialogState
    extends ConsumerState<AddPeriodicSavingGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _periodicAmountController = TextEditingController();
  String? _periodicFrequency; // daily, weekly, monthly
  DateTime? _targetDate;
  DateTime? _startedDate;

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
    final savingsGoal = ref.watch(savingsGoalsProvider);

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
                  'Tạo sổ tiết kiệm định kỳ',
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
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 14,
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
                        prefixIcon: Icon(Icons.book, color: widget.themeColor),
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
                          fontSize: 14,
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
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _periodicAmountController,
                            decoration: InputDecoration(
                              labelText: 'Nạp định kỳ',
                              labelStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
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
                        const SizedBox(width: 16),
                        Expanded(
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
                                firstDate: now,
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
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
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
                                      ? 'Chọn ngày'
                                      : '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}',
                                  style: TextStyle(
                                    color: _targetDate == null
                                        ? Colors.grey
                                        : Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                          await notifier.addSavingsGoal(
                            SavingsGoal(
                              name: name,
                              targetAmount: targetAmount,
                              type: 'periodic',
                              currentAmount: 0.0,
                              periodicAmount: periodicAmount,
                              periodicFrequency: periodicFrequency,
                              targetDate: targetDate,
                              startedDate: startedDate,
                              isActive: true,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Tạo sổ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
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
}

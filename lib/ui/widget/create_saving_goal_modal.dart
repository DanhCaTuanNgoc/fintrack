import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers_barrel.dart';
import '../../data/models/models_barrel.dart';

class CreateSavingsGoalModal extends ConsumerStatefulWidget {
  final Color themeColor;
  final String? initialGoalType;

  const CreateSavingsGoalModal({
    super.key,
    required this.themeColor,
    this.initialGoalType,
  });

  @override
  ConsumerState<CreateSavingsGoalModal> createState() =>
      _CreateSavingsGoalModalState();
}

class _CreateSavingsGoalModalState
    extends ConsumerState<CreateSavingsGoalModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _monthlyAmountController = TextEditingController();
  String _selectedGoalType = 'flexible';
  DateTime? _targetDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialGoalType != null) {
      _selectedGoalType = widget.initialGoalType!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _monthlyAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tạo mục tiêu tiết kiệm',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.themeColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Goal Type Selection
              Text(
                'Loại mục tiêu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.themeColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildGoalTypeCard(
                      'flexible',
                      'Linh hoạt',
                      Icons.savings,
                      'Tiết kiệm theo khả năng',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGoalTypeCard(
                      'fixed',
                      'Cố định',
                      Icons.schedule,
                      'Tiết kiệm theo lịch trình',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên mục tiêu *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên mục tiêu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Target Amount Field
              TextFormField(
                controller: _targetAmountController,
                decoration: const InputDecoration(
                  labelText: 'Số tiền mục tiêu *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập số tiền mục tiêu';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Số tiền phải lớn hơn 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Monthly Amount Field (for fixed goals)
              if (_selectedGoalType == 'fixed') ...[
                TextFormField(
                  controller: _monthlyAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Số tiền hàng tháng *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số tiền hàng tháng';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Số tiền phải lớn hơn 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Target Date Field
                InkWell(
                  onTap: _selectTargetDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Ngày hoàn thành *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.event),
                    ),
                    child: Text(
                      _targetDate != null
                          ? '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}'
                          : 'Chọn ngày',
                      style: TextStyle(
                        color: _targetDate != null
                            ? Colors.black
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Create Button
              ElevatedButton(
                onPressed: _createGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.themeColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Tạo mục tiêu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalTypeCard(
      String type, String title, IconData icon, String description) {
    final isSelected = _selectedGoalType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGoalType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? widget.themeColor.withOpacity(0.1)
              : Colors.grey[100],
          border: Border.all(
            color: isSelected ? widget.themeColor : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? widget.themeColor : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? widget.themeColor : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTargetDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  void _createGoal() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGoalType == 'fixed' && _targetDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày hoàn thành'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final targetAmount = double.parse(_targetAmountController.text);

    final newGoal = SavingsGoal(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      targetAmount: targetAmount,
      currentAmount: 0,
      type: _selectedGoalType,
      targetDate: _targetDate,
      createdAt: DateTime.now(),
    );

    ref.read(savingsGoalsProvider.notifier).addSavingsGoal(newGoal);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã tạo mục tiêu "${newGoal.name}"'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }
}

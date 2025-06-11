import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/recurring_bill.dart';
import '../providers/recurring_bill_provider.dart';

class RecurringBillForm extends ConsumerStatefulWidget {
  final RecurringBill? bill;

  const RecurringBillForm({super.key, this.bill});

  @override
  ConsumerState<RecurringBillForm> createState() => _RecurringBillFormState();
}

class _RecurringBillFormState extends ConsumerState<RecurringBillForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late int _dayOfMonth;
  late String _category;

  final List<String> _categories = [
    'Tiền điện',
    'Tiền nước',
    'Tiền internet',
    'Tiền điện thoại',
    'Tiền thuê nhà',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.bill?.title ?? '');
    _amountController = TextEditingController(
      text: widget.bill?.amount.toString() ?? '',
    );
    _noteController = TextEditingController(text: widget.bill?.note ?? '');
    _dayOfMonth = widget.bill?.dayOfMonth ?? 1;
    _category = widget.bill?.category ?? _categories[0];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final bill = RecurringBill(
        id: widget.bill?.id,
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        dayOfMonth: _dayOfMonth,
        category: _category,
        note: _noteController.text,
        lastPaidDate: widget.bill?.lastPaidDate,
      );

      if (widget.bill == null) {
        ref.read(recurringBillsProvider.notifier).addRecurringBill(bill);
      } else {
        ref.read(recurringBillsProvider.notifier).updateRecurringBill(bill);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            Text(
              widget.bill == null ? 'Thêm hóa đơn mới' : 'Chỉnh sửa hóa đơn',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tên hóa đơn',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên hóa đơn';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Số tiền',
                border: OutlineInputBorder(),
                suffixText: 'VND',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số tiền';
                }
                if (double.tryParse(value) == null) {
                  return 'Vui lòng nhập số hợp lệ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Danh mục',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _category = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _dayOfMonth,
              decoration: const InputDecoration(
                labelText: 'Ngày thanh toán hàng tháng',
                border: OutlineInputBorder(),
              ),
              items: List.generate(31, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text('${index + 1}'),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _dayOfMonth = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(
                widget.bill == null ? 'Thêm' : 'Cập nhật',
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/more/transaction.dart';
import '../../providers/more/transaction_provider.dart';
import '../../providers/currency_provider.dart';
import './number_pad.dart';
import './type_button.dart';

class EditTransactionModal extends ConsumerStatefulWidget {
  final Transaction transaction;
  final Color themeColor;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> expenseCategories;
  final List<Map<String, dynamic>> incomeCategories;

  const EditTransactionModal({
    super.key,
    required this.transaction,
    required this.themeColor,
    required this.categories,
    required this.expenseCategories,
    required this.incomeCategories,
  });

  @override
  ConsumerState<EditTransactionModal> createState() =>
      _EditTransactionModalState();
}

class _EditTransactionModalState extends ConsumerState<EditTransactionModal> {
  late String _amount;
  late String _note;
  String? _selectedCategory;
  late bool _isExpense;

  @override
  void initState() {
    super.initState();
    _amount = widget.transaction.amount.toString();
    _note = widget.transaction.note;
    _isExpense = widget.transaction.type == 'expense';
    _selectedCategory = widget.categories.firstWhere(
      (cat) => cat['id'] == widget.transaction.categoryId,
      orElse: () => {'name': null},
    )['name'];
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);

    final categories =
        _isExpense ? widget.expenseCategories : widget.incomeCategories;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chỉnh sửa giao dịch',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  Row(
                    children: [
                      TypeButton(
                        text: 'Chi tiêu',
                        isSelected: _isExpense,
                        themeColor: widget.themeColor,
                        onTap: () {
                          setState(() {
                            _isExpense = true;
                            _selectedCategory = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      TypeButton(
                        text: 'Thu nhập',
                        isSelected: !_isExpense,
                        themeColor: widget.themeColor,
                        onTap: () {
                          setState(() {
                            _isExpense = false;
                            _selectedCategory = null;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: TextEditingController(text: _note),
                decoration: InputDecoration(
                  labelText: 'Ghi chú',
                  labelStyle: TextStyle(color: widget.themeColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.themeColor, width: 2),
                  ),
                ),
                onChanged: (value) => _note = value,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      _amount.isEmpty
                          ? '0 ${currency.symbol}'
                          : '${formatCurrency(double.tryParse(_amount) ?? 0, currency)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 16),
                    NumberPad(
                      onNumberTap: (number) {
                        setState(() {
                          _amount += number;
                        });
                      },
                      onBackspaceTap: () {
                        setState(() {
                          if (_amount.isNotEmpty) {
                            _amount = _amount.substring(0, _amount.length - 1);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
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
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              margin:
                                  const EdgeInsets.only(top: 12, bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Text(
                              'Chọn danh mục ${_isExpense ? 'chi tiêu' : 'thu nhập'}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3142),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ...categories.map((category) {
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _selectedCategory == category['name']
                                        ? widget.themeColor.withOpacity(0.1)
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    category['icon'],
                                    style: TextStyle(
                                      fontSize: 20,
                                      color:
                                          _selectedCategory == category['name']
                                              ? widget.themeColor
                                              : Colors.grey[600],
                                    ),
                                  ),
                                ),
                                title: Text(
                                  category['name'],
                                  style: TextStyle(
                                    fontWeight:
                                        _selectedCategory == category['name']
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color: _selectedCategory == category['name']
                                        ? widget.themeColor
                                        : const Color(0xFF2D3142),
                                  ),
                                ),
                                trailing: _selectedCategory == category['name']
                                    ? Icon(
                                        Icons.check_circle,
                                        color: widget.themeColor,
                                      )
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = category['name'];
                                  });
                                  Future.delayed(Duration.zero,
                                      () => {Navigator.pop(context)});
                                },
                              );
                            }).toList(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Danh mục',
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
                    suffixIcon: const Icon(Icons.keyboard_arrow_down),
                  ),
                  child: _selectedCategory == null
                      ? Text(
                          'Chọn danh mục',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        )
                      : Row(
                          children: [
                            Text(
                              categories.firstWhere(
                                (cat) => cat['name'] == _selectedCategory,
                              )['icon'],
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedCategory!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2D3142),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_amount.isNotEmpty && _selectedCategory != null) {
                      final selectedCategoryData = categories.firstWhere(
                        (cat) => cat['name'] == _selectedCategory,
                      );

                      final updated = widget.transaction.copyWith(
                        amount: double.parse(_amount),
                        note: _note,
                        type: _isExpense ? 'expense' : 'income',
                        categoryId: selectedCategoryData['id'],
                      );

                      await ref
                          .read(transactionsProvider.notifier)
                          .updateTransaction(updated);
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Lưu thay đổi',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
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

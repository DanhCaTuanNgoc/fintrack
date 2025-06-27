import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 12.h, bottom: 20.h),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Chỉnh sửa giao dịch',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3142),
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
                          SizedBox(width: 8.w),
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
                  SizedBox(height: 18.h),
                  TextField(
                    controller: TextEditingController(text: _note),
                    decoration: InputDecoration(
                      labelText: 'Ghi chú',
                      labelStyle: TextStyle(color: widget.themeColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                            BorderSide(color: widget.themeColor, width: 2),
                      ),
                      prefixIcon: Icon(
                        Icons.note,
                        color: widget.themeColor,
                      ),
                    ),
                    onChanged: (value) => _note = value,
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.only(top: 9.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _amount.isEmpty
                              ? '0 ${currency.symbol}'
                              : '${formatCurrency(double.tryParse(_amount) ?? 0, currency)}',
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3142),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        NumberPad(
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
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20.r),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 40.w,
                                height: 4.h,
                                margin:
                                    EdgeInsets.only(top: 12.h, bottom: 20.h),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),
                              Text(
                                'Chọn danh mục ${_isExpense ? 'chi tiêu' : 'thu nhập'}',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2D3142),
                                ),
                              ),
                              SizedBox(height: 10.h),
                              SingleChildScrollView(
                                child: Column(
                                  children: categories.map((category) {
                                    return ListTile(
                                      leading: Container(
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color: _selectedCategory ==
                                                  category['name']
                                              ? widget.themeColor
                                                  .withOpacity(0.1)
                                              : Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                        ),
                                        child: Text(
                                          category['icon'],
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                            color: _selectedCategory ==
                                                    category['name']
                                                ? widget.themeColor
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        category['name'],
                                        style: TextStyle(
                                          fontWeight: _selectedCategory ==
                                                  category['name']
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: _selectedCategory ==
                                                  category['name']
                                              ? widget.themeColor
                                              : const Color(0xFF2D3142),
                                        ),
                                      ),
                                      trailing:
                                          _selectedCategory == category['name']
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
                                ),
                              ),
                              SizedBox(height: 10.h)
                            ],
                          ),
                        ),
                      );
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Danh mục',
                        labelStyle: TextStyle(color: widget.themeColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
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
                                fontSize: 16.sp,
                              ),
                            )
                          : Row(
                              children: [
                                Text(
                                  categories.firstWhere(
                                    (cat) => cat['name'] == _selectedCategory,
                                  )['icon'],
                                  style: TextStyle(fontSize: 20.sp),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  _selectedCategory!,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: const Color(0xFF2D3142),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: 24.h),
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
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Chỉnh sửa',
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

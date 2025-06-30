import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/more/transaction.dart';
import '../../providers/more/transaction_provider.dart';
import '../../providers/currency_provider.dart';
import '../../utils/localization.dart';
import './number_pad.dart';
import './type_button.dart';
import './custom_snackbar.dart';
import '../../utils/category_helper.dart';
import './category_selection_modal.dart';

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
  late bool _isExpense;
  late String _amount;
  late String _note;
  String? _selectedCategoryIcon;
  String? _noteError;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    _amount = widget.transaction.amount.toInt().toString();
    _note = widget.transaction.note ?? '';
    _isExpense = widget.transaction.type == 'expense';
    final initialCategory = widget.categories.firstWhere(
      (cat) => cat['id'] == widget.transaction.categoryId,
      orElse: () => {'icon': null},
    );
    _selectedCategoryIcon = initialCategory['icon'];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                        l10n.editTransaction,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3142),
                        ),
                      ),
                      Row(
                        children: [
                          TypeButton(
                            text: l10n.expense,
                            isSelected: _isExpense,
                            themeColor: widget.themeColor,
                            onTap: () {
                              setState(() {
                                _isExpense = true;
                                _selectedCategoryIcon = null;
                              });
                            },
                          ),
                          SizedBox(width: 8.w),
                          TypeButton(
                            text: l10n.income,
                            isSelected: !_isExpense,
                            themeColor: widget.themeColor,
                            onTap: () {
                              setState(() {
                                _isExpense = false;
                                _selectedCategoryIcon = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  TextField(
                    controller: TextEditingController(
                        text: widget.transaction.note ?? ''),
                    decoration: InputDecoration(
                      labelText: l10n.note,
                      labelStyle: TextStyle(color: widget.themeColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                            BorderSide(color: widget.themeColor, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 1,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.note,
                        color: widget.themeColor,
                      ),
                    ),
                    onChanged: (value) {
                      _note = value;
                      // Clear error when user starts typing
                      if (_noteError != null) {
                        setState(() {
                          _noteError = null;
                        });
                      }
                    },
                  ),
                  if (_noteError != null) ...[
                    SizedBox(height: 8.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: Colors.red.shade200,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _noteError!,
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
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
                        SizedBox(height: 10.h),
                        NumberPad(
                          onNumberTap: (number) {
                            if (mounted) {
                              setState(() {
                                _amount += number;
                                // Clear error when user starts typing
                                if (_amountError != null) {
                                  _amountError = null;
                                }
                              });
                            }
                          },
                          onBackspaceTap: () {
                            if (mounted) {
                              setState(() {
                                if (_amount.isNotEmpty) {
                                  _amount =
                                      _amount.substring(0, _amount.length - 1);
                                }
                                // Clear error when user starts typing
                                if (_amountError != null) {
                                  _amountError = null;
                                }
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  if (_amountError != null) ...[
                    SizedBox(height: 8.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: Colors.red.shade200,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _amountError!,
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 16.h),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) => CategorySelectionModal(
                          categories: categories,
                          selectedCategory: _selectedCategoryIcon,
                          themeColor: widget.themeColor,
                          isExpense: _isExpense,
                          onCategoryTap: (icon) {
                            setState(() {
                              _selectedCategoryIcon = icon;
                            });
                          },
                        ),
                      );
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.category,
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
                      child: _selectedCategoryIcon == null
                          ? Text(
                              l10n.chooseCategory,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16.sp,
                              ),
                            )
                          : Row(
                              children: [
                                Text(
                                  _selectedCategoryIcon!,
                                  style: TextStyle(fontSize: 20.sp),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  CategoryHelper.getLocalizedCategoryName(
                                      _selectedCategoryIcon!, l10n),
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
                        // Validate note field
                        if (_note.trim().isEmpty) {
                          setState(() {
                            _noteError =
                                'Vui lòng nhập chú thích cho giao dịch';
                          });
                          return;
                        }

                        // Validate amount
                        if (_amount.isEmpty) {
                          setState(() {
                            _amountError = 'Vui lòng nhập số tiền';
                          });
                          return;
                        }

                        if (_amount.isNotEmpty &&
                            _selectedCategoryIcon != null) {
                          final selectedCategoryData = categories.firstWhere(
                            (cat) => cat['icon'] == _selectedCategoryIcon,
                            orElse: () => {'id': null},
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
                          if (!mounted) return;
                          Navigator.pop(context);

                          Future.delayed(Duration.zero, () {
                            if (mounted) {
                              CustomSnackBar.showSuccess(
                                context,
                                message: l10n.updateSuccess,
                              );
                            }
                          });
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
                        l10n.edit,
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

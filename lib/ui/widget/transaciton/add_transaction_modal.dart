import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/models_barrel.dart';
import '../../../providers/providers_barrel.dart';
import '../../../utils/localization.dart';
import '../components/type_button.dart';
import '../components/number_pad.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/category_helper.dart';
import '../components/custom_snackbar.dart';
import '../components/category_selection_modal.dart';

class AddTransactionModal extends ConsumerStatefulWidget {
  final Book currentBook;
  final Color themeColor;
  final bool initialIsExpense;
  final List<Map<String, dynamic>> expenseCategories;
  final List<Map<String, dynamic>> incomeCategories;

  const AddTransactionModal({
    super.key,
    required this.currentBook,
    required this.themeColor,
    required this.initialIsExpense,
    required this.expenseCategories,
    required this.incomeCategories,
  });

  @override
  ConsumerState<AddTransactionModal> createState() =>
      _AddTransactionModalState();
}

class _AddTransactionModalState extends ConsumerState<AddTransactionModal> {
  bool _isExpense = true;
  String _amount = '';
  String _note = '';
  String? _selectedCategory;
  String? _noteError;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    _isExpense = widget.initialIsExpense;
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.addTransaction,
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
                            onTap: () {
                              setState(() {
                                _isExpense = true;
                                _selectedCategory = null;
                              });
                            },
                            themeColor: widget.themeColor,
                          ),
                          SizedBox(width: 8.w),
                          TypeButton(
                            text: l10n.income,
                            isSelected: !_isExpense,
                            onTap: () {
                              setState(() {
                                _isExpense = false;
                                _selectedCategory = null;
                              });
                            },
                            themeColor: widget.themeColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  TextField(
                    decoration: InputDecoration(
                      labelText: l10n.note,
                      labelStyle: TextStyle(color: widget.themeColor),
                      prefixIcon: Icon(
                        Icons.note,
                        color: widget.themeColor,
                      ),
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
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1,
                        ),
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
                              : formatCurrency(double.tryParse(_amount) ?? 0, currency),
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3142),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        NumberPad(
                          onNumberTap: (number) {
                            setState(() {
                              _amount += number;
                              // Clear error when user starts typing
                              if (_amountError != null) {
                                _amountError = null;
                              }
                            });
                          },
                          onBackspaceTap: () {
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
                        builder: (context) => CategorySelectionModal(
                          categories: categories,
                          selectedCategory: _selectedCategory,
                          themeColor: widget.themeColor,
                          isExpense: _isExpense,
                          onCategoryTap: (category) {
                            setState(() {
                              _selectedCategory = category;
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
                      child: _selectedCategory == null
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
                                  categories.firstWhere(
                                    (cat) => cat['icon'] == _selectedCategory,
                                  )['icon'],
                                  style: TextStyle(fontSize: 20.sp),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  CategoryHelper.getLocalizedCategoryName(
                                    categories.firstWhere((cat) =>
                                        cat['icon'] ==
                                        _selectedCategory)['icon'],
                                    l10n,
                                  ),
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

                        try {
                          final notifier =
                              ref.read(transactionsProvider.notifier);

                          // Handle category - can be null
                          int? categoryId;
                          if (_selectedCategory != null) {
                            try {
                              final selected = categories.firstWhere(
                                (cat) => cat['icon'] == _selectedCategory,
                              );
                              categoryId = selected['id'];
                            } catch (e) {
                              // Category not found, use null
                              categoryId = null;
                            }
                          }

                          await notifier.createTransaction(
                            amount: double.parse(_amount),
                            note: _note,
                            type: _isExpense ? 'expense' : 'income',
                            categoryId: categoryId,
                            bookId: widget.currentBook.id ?? 0,
                            userId: 1,
                          );

                          setState(() {
                            _amount = '';
                            _note = '';
                            _selectedCategory = null;
                            _noteError = null;
                            _amountError = null;
                          });

                          if (!mounted) return;
                          Navigator.pop(context);

                          // Hiển thị thông báo cho người dùng
                          Future.delayed(
                            const Duration(milliseconds: 100),
                            () {
                              if (mounted) {
                                CustomSnackBar.showSuccess(
                                  context,
                                  message: AppLocalizations.of(context).success,
                                );
                              }
                            },
                          );
                        } catch (e) {
                          print('Error creating transaction: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.themeColor,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.add,
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
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/category_helper.dart';
import '../../../utils/localization.dart';

class CategorySelectionModal extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String? selectedCategory;
  final Color themeColor;
  final bool isExpense;
  final Function(String) onCategoryTap;

  const CategorySelectionModal({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.themeColor,
    required this.isExpense,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
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
            margin: EdgeInsets.only(top: 12.h, bottom: 20.h),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Text(
            isExpense ? l10n.selectExpenseCategory : l10n.selectIncomeCategory,
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
                final localizedName = CategoryHelper.getLocalizedCategoryName(
                    category['icon'], l10n);
                return ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: selectedCategory == category['icon']
                          ? themeColor.withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      category['icon'],
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: selectedCategory == category['icon']
                            ? themeColor
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                  title: Text(
                    localizedName,
                    style: TextStyle(
                      fontWeight: selectedCategory == category['icon']
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: selectedCategory == category['icon']
                          ? themeColor
                          : const Color(0xFF2D3142),
                    ),
                  ),
                  trailing: selectedCategory == category['icon']
                      ? Icon(
                          Icons.check_circle,
                          color: themeColor,
                        )
                      : null,
                  onTap: () {
                    onCategoryTap(category['icon']);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
          SizedBox(
            height: 10.h,
          )
        ],
      ),
    );
  }
}

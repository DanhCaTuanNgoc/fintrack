import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../providers/providers_barrel.dart';
import '../../../utils/localization.dart';
import '../../../utils/category_helper.dart';

class ExpenseItem extends StatefulWidget {
  final String dateKey;
  final List<dynamic> transactions;
  final double dayExpense;
  final Color themeColor;
  final List<Map<String, dynamic>> categories;
  final bool isAmountVisible;
  final CurrencyType currencySymbol;
  final Function(dynamic transaction) onTransactionTap;

  const ExpenseItem({
    super.key,
    required this.dateKey,
    required this.transactions,
    required this.dayExpense,
    required this.themeColor,
    required this.categories,
    required this.isAmountVisible,
    required this.currencySymbol,
    required this.onTransactionTap,
  });

  @override
  State<ExpenseItem> createState() => _ExpenseItemState();
}

class _ExpenseItemState extends State<ExpenseItem> {
  bool isExpanded = false;
  final Map<String, IconData> _iconMapping = {
    '🍔': Icons.restaurant,
    '🚗': Icons.directions_car,
    '🛍': Icons.shopping_bag,
    '🎮': Icons.sports_esports,
    '📚': Icons.book,
    '💅': Icons.face,
    '💰': Icons.attach_money,
    '🎁': Icons.card_giftcard,
    '📈': Icons.trending_up,
    '🏠': Icons.home,
  };

  IconData _getIconFromEmoji(String emoji) {
    return _iconMapping[emoji] ?? Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###');
    final date = DateFormat('dd/MM/yy').parse(widget.dateKey);
    final weekdayNumber = date.weekday;
    final l10n = AppLocalizations.of(context);

    final weekdayMap = {
      1: l10n.monday,
      2: l10n.tuesday,
      3: l10n.wednesday,
      4: l10n.thursday,
      5: l10n.friday,
      6: l10n.saturday,
      7: l10n.sunday,
    };

    final formattedDate =
        '${weekdayMap[weekdayNumber]}, ${DateFormat('dd/MM').format(date)}';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2.r,
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1.r,
            blurRadius: 2.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => isExpanded = !isExpanded),
            splashFactory: NoSplash.splashFactory,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                border: isExpanded
                    ? Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.1),
                          width: 1.w,
                        ),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_right,
                      color: widget.themeColor,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${l10n.total}: ${widget.isAmountVisible ? (widget.dayExpense > 0 ? '+' : '-') + formatCurrency(widget.dayExpense.abs(), widget.currencySymbol) : '•••••'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: SizedBox(height: 0.h),
            secondChild: Column(
              children: widget.transactions.map((transaction) {
                final category = widget.categories.firstWhere(
                  (cat) => cat['id'] == transaction.categoryId,
                  orElse: () => {'name': '', 'icon': ''},
                );
                final categoryName = CategoryHelper.getLocalizedCategoryName(
                    category['icon'], l10n);

                final bgColor = widget.themeColor.withOpacity(0.1);

                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: InkWell(
                    onTap: () => widget.onTransactionTap(transaction),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            _getIconFromEmoji(category['icon'] ?? '🏷️'),
                            color: widget.themeColor,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            transaction.note,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          '${transaction.type == 'expense' ? '-' : '+'}${widget.isAmountVisible ? formatCurrency(transaction.amount, widget.currencySymbol) : '•••••'}',
                          style: TextStyle(
                            color: transaction.type == 'expense'
                                ? Colors.red
                                : Colors.green,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

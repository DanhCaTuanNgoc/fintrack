import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/models_barrel.dart';
import '../../providers/providers_barrel.dart';
import '../../utils/category_helper.dart';
import '../../utils/localization.dart';

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

class CalendarExpenseItem extends ConsumerWidget {
  final String dateKey;
  final List<Transaction> transactions;
  final double dayExpense;
  final Color themeColor;
  final bool isAmountVisible;
  final List<Map<String, dynamic>> categories;
  final void Function(Transaction transaction) onTapTransaction;

  const CalendarExpenseItem({
    super.key,
    required this.dateKey,
    required this.transactions,
    required this.dayExpense,
    required this.themeColor,
    required this.isAmountVisible,
    required this.categories,
    required this.onTapTransaction,
  });

  IconData _getIconFromEmoji(String emoji) {
    return _iconMapping[emoji] ?? Icons.category;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateFormat('dd/MM/yy').parse(dateKey);
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
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔒 Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                  width: 2.w,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: themeColor,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${l10n.total} : ${isAmountVisible ? (dayExpense >= 0 ? '+' : '-') + formatCurrency(dayExpense.abs(), ref.watch(currencyProvider)) : '•••••'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                ),
              ],
            ),
          ),

          /// 🧾 List Transactions
          SizedBox(
            height: 240.h,
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 8.h),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];

                final category = categories.firstWhere(
                  (cat) => cat['id'] == transaction.categoryId,
                  orElse: () => {'name': '', 'icon': ''},
                );
                final categoryName = CategoryHelper.getLocalizedCategoryName(
                    category['icon'], l10n);

                final icon = _getIconFromEmoji(category['icon'] ?? '🏷️');

                return Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: InkWell(
                    onTap: () => onTapTransaction(transaction),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            _getIconFromEmoji(category['icon'] ?? '🏷️'),
                            color: themeColor,
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
                          '${transaction.type == 'expense' ? '-' : '+'}${isAmountVisible ? formatCurrency(transaction.amount, ref.watch(currencyProvider)) : '•••••'}',
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
              },
            ),
          ),
        ],
      ),
    );
  }
}

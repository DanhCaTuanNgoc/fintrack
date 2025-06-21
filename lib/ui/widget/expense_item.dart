import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/models_barrel.dart'; // nếu có
import '../../providers/providers_barrel.dart';

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
  };

  IconData _getIconFromEmoji(String emoji) {
    return _iconMapping[emoji] ?? Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###');
    final date = DateFormat('dd/MM/yy').parse(widget.dateKey);
    final weekdayNumber = date.weekday;
    const weekdayMap = {
      1: 'Th 2',
      2: 'Th 3',
      3: 'Th 4',
      4: 'Th 5',
      5: 'Th 6',
      6: 'Th 7',
      7: 'CN',
    };

    final formattedDate =
        '${weekdayMap[weekdayNumber]}, ${DateFormat('dd/MM').format(date)}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 2),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: isExpanded
                    ? Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.1),
                          width: 1,
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
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Tổng: ${widget.isAmountVisible ? (widget.dayExpense >= 0 ? '+' : '-') + formatCurrency(widget.dayExpense.abs(), widget.currencySymbol) : '•••••'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: Column(
              children: widget.transactions.map((transaction) {
                final category = widget.categories.firstWhere(
                  (cat) => cat['id'] == transaction.categoryId,
                  orElse: () => {'icon': '🏷️', 'color': '0xFF6C63FF'},
                );

                final bgColor = widget.themeColor.withOpacity(0.1);

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: InkWell(
                    onTap: () => widget.onTransactionTap(transaction),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getIconFromEmoji(category['icon'] ?? '🏷️'),
                            color: widget.themeColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            transaction.note,
                            style: const TextStyle(
                              fontSize: 15,
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
                            fontSize: 15,
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

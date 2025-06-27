import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/currency_provider.dart';

class StatItem extends ConsumerWidget {
  final String title;
  final String amount;
  final Color textColor;
  final bool showNegative;
  final bool isAmountVisible;

  const StatItem({
    super.key,
    required this.title,
    required this.amount,
    required this.textColor,
    required this.isAmountVisible,
    this.showNegative = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amountValue =
        double.tryParse(amount.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

    final currencyType = ref.watch(currencyProvider);

    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isAmountVisible
                ? '${formatCurrency(amountValue, currencyType)}'
                : '•••••',
            style: TextStyle(
              color: textColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

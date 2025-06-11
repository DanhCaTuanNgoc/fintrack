import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/recurring_bill.dart';
import '../providers/recurring_bill_provider.dart';
import '../widgets/recurring_bill_form.dart';

class RecurringBillsScreen extends ConsumerWidget {
  const RecurringBillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringBillsAsync = ref.watch(recurringBillsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hóa đơn định kỳ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const RecurringBillForm(),
              );
            },
          ),
        ],
      ),
      body: recurringBillsAsync.when(
        data: (bills) {
          if (bills.isEmpty) {
            return const Center(
              child: Text('Chưa có hóa đơn định kỳ nào'),
            );
          }

          return ListView.builder(
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index];
              return Dismissible(
                key: Key(bill.id.toString()),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  ref
                      .read(recurringBillsProvider.notifier)
                      .deleteRecurringBill(bill.id!);
                },
                child: ListTile(
                  title: Text(bill.title),
                  subtitle: Text(
                    '${bill.amount.toStringAsFixed(0)} VND - Ngày ${bill.dayOfMonth} hàng tháng',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (bill.lastPaidDate != null)
                        const Icon(Icons.check_circle, color: Colors.green),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => RecurringBillForm(bill: bill),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    if (bill.lastPaidDate == null) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Đánh dấu đã thanh toán?'),
                          content:
                              Text('Bạn đã thanh toán hóa đơn ${bill.title}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () {
                                ref
                                    .read(recurringBillsProvider.notifier)
                                    .markAsPaid(bill);
                                Navigator.pop(context);
                              },
                              child: const Text('Xác nhận'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Lỗi: $error'),
        ),
      ),
    );
  }
}

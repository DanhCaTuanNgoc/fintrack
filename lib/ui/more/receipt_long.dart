import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/database/database_helper.dart';
import '../../providers/currency_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../data/models/transaction.dart';
import '../../providers/notifications_provider.dart';

// Provider để quản lý danh sách hóa đơn định kỳ
final periodicInvoicesProvider =
    StateNotifierProvider<PeriodicInvoicesNotifier, List<PeriodicInvoice>>(
        (ref) {
  return PeriodicInvoicesNotifier();
});

class PeriodicInvoice {
  final String id;
  final String name;
  final double amount;
  final DateTime startDate;
  final String frequency; // daily, weekly, monthly, yearly
  final String category;
  final String description;
  final bool isPaid;
  final DateTime? lastPaidDate;
  final DateTime? nextDueDate;

  PeriodicInvoice({
    required this.id,
    required this.name,
    required this.amount,
    required this.startDate,
    required this.frequency,
    required this.category,
    required this.description,
    this.isPaid = false,
    this.lastPaidDate,
    this.nextDueDate,
  });

  PeriodicInvoice copyWith({
    String? id,
    String? name,
    double? amount,
    DateTime? startDate,
    String? frequency,
    String? category,
    String? description,
    bool? isPaid,
    DateTime? lastPaidDate,
    DateTime? nextDueDate,
  }) {
    return PeriodicInvoice(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      startDate: startDate ?? this.startDate,
      frequency: frequency ?? this.frequency,
      category: category ?? this.category,
      description: description ?? this.description,
      isPaid: isPaid ?? this.isPaid,
      lastPaidDate: lastPaidDate ?? this.lastPaidDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
    );
  }

  DateTime calculateNextDueDate() {
    final now = DateTime.now();
    if (lastPaidDate == null) {
      return startDate;
    }

    switch (frequency) {
      case 'daily':
        // Ngày tiếp theo, bắt đầu từ 00:00
        return DateTime(
          lastPaidDate!.year,
          lastPaidDate!.month,
          lastPaidDate!.day + 1,
        );
      case 'weekly':
        // Tuần tiếp theo, bắt đầu từ thứ 2
        final daysUntilMonday = (8 - lastPaidDate!.weekday) % 7;
        return DateTime(
          lastPaidDate!.year,
          lastPaidDate!.month,
          lastPaidDate!.day + daysUntilMonday,
        );
      case 'monthly':
        // Tháng tiếp theo, ngày 1
        return DateTime(
          lastPaidDate!.year,
          lastPaidDate!.month + 1,
          1,
        );
      case 'yearly':
        // Năm tiếp theo, ngày 1 tháng 1
        return DateTime(
          lastPaidDate!.year + 1,
          1,
          1,
        );
      default:
        return lastPaidDate!;
    }
  }

  bool isOverdue() {
    if (isPaid) return false;
    final nextDue = nextDueDate ?? calculateNextDueDate();
    final now = DateTime.now();

    // So sánh chỉ ngày, tháng, năm
    return now.year > nextDue.year ||
        (now.year == nextDue.year && now.month > nextDue.month) ||
        (now.year == nextDue.year &&
            now.month == nextDue.month &&
            now.day > nextDue.day);
  }
}

class PeriodicInvoicesNotifier extends StateNotifier<List<PeriodicInvoice>> {
  PeriodicInvoicesNotifier() : super([]) {
    // Khởi tạo timer để kiểm tra và làm mới hóa đơn
    _initializeAutoRenewal();
  }

  void _initializeAutoRenewal() {
    // Kiểm tra mỗi ngày
    Future.delayed(const Duration(days: 1), () {
      _checkAndRenewInvoices();
      _initializeAutoRenewal(); // Lặp lại
    });
  }

  void _checkAndRenewInvoices() {
    final now = DateTime.now();
    state = state.map((invoice) {
      if (invoice.isPaid && invoice.nextDueDate != null) {
        final nextDue = invoice.nextDueDate!;

        // Kiểm tra xem đã qua ngày đến hạn chưa
        bool shouldRenew = false;
        switch (invoice.frequency) {
          case 'daily':
            shouldRenew = now.day > nextDue.day ||
                now.month > nextDue.month ||
                now.year > nextDue.year;
            break;
          case 'weekly':
            // Kiểm tra xem đã sang tuần mới chưa
            shouldRenew = now.isAfter(nextDue) && now.weekday == 1; // Thứ 2
            break;
          case 'monthly':
            // Kiểm tra xem đã sang tháng mới chưa
            shouldRenew = now.month > nextDue.month || now.year > nextDue.year;
            break;
          case 'yearly':
            // Kiểm tra xem đã sang năm mới chưa
            shouldRenew = now.year > nextDue.year;
            break;
        }

        if (shouldRenew) {
          // Tạo hóa đơn mới
          final newInvoice = invoice.copyWith(
            isPaid: false,
            lastPaidDate: null,
            nextDueDate: invoice.calculateNextDueDate(),
          );

          return newInvoice;
        }
      }
      return invoice;
    }).toList();
  }

  void addInvoice(PeriodicInvoice invoice) {
    final nextDueDate = invoice.calculateNextDueDate();
    state = [...state, invoice.copyWith(nextDueDate: nextDueDate)];
  }

  void removeInvoice(String id) {
    state = state.where((invoice) => invoice.id != id).toList();
  }

  void markAsPaid(String id) {
    state = state.map((invoice) {
      if (invoice.id == id) {
        final nextDueDate = invoice.calculateNextDueDate();
        return invoice.copyWith(
          isPaid: true,
          lastPaidDate: DateTime.now(),
          nextDueDate: nextDueDate,
        );
      }
      return invoice;
    }).toList();
  }
}

class ReceiptLongScreen extends ConsumerStatefulWidget {
  const ReceiptLongScreen({super.key});

  @override
  ConsumerState<ReceiptLongScreen> createState() => _ReceiptLongScreenState();
}

class _ReceiptLongScreenState extends ConsumerState<ReceiptLongScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _expenseCategories = [];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final expenseCats = await _dbHelper.getCategoriesByType('expense');
    setState(() {
      _expenseCategories = expenseCats;
    });
  }

  void _checkAndNotifyInvoices() {
    final invoices = ref.read(periodicInvoicesProvider);
    final now = DateTime.now();

    for (final invoice in invoices) {
      if (!invoice.isPaid && invoice.nextDueDate != null) {
        final nextDue = invoice.nextDueDate!;
        if (now.isAfter(nextDue)) {
          // Thêm thông báo cho hóa đơn quá hạn
          ref.read(notificationsProvider.notifier).addInvoiceDueNotification(
                invoice.name,
                invoice.amount,
                nextDue,
              );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoices = ref.watch(periodicInvoicesProvider);

    // Kiểm tra và thông báo hóa đơn đến hạn
    _checkAndNotifyInvoices();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hóa đơn định kỳ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF2D3142),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: invoices.isEmpty
                ? const Center(
                    child: Text(
                      'Chưa có hóa đơn định kỳ nào',
                      style: TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: invoices.length,
                    itemBuilder: (context, index) {
                      final invoice = invoices[index];
                      return _buildInvoiceCard(context, invoice);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddInvoiceDialog(context),
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, PeriodicInvoice invoice) {
    final isOverdue = invoice.isOverdue();
    final nextDueDate = invoice.nextDueDate ?? invoice.calculateNextDueDate();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  invoice.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                Row(
                  children: [
                    if (!invoice.isPaid)
                      ElevatedButton(
                        onPressed: () async {
                          // Lấy category ID từ tên danh mục
                          final categoryData = _expenseCategories.firstWhere(
                            (cat) => cat['name'] == invoice.category,
                          );

                          // Tạo giao dịch mới
                          final transactionNotifier = ref.read(
                            transactionsProvider.notifier,
                          );

                          await transactionNotifier.createTransaction(
                            amount: invoice.amount,
                            note: 'Thanh toán ${invoice.name}',
                            type: 'expense',
                            categoryId: categoryData['id'],
                            bookId: 1,
                            userId: 1,
                          );

                          // Đánh dấu hóa đơn đã thanh toán
                          ref
                              .read(periodicInvoicesProvider.notifier)
                              .markAsPaid(invoice.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isOverdue ? Colors.red : const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isOverdue ? 'Quá hạn' : 'Thanh toán',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Xác nhận xóa'),
                              content: const Text(
                                  'Bạn có chắc chắn muốn xóa hóa đơn này?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref
                                        .read(periodicInvoicesProvider.notifier)
                                        .removeInvoice(invoice.id);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Xóa',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Số tiền: ${formatCurrency(invoice.amount, ref.watch(currencyProvider))}',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tần suất: ${_getFrequencyText(invoice.frequency)}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9E9E9E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Danh mục: ${invoice.category}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9E9E9E),
              ),
            ),
            if (invoice.isPaid) ...[
              const SizedBox(height: 4),
              Text(
                'Đã thanh toán: ${DateFormat('dd/MM/yyyy').format(invoice.lastPaidDate!)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'Hạn thanh toán tiếp: ${DateFormat('dd/MM/yyyy').format(nextDueDate)}',
              style: TextStyle(
                fontSize: 14,
                color: isOverdue ? Colors.red : const Color(0xFF9E9E9E),
                fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFrequencyText(String frequency) {
    switch (frequency) {
      case 'daily':
        return 'Hàng ngày';
      case 'weekly':
        return 'Hàng tuần';
      case 'monthly':
        return 'Hàng tháng';
      case 'yearly':
        return 'Hàng năm';
      default:
        return frequency;
    }
  }

  void _showAddInvoiceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedFrequency = 'monthly';
    String? selectedCategory;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const Text(
                          'Thêm hóa đơn định kỳ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Tên hóa đơn',
                            labelStyle: const TextStyle(
                              color: Color(0xFF6C63FF),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF6C63FF),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: amountController,
                          decoration: InputDecoration(
                            labelText: 'Số tiền',
                            labelStyle: const TextStyle(
                              color: Color(0xFF6C63FF),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF6C63FF),
                                width: 2,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedFrequency,
                          decoration: InputDecoration(
                            labelText: 'Tần suất',
                            labelStyle: const TextStyle(
                              color: Color(0xFF6C63FF),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF6C63FF),
                                width: 2,
                              ),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'daily', child: Text('Hàng ngày')),
                            DropdownMenuItem(
                                value: 'weekly', child: Text('Hàng tuần')),
                            DropdownMenuItem(
                                value: 'monthly', child: Text('Hàng tháng')),
                            DropdownMenuItem(
                                value: 'yearly', child: Text('Hàng năm')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() {
                                selectedFrequency = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Danh mục',
                            labelStyle: const TextStyle(
                              color: Color(0xFF6C63FF),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF6C63FF),
                                width: 2,
                              ),
                            ),
                          ),
                          items: _expenseCategories
                              .map<DropdownMenuItem<String>>(
                                (category) => DropdownMenuItem<String>(
                                  value: category['name'],
                                  child: Row(
                                    children: [
                                      Text(category['icon']),
                                      const SizedBox(width: 8),
                                      Text(category['name']),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setModalState(() {
                              selectedCategory = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: 'chi tiết',
                            labelStyle: const TextStyle(
                              color: Color(0xFF6C63FF),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF6C63FF),
                                width: 2,
                              ),
                            ),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (nameController.text.isNotEmpty &&
                                  amountController.text.isNotEmpty &&
                                  selectedCategory != null) {
                                final newInvoice = PeriodicInvoice(
                                  id: DateTime.now().toString(),
                                  name: nameController.text,
                                  amount: double.parse(amountController.text),
                                  startDate: DateTime.now(),
                                  frequency: selectedFrequency,
                                  category: selectedCategory!,
                                  description: descriptionController.text,
                                );

                                ref
                                    .read(periodicInvoicesProvider.notifier)
                                    .addInvoice(newInvoice);
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Thêm',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

String formatCurrency(double amount, CurrencyType currency) {
  final formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: currency.symbol,
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

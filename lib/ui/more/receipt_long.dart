import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/database/database_helper.dart';
import '../../providers/currency_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../data/models/transaction.dart';
import '../../providers/notifications_provider.dart';
import 'package:flutter/scheduler.dart';
import '../../data/models/periodic_invoice.dart';

// Provider để quản lý danh sách hóa đơn định kỳ
final periodicInvoicesProvider =
    StateNotifierProvider<PeriodicInvoicesNotifier, List<PeriodicInvoice>>(
        (ref) {
  return PeriodicInvoicesNotifier();
});

class PeriodicInvoicesNotifier extends StateNotifier<List<PeriodicInvoice>> {
  PeriodicInvoicesNotifier() : super([]);

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
    // Delay the notification check until after the build phase
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _checkAndNotifyInvoices();
    });
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
        final isDueOrOverdue = now.year > nextDue.year ||
            (now.year == nextDue.year && now.month > nextDue.month) ||
            (now.year == nextDue.year &&
                now.month == nextDue.month &&
                now.day >= nextDue.day);

        if (isDueOrOverdue) {
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
    // _checkAndNotifyInvoices(); // REMOVED FROM HERE

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
                              // Kiểm tra dữ liệu đầu vào
                              if (nameController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Vui lòng nhập tên hóa đơn'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              if (amountController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Vui lòng nhập số tiền'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              if (selectedCategory == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Vui lòng chọn danh mục'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              // Parse số tiền
                              double amount;
                              try {
                                amount = double.parse(
                                    amountController.text.replaceAll(',', ''));
                                if (amount <= 0) {
                                  throw FormatException(
                                      'Số tiền phải lớn hơn 0');
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Số tiền không hợp lệ'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              try {
                                final newInvoice = PeriodicInvoice(
                                  id: DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  name: nameController.text.trim(),
                                  amount: amount,
                                  startDate: DateTime.now(),
                                  frequency: selectedFrequency,
                                  category: selectedCategory!,
                                  description:
                                      descriptionController.text.trim(),
                                );

                                ref
                                    .read(periodicInvoicesProvider.notifier)
                                    .addInvoice(newInvoice);
                                Navigator.pop(context);

                                // Thông báo thành công
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Đã thêm hóa đơn định kỳ thành công'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Lỗi khi tạo hóa đơn: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
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

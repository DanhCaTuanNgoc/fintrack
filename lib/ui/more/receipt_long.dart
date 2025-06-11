import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  PeriodicInvoice({
    required this.id,
    required this.name,
    required this.amount,
    required this.startDate,
    required this.frequency,
    required this.category,
    required this.description,
  });
}

class PeriodicInvoicesNotifier extends StateNotifier<List<PeriodicInvoice>> {
  PeriodicInvoicesNotifier() : super([]);

  void addInvoice(PeriodicInvoice invoice) {
    state = [...state, invoice];
  }

  void removeInvoice(String id) {
    state = state.where((invoice) => invoice.id != id).toList();
  }
}

class ReceiptLongScreen extends ConsumerWidget {
  const ReceiptLongScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(periodicInvoicesProvider);

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
        onPressed: () => _showAddInvoiceDialog(context, ref),
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, PeriodicInvoice invoice) {
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
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    // TODO: Implement delete functionality
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Số tiền: ${invoice.amount.toStringAsFixed(0)} VND',
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

  void _showAddInvoiceDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final categoryController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedFrequency = 'monthly';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Thêm hóa đơn định kỳ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3142),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên hóa đơn',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Số tiền',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedFrequency,
                decoration: const InputDecoration(
                  labelText: 'Tần suất',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Hàng ngày')),
                  DropdownMenuItem(value: 'weekly', child: Text('Hàng tuần')),
                  DropdownMenuItem(value: 'monthly', child: Text('Hàng tháng')),
                  DropdownMenuItem(value: 'yearly', child: Text('Hàng năm')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedFrequency = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  amountController.text.isNotEmpty) {
                final newInvoice = PeriodicInvoice(
                  id: DateTime.now().toString(),
                  name: nameController.text,
                  amount: double.parse(amountController.text),
                  startDate: DateTime.now(),
                  frequency: selectedFrequency,
                  category: categoryController.text,
                  description: descriptionController.text,
                );
                ref
                    .read(periodicInvoicesProvider.notifier)
                    .addInvoice(newInvoice);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}

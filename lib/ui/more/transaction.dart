import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/book.dart';
import '../../providers/more/transaction_provider.dart';
import '../../providers/currency_provider.dart';
import '../more.dart'; // Import để lấy backgroundColorProvider

// Định nghĩa enum cho các loại giao dịch
enum TransactionType { income, expense }

class TransactionScreen extends ConsumerStatefulWidget {
  final Book book;
  final String? initialWalletId;

  const TransactionScreen({
    super.key,
    required this.book,
    this.initialWalletId,
  });

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String? selectedWalletId;
  DateTime selectedDate = DateTime.now();
  TransactionType transactionType = TransactionType.income;

  @override
  void initState() {
    super.initState();
    selectedWalletId = widget.initialWalletId;
  }

  @override
  Widget build(BuildContext context) {
    final transactionNotifier = ref.watch(transactionsProvider.notifier);
    final currencyNotifier = ref.read(currencyProvider.notifier);
    final currentCurrency = ref.watch(currencyProvider);

    // ... existing code ...

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Transaction',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: GestureDetector(
          // ... existing code ...
          ),
    );
  }

  // ... existing code ...
}

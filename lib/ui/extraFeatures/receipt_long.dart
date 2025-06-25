import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database_helper.dart';
import '../../providers/providers_barrel.dart';
import 'package:flutter/scheduler.dart';
import '../../data/models/more/periodic_invoice.dart';
import 'package:intl/intl.dart';

class ReceiptLong extends ConsumerStatefulWidget {
  const ReceiptLong({super.key});

  @override
  ConsumerState<ReceiptLong> createState() => _ReceiptLongState();
}

class _ReceiptLongState extends ConsumerState<ReceiptLong> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> receipLong = [];
  List<Map<String, dynamic>> books = [];
  Map<String, dynamic>? selectedBook;

  // State cho bộ lọc
  int? _selectedBookFilterId;
  String? _selectedCategoryFilter;
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadBooks();
    // Khi truy cập ReceiptLong, tự động làm mới trạng thái hóa đơn định kỳ
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _refreshPeriodicInvoices();
    });

    // Thêm listener để tự động lọc khi người dùng nhập
    _minAmountController.addListener(() => setState(() {}));
    _maxAmountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final expenseCats = await _dbHelper.getCategoriesByType('expense');
    setState(() {
      receipLong = expenseCats;
    });
  }

  Future<void> _loadBooks() async {
    final userBooks = await _dbHelper.getBooksByUser(1); // user ID = 1
    setState(() {
      books = userBooks;
      if (books.isNotEmpty) {
        selectedBook = books.first;
      }
    });
  }

  // Hàm làm mới trạng thái hóa đơn định kỳ nếu đã đến hạn
  Future<void> _refreshPeriodicInvoices() async {
    final notifier = ref.read(periodicInvoicesProvider.notifier);
    await notifier.refreshPeriodicInvoices();
  }

  void _clearFilters() {
    setState(() {
      _selectedBookFilterId = null;
      _selectedCategoryFilter = null;
      _minAmountController.clear();
      _maxAmountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final allInvoices = ref.watch(periodicInvoicesProvider);
    final themeColor = ref.watch(themeColorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hóa đơn định kỳ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: themeColor,
        elevation: 0,
        leading: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        titleSpacing: 0,
      ),
      body: ref.watch(periodicInvoicesProvider).when(
            data: (allInvoices) {
              // Áp dụng bộ lọc
              final filteredInvoices = allInvoices.where((invoice) {
                // Lọc theo sổ
                final bookMatch = _selectedBookFilterId == null ||
                    invoice.bookId == _selectedBookFilterId;

                // Lọc theo danh mục
                final categoryMatch = _selectedCategoryFilter == null ||
                    invoice.category == _selectedCategoryFilter;

                // Lọc theo khoản tiền
                final minAmount = double.tryParse(_minAmountController.text);
                final maxAmount = double.tryParse(_maxAmountController.text);
                final amountMatch =
                    (minAmount == null || invoice.amount >= minAmount) &&
                        (maxAmount == null || invoice.amount <= maxAmount);

                return bookMatch && categoryMatch && amountMatch;
              }).toList();

              return Column(
                children: [
                  _buildFilterBar(),
                  Expanded(
                    child: filteredInvoices.isEmpty
                        ? const Center(
                            child: Text(
                              'Chưa có hóa đơn định kỳ nào',
                              style: TextStyle(
                                color: Color(0xFF9E9E9E),
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            children: [
                              // Hiển thị section hóa đơn vừa làm mới
                              if (filteredInvoices.isNotEmpty) ...[
                                // Duyệt và hiển thị từng hóa đơn vừa làm mới
                                ...filteredInvoices.map((invoice) =>
                                    _buildInvoiceCard(context, invoice)),
                                const SizedBox(height: 20),
                              ],
                            ],
                          ),
                  ),
                  // Nút thêm hóa đơn mới
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _showAddInvoiceDialog(context, themeColor);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Tạo hóa đơn mới',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => Center(
              child: CircularProgressIndicator(
                color: themeColor,
              ),
            ),
            error: (error, stackTrace) => Center(
              child: Text('Đã xảy ra lỗi: $error'),
            ),
          ),
    );
  }

  Widget _buildFilterBar() {
    final themeColor = ref.watch(themeColorProvider);
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Icon(Icons.filter_list, color: themeColor),
        title: const Text(
          'Bộ lọc',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF2D3142),
          ),
        ),
        shape: const Border(),
        collapsedShape: const Border(),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedBookFilterId,
                            hint: const Text(
                              'Tất cả sổ',
                              style: TextStyle(fontSize: 14),
                            ),
                            isExpanded: true,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            items: [
                              const DropdownMenuItem<int>(
                                value: null,
                                child: Text(
                                  'Tất cả sổ',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              ...books
                                  .map<DropdownMenuItem<int>>(
                                      (book) => DropdownMenuItem(
                                            value: book['id'],
                                            child: Text(book['name']),
                                          ))
                                  .toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedBookFilterId = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategoryFilter,
                            hint: const Text(
                              'Tất cả danh mục',
                              style: TextStyle(fontSize: 14),
                            ),
                            isExpanded: true,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text(
                                  'Tất cả danh mục',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              ...receipLong
                                  .map<DropdownMenuItem<String>>(
                                    (category) => DropdownMenuItem<String>(
                                      value: category['name'],
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(category['icon']),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              category['name'],
                                              style:
                                                  const TextStyle(fontSize: 13),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCategoryFilter = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minAmountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Số tiền tối thiểu',
                          labelStyle: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: themeColor, width: 2),
                          ),
                          prefixIcon:
                              Icon(Icons.attach_money, color: themeColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _maxAmountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Số tiền tối đa',
                          labelStyle: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: themeColor, width: 2),
                          ),
                          prefixIcon:
                              Icon(Icons.attach_money, color: themeColor),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear),
                    label: const Text('Xóa bộ lọc'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, PeriodicInvoice invoice) {
    final isOverdue = invoice.isOverdue();
    final nextDueDate = invoice.nextDueDate ?? invoice.calculateNextDueDate();
    final themeColor = ref.watch(themeColorProvider);

    // Tìm tên sổ chi tiêu dựa trên bookId
    String bookName = 'Chưa có sổ';
    if (invoice.bookId != null && books.isNotEmpty) {
      try {
        final book = books.firstWhere((b) => b['id'] == invoice.bookId);
        bookName = book['name'];
      } catch (e) {
        bookName = 'Sổ không tồn tại';
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(60),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(60),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: themeColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                ' ${invoice.name}',
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A1A),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isOverdue
                                    ? Colors.red.withOpacity(0.1)
                                    : invoice.isPaid
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isOverdue
                                    ? 'Quá hạn'
                                    : invoice.isPaid
                                        ? 'Đã thanh toán'
                                        : 'Chờ thanh toán',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isOverdue
                                      ? Colors.red
                                      : invoice.isPaid
                                          ? Colors.green
                                          : Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Amount section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Book name section
                    Icon(
                      Icons.book,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sổ chi tiêu',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            bookName ?? 'Không có tên sách',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Amount section
                    Icon(
                      Icons.attach_money,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Số tiền',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatCurrency(
                                invoice.amount, ref.watch(currencyProvider)),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Details section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tần suất',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getFrequencyText(invoice.frequency),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: themeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Danh mục',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              invoice.category,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Payment status section
              if (invoice.isPaid) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Đã thanh toán',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('dd/MM/yyyy')
                                  .format(invoice.lastPaidDate!),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Action buttons
              const SizedBox(height: 20),
              Row(
                children: [
                  if (!invoice.isPaid)
                    Expanded(
                      child: ElevatedButton(
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
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      ref
                                          .read(
                                              periodicInvoicesProvider.notifier)
                                          .removePeriodicInvoice(invoice.id);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      'Xóa',
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255)),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Xóa',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  const SizedBox(
                    width: 10,
                  ),
                  if (!invoice.isPaid)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final categoryData = receipLong.firstWhere(
                              (cat) => cat['name'] == invoice.category,
                            );

                            final bookId = invoice.bookId ?? 1;

                            final transactionNotifier = ref.read(
                              transactionsProvider.notifier,
                            );

                            await transactionNotifier.createTransaction(
                              amount: invoice.amount,
                              note: 'Thanh toán ${invoice.name}',
                              type: 'expense',
                              categoryId: categoryData['id'],
                              bookId: bookId,
                              userId: 1,
                            );

                            await ref
                                .read(periodicInvoicesProvider.notifier)
                                .markPeriodicInvoiceAsPaid(invoice.id);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã thanh toán ${invoice.name}'),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Lỗi khi thanh toán: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isOverdue ? Colors.red : themeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isOverdue ? 'Thanh toán ngay' : 'Thanh toán',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
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

  void _showAddInvoiceDialog(BuildContext context, Color themeColor) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedFrequency = 'monthly';
    String? selectedCategory;
    Map<String, dynamic>? selectedBookForInvoice = selectedBook;

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
                          'Tạo hóa đơn định kỳ',
                          style: TextStyle(
                            fontSize: 20,
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
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: themeColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: themeColor,
                                width: 2,
                              ),
                            ),
                            prefixIcon: Icon(Icons.receipt, color: themeColor),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: amountController,
                          decoration: InputDecoration(
                            labelText: 'Số tiền',
                            labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: themeColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: themeColor,
                                width: 2,
                              ),
                            ),
                            prefixIcon:
                                Icon(Icons.attach_money, color: themeColor),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedFrequency,
                                decoration: InputDecoration(
                                  labelText: 'Tần suất',
                                  labelStyle: TextStyle(
                                    color: themeColor,
                                    fontSize: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: themeColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: themeColor,
                                      width: 2,
                                    ),
                                  ),
                                  prefixIcon:
                                      Icon(Icons.schedule, color: themeColor),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'daily',
                                      child: Text(
                                        'Hàng ngày',
                                        style: TextStyle(fontSize: 13),
                                      )),
                                  DropdownMenuItem(
                                      value: 'weekly',
                                      child: Text(
                                        'Hàng tuần',
                                        style: TextStyle(fontSize: 13),
                                      )),
                                  DropdownMenuItem(
                                      value: 'monthly',
                                      child: Text(
                                        'Hàng tháng',
                                        style: TextStyle(fontSize: 13),
                                      )),
                                  DropdownMenuItem(
                                      value: 'yearly',
                                      child: Text(
                                        'Hàng năm',
                                        style: TextStyle(fontSize: 13),
                                      )),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setModalState(() {
                                      selectedFrequency = value;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedCategory,
                                decoration: InputDecoration(
                                  labelText: 'Danh mục',
                                  labelStyle: TextStyle(
                                    color: themeColor,
                                    fontSize: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: themeColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: themeColor,
                                      width: 2,
                                    ),
                                  ),
                                  prefixIcon:
                                      Icon(Icons.category, color: themeColor),
                                ),
                                items: receipLong
                                    .map<DropdownMenuItem<String>>(
                                      (category) => DropdownMenuItem<String>(
                                        value: category['name'],
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(category['icon']),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                category['name'],
                                                style: const TextStyle(
                                                    fontSize: 13),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
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
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: selectedBookForInvoice?['id'],
                          decoration: InputDecoration(
                            labelText: 'Sổ chi tiêu',
                            labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: themeColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: themeColor,
                                width: 2,
                              ),
                            ),
                            prefixIcon: Icon(Icons.book, color: themeColor),
                          ),
                          items: books
                              .map<DropdownMenuItem<int>>(
                                (book) => DropdownMenuItem<int>(
                                  value: book['id'],
                                  child: Text(book['name']),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() {
                                selectedBookForInvoice =
                                    books.firstWhere((b) => b['id'] == value);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Chi tiết',
                            labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: themeColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: themeColor,
                                width: 2,
                              ),
                            ),
                            prefixIcon:
                                Icon(Icons.description, color: themeColor),
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
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

                              if (selectedBookForInvoice == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Vui lòng chọn sổ chi tiêu'),
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
                                  throw const FormatException(
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
                                  bookId: selectedBookForInvoice!['id'],
                                );

                                await ref
                                    .read(periodicInvoicesProvider.notifier)
                                    .addPeriodicInvoice(newInvoice);
                                Navigator.pop(context);

                                // Thông báo thành công
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Đã thêm hóa đơn định kỳ thành công vào sổ ${selectedBookForInvoice!['name']}'),
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
                              backgroundColor: themeColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Tạo hóa đơn',
                              style: TextStyle(
                                fontSize: 18,
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

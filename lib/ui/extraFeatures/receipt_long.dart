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

<<<<<<< HEAD
  Future<void> _loadBooks() async {
    final userBooks = await _dbHelper.getBooksByUser(1); // user ID = 1
    setState(() {
      books = userBooks;
      if (books.isNotEmpty) {
        selectedBook = books.first;
      }
    });
  }

=======
>>>>>>> develop
  // Hàm làm mới trạng thái hóa đơn định kỳ nếu đã đến hạn
  Future<void> _refreshPeriodicInvoices() async {
    final notifier = ref.read(periodicInvoicesProvider.notifier);
    await notifier.refreshPeriodicInvoices();
<<<<<<< HEAD
  }

  void _clearFilters() {
    setState(() {
      _selectedBookFilterId = null;
      _selectedCategoryFilter = null;
      _minAmountController.clear();
      _maxAmountController.clear();
    });
=======
>>>>>>> develop
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final allInvoices = ref.watch(periodicInvoicesProvider);
=======
    // Lấy danh sách hóa đơn định kỳ từ provider
    final invoices = ref.watch(periodicInvoicesProvider);
    final now = DateTime.now();
    // Lọc các hóa đơn vừa làm mới: chưa thanh toán và đã đến hạn
    final refreshedInvoices = invoices.where((invoice) {
      final nextDue = invoice.nextDueDate ?? invoice.calculateNextDueDate();
      return !invoice.isPaid &&
          (now.isAfter(nextDue) ||
              (now.year == nextDue.year &&
                  now.month == nextDue.month &&
                  now.day == nextDue.day));
    }).toList();
    // Lọc các hóa đơn còn lại
    final otherInvoices = invoices
        .where((invoice) => !refreshedInvoices.contains(invoice))
        .toList();
>>>>>>> develop
    final themeColor = ref.watch(themeColorProvider);

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
      final amountMatch = (minAmount == null || invoice.amount >= minAmount) &&
          (maxAmount == null || invoice.amount <= maxAmount);

      return bookMatch && categoryMatch && amountMatch;
    }).toList();

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
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
<<<<<<< HEAD
            child: filteredInvoices.isEmpty
=======
            child: invoices.isEmpty
>>>>>>> develop
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
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Hiển thị section hóa đơn vừa làm mới
<<<<<<< HEAD
                      if (filteredInvoices.isNotEmpty) ...[
=======
                      if (refreshedInvoices.isNotEmpty) ...[
>>>>>>> develop
                        // Duyệt và hiển thị từng hóa đơn vừa làm mới
                        ...filteredInvoices.map(
                            (invoice) => _buildInvoiceCard(context, invoice)),
                        const Divider(height: 32),
                      ],
<<<<<<< HEAD
=======
                      // Hiển thị các hóa đơn còn lại
                      if (otherInvoices.isNotEmpty) ...[
                        ...otherInvoices.map(
                            (invoice) => _buildInvoiceCard(context, invoice)),
                      ],
>>>>>>> develop
                    ],
                  ),
          ),
        ],
      ),
      // Nút thêm hóa đơn mới
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddInvoiceDialog(context),
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ExpansionTile(
        title: const Text('Bộ lọc'),
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedBookFilterId,
                  decoration: const InputDecoration(labelText: 'Sổ chi tiêu'),
                  items: books
                      .map<DropdownMenuItem<int>>((book) => DropdownMenuItem(
                            value: book['id'],
                            child: Text(book['name']),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBookFilterId = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategoryFilter,
                  decoration: const InputDecoration(labelText: 'Danh mục'),
                  items: receipLong
                      .map<DropdownMenuItem<String>>(
                          (category) => DropdownMenuItem(
                                value: category['name'],
                                child: Text(category['name']),
                              ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryFilter = value;
                    });
                  },
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
                  decoration: const InputDecoration(labelText: 'Tối thiểu'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _maxAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Tối đa'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _clearFilters,
            child: const Text('Xóa bộ lọc'),
          )
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, PeriodicInvoice invoice) {
    final isOverdue = invoice.isOverdue();
    final nextDueDate = invoice.nextDueDate ?? invoice.calculateNextDueDate();

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '$bookName: ${invoice.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    if (!invoice.isPaid)
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            // Lấy category ID từ tên danh mục
                            final categoryData = receipLong.firstWhere(
                              (cat) => cat['name'] == invoice.category,
                            );

                            // Sử dụng bookId từ hóa đơn
                            final bookId = invoice.bookId ??
                                1; // fallback nếu không có bookId

                            // Tạo giao dịch mới
                            final transactionNotifier = ref.read(
                              transactionsProvider.notifier,
                            );

<<<<<<< HEAD
                            await transactionNotifier.createTransaction(
                              amount: invoice.amount,
                              note: 'Thanh toán ${invoice.name}',
                              type: 'expense',
                              categoryId: categoryData['id'],
                              bookId: bookId,
                              userId: 1,
                            );

                            // Đánh dấu hóa đơn đã thanh toán
                            await ref
                                .read(periodicInvoicesProvider.notifier)
                                .markPeriodicInvoiceAsPaid(invoice.id);

                            // Thông báo thành công
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
=======
                          // Đánh dấu hóa đơn đã thanh toán
                          await ref
                              .read(periodicInvoicesProvider.notifier)
                              .markPeriodicInvoiceAsPaid(invoice.id);
>>>>>>> develop
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
                                        .removePeriodicInvoice(invoice.id);
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
                          items: receipLong
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
                        DropdownButtonFormField<int>(
                          value: selectedBookForInvoice?['id'],
                          decoration: InputDecoration(
                            labelText: 'Sổ chi tiêu',
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

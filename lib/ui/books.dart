import 'package:fintrack/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../data/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/number_pad.dart';
import '../data/models/book.dart';
import '../data/repositories/book_repository.dart';
import '../providers/book_provider.dart';

class Books extends ConsumerStatefulWidget {
  const Books({super.key});

  @override
  _BooksState createState() => _BooksState();
}

class _BooksState extends ConsumerState<Books>
    with SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late final BookRepository _bookRepository;
  String _amount = '';
  String _note = '';
  String? _selectedCategory;
  List<Map<String, dynamic>> _expenseCategories = [];
  List<Map<String, dynamic>> _incomeCategories = [];
  bool _isExpense = true;
  bool? _hasBooks;
  late TabController _tabController;

  // Calendar state
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _bookRepository = BookRepository(_dbHelper);
    _loadCategories();
    // _checkBooks();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Future<void> _checkBooks() async {
  //   final books = await _dbHelper.getBooks();
  //   setState(() {
  //     _hasBooks = books.isNotEmpty;
  //   });
  // }

  Future<void> _loadCategories() async {
    final expenseCats = await _dbHelper.getCategoriesByType('expense');
    final incomeCats = await _dbHelper.getCategoriesByType('income');
    setState(() {
      _expenseCategories = expenseCats;
      _incomeCategories = incomeCats;
    });
  }

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(booksProvider);
    final transactions = ref.watch(transactionsProvider);

    final totalAmount = transactions.when(
      data:
          (transactionsList) => transactionsList.fold(
            0.0,
            (sum, transaction) => sum + transaction.amount,
          ),
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );

    final totalIncome = transactions.when(
      data:
          (transactionsList) => transactionsList.fold(
            0.0,
            (sum, transaction) =>
                transaction.type == 'income' ? sum + transaction.amount : sum,
          ),
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );

    final totalExpense = transactions.when(
      data:
          (transactionsList) => transactionsList.fold(
            0.0,
            (sum, transaction) =>
                transaction.type == 'expense' ? sum + transaction.amount : sum,
          ),
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );

    return books.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (error, stack) =>
              Scaffold(body: Center(child: Text('Có lỗi xảy ra: $error'))),
      data: (books) {
        if (books.isEmpty) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              title: const Text(
                'Sổ chi tiêu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF2D3142),
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.book,
                          size: 64,
                          color: Color(0xFF6C63FF),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Chưa có sổ chi tiêu nào',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Hãy tạo sổ chi tiêu đầu tiên của bạn',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            _showCreateBookModal(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Tạo sổ chi tiêu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.search, color: Color(0xFF2D3142)),
              onPressed: () {
                // TODO: Handle search
              },
            ),
            centerTitle: true,
            title: TextButton.icon(
              onPressed: () {
                // TODO: Handle dropdown menu
              },
              icon: Text(
                books.first.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Color(0xFF2D3142),
                ),
              ),
              label: const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF2D3142),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF6C63FF),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF6C63FF),
              labelStyle: const TextStyle(fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt, size: 20),
                      SizedBox(width: 4),
                      Text('Hóa đơn'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, size: 20),
                      SizedBox(width: 4),
                      Text('Lịch'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab Hóa đơn
              Column(
                children: [
                  // Header với thông tin tổng quan
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF4A45B1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Toàn bộ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              '${totalExpense.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'Thu nhập',
                              '${totalIncome.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ',
                              Colors.white,
                            ),
                            _buildStatItem(
                              'Chi tiêu',
                              '${totalExpense.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ',
                              Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Danh sách các đầu mục chi tiêu
                  Expanded(
                    child: transactions.when(
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (error, stack) =>
                              Center(child: Text('Error: $error')),
                      data:
                          (transactionsList) => ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: transactionsList.length,
                            itemBuilder: (context, index) {
                              final transaction = transactionsList[index];
                              return _buildExpenseItem(
                                title: transaction.note,
                                amount:
                                    '${transaction.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ',
                                time:
                                    transaction.date != null
                                        ? DateFormat(
                                          'HH:mm dd/MM/yyyy',
                                        ).format(transaction.date!)
                                        : '',
                                type: transaction.type,
                              );
                            },
                          ),
                    ),
                  ),
                ],
              ),
              // Tab Lịch
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      calendarFormat: _calendarFormat,
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarStyle: const CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: Color(0xFF6C63FF),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Color(0xFF6C63FF),
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: BoxDecoration(
                          color: Color(0xFF6C63FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _events[_selectedDay]?.length ?? 0,
                      itemBuilder: (context, index) {
                        final event = _events[_selectedDay]![index];
                        return _buildExpenseItem(
                          title: event['title'],
                          amount: event['amount'],
                          time: event['time'],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showAddExpenseModal(context, books.first); // Pass current book
            },
            backgroundColor: const Color(0xFF6C63FF),
            elevation: 4,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14, color: color.withOpacity(0.8)),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem({
    String? title,
    String? amount,
    String? time,
    String? type,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4A45B1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              type == 'income' ? Icons.savings : Icons.shopping_cart,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? 'Mua sắm',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time ?? 'Hôm nay, 14:30',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            (type == 'income' ? '+ ' : '- ') + (amount ?? '500,000 đ'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color:
                  type == 'income'
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFEF476F),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseModal(BuildContext context, Book currentBook) {
    // Update parameter
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Thêm giao dịch',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3142),
                              ),
                            ),
                            Row(
                              children: [
                                _buildTypeButton('Chi tiêu', true, setState),
                                const SizedBox(width: 8),
                                _buildTypeButton('Thu nhập', false, setState),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Ghi chú',
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
                          onChanged: (value) => _note = value,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _amount.isEmpty ? '0 đ' : '${_amount} đ',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3142),
                                ),
                              ),
                              const SizedBox(height: 16),
                              NumberPad(
                                onNumberTap: (number) {
                                  setState(() {
                                    _amount += number;
                                  });
                                },
                                onBackspaceTap: () {
                                  setState(() {
                                    if (_amount.isNotEmpty) {
                                      _amount = _amount.substring(
                                        0,
                                        _amount.length - 1,
                                      );
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
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
                          items:
                              (_isExpense
                                      ? _expenseCategories
                                      : _incomeCategories)
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
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_amount.isNotEmpty &&
                                  _selectedCategory != null) {
                                final transactionNotifier = ref.read(
                                  transactionsProvider.notifier,
                                );

                                // Get category ID from selected category name
                                final selectedCategoryData =
                                    _isExpense
                                        ? _expenseCategories.firstWhere(
                                          (cat) =>
                                              cat['name'] == _selectedCategory,
                                        )
                                        : _incomeCategories.firstWhere(
                                          (cat) =>
                                              cat['name'] == _selectedCategory,
                                        );

                                await transactionNotifier.createTransaction(
                                  amount: double.parse(_amount),
                                  note: _note,
                                  type: _isExpense ? 'expense' : 'income',
                                  categoryId: selectedCategoryData['id'],
                                  bookId:
                                      currentBook.id ??
                                      0, // Add null check with default value
                                  userId: 1,
                                );

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

  Widget _buildTypeButton(String text, bool isExpense, StateSetter setState) {
    final isSelected = _isExpense == isExpense;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpense = isExpense;
          _selectedCategory = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showCreateBookModal(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _bookNameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Tạo sổ chi tiêu mới',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _bookNameController,
                        decoration: InputDecoration(
                          labelText: 'Tên sổ chi tiêu',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.book),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên sổ chi tiêu';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final book = Book(
                            name: _bookNameController.text,
                            balance: 0.0,
                            userId: 1, // TODO: Get current user ID
                          );
                          await ref
                              .read(booksProvider.notifier)
                              .createBook(_bookNameController.text);
                          Navigator.pop(context);
                        } catch (e) {
                          // TODO: Show error message
                          print('Error creating book: $e');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Tạo sổ',
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
        );
      },
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Books'),
      backgroundColor: Colors.deepPurpleAccent,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

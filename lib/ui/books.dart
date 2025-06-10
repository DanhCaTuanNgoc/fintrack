import 'package:fintrack/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../data/database/database_helper.dart';
import 'components/number_pad.dart';
import '../data/models/book.dart';
import '../data/repositories/book_repository.dart';
import '../providers/book_provider.dart';
import '../providers/currency_provider.dart';

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
  int _selectedTabIndex = 0;

  // State để quản lý trạng thái mở rộng của mỗi ngày
  final Map<String, bool> _expandedDays = {};
  final Map<int, bool> _expandedTransactions = {};

  // Calendar state
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  // Thêm vào phần khai báo state
  List<Map<String, dynamic>> _categories = [];

  // Thêm vào phần khai báo state
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

  // Thêm vào phần khai báo state
  bool _isAmountVisible = true;

  // Thêm biến state cho date range filter
  DateTime? _startDate;
  DateTime? _endDate;

  IconData _getIconFromEmoji(String emoji) {
    return _iconMapping[emoji] ?? Icons.category;
  }

  @override
  void initState() {
    super.initState();
    // Lay du lieu bang Categories
    _loadCategories();
    // Tao bien TabController cho UI
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final expenseCats = await _dbHelper.getCategoriesByType('expense');
    final incomeCats = await _dbHelper.getCategoriesByType('income');
    final categories = await _dbHelper.getCategories();
    setState(() {
      _expenseCategories = expenseCats;
      _incomeCategories = incomeCats;
      _categories = categories;
    });
  }

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(booksProvider);
    final transactions = ref.watch(transactionsProvider);

    final totalAmount = transactions.when(
      data: (transactionsList) => transactionsList.fold(
        0.0,
        (sum, transaction) => sum + transaction.amount,
      ),
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );

    final totalIncome = transactions.when(
      data: (transactionsList) => transactionsList.fold(
        0.0,
        (sum, transaction) =>
            transaction.type == 'income' ? sum + transaction.amount : sum,
      ),
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );

    final totalExpense = transactions.when(
      data: (transactionsList) => transactionsList.fold(
        0.0,
        (sum, transaction) =>
            transaction.type == 'expense' ? sum + transaction.amount : sum,
      ),
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );

    // Tính toán balance (thu nhập - chi tiêu)
    final balance = totalIncome - totalExpense;
    final isNegative = balance < 0;

    return books.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
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
            toolbarHeight: 70,
            title: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          books.first.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFF2D3142),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF2D3142),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildTabButton('Hóa đơn', 0),
                      const SizedBox(width: 8),
                      _buildTabButton('Lịch', 1),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(), // Disable swipe
            children: [
              // Tab Hóa đơn
              Column(
                children: [
                  // Header với thông tin tổng quan
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Date range selector và nút ẩn/hiện
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.calendar_month,
                                    color: Colors.grey[600],
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    // Handle previous date range
                                  },
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final picked = await showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                      initialDateRange:
                                          _startDate != null && _endDate != null
                                              ? DateTimeRange(
                                                  start: _startDate!,
                                                  end: _endDate!)
                                              : null,
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _startDate = picked.start;
                                        _endDate = picked.end;
                                      });
                                    }
                                  },
                                  child: Text(
                                    _startDate != null && _endDate != null
                                        ? '${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}'
                                        : 'Chọn khoảng thời gian',
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                _isAmountVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey[600],
                                size: 24,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isAmountVisible = !_isAmountVisible;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 110,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: _buildStatItem(
                                    'Toàn bộ',
                                    balance.abs().toString(),
                                    isNegative
                                        ? const Color(0xFFFF5252)
                                        : const Color(0xFF4CAF50),
                                    showNegative: isNegative,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 110,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: _buildStatItem(
                                    'Thu nhập',
                                    totalIncome.toString(),
                                    const Color(0xFF4CAF50),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 110,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: _buildStatItem(
                                    'Chi tiêu',
                                    totalExpense.toString(),
                                    const Color(0xFFFF5252),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // const SizedBox(height: 16),
                        // Time range selector
                        // Container(
                        //   padding: const EdgeInsets.all(4),
                        //   decoration: BoxDecoration(
                        //     color: const Color(0xFFF5F5F5),
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //   // child: Row(
                        //   //   children: [
                        //   //     Expanded(
                        //   //       child: _buildTimeRangeButton(
                        //   //         'Hàng tuần',
                        //   //         isSelected: true,
                        //   //       ),
                        //   //     ),
                        //   //     Expanded(
                        //   //       child: _buildTimeRangeButton('Hàng tháng'),
                        //   //     ),
                        //   //     Expanded(
                        //   //       child: _buildTimeRangeButton('Hàng năm'),
                        //   //     ),
                        //   //   ],
                        //   // ),
                        // ),
                      ],
                    ),
                  ),
                  // Danh sách các đầu mục chi tiêu
                  Expanded(
                    child: transactions.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) =>
                          Center(child: Text('Error: $error')),
                      data: (transactionsList) {
                        // Lọc theo khoảng thời gian
                        final filteredTransactions =
                            (_startDate != null && _endDate != null)
                                ? transactionsList.where((transaction) {
                                    final date = transaction.date!;
                                    return !date.isBefore(_startDate!) &&
                                        !date.isAfter(_endDate!);
                                  }).toList()
                                : transactionsList;

                        // Nhóm giao dịch theo ngày
                        final groupedTransactions = <String, List<dynamic>>{};
                        final dailyExpenses = <String, double>{};

                        for (var transaction in filteredTransactions) {
                          final dateKey = DateFormat(
                            'dd/MM/yyyy',
                          ).format(transaction.date!);
                          if (!groupedTransactions.containsKey(dateKey)) {
                            groupedTransactions[dateKey] = [];
                            dailyExpenses[dateKey] = 0;
                          }
                          groupedTransactions[dateKey]!.add(transaction);
                          if (transaction.type == 'expense') {
                            dailyExpenses[dateKey] =
                                (dailyExpenses[dateKey] ?? 0) +
                                    transaction.amount;
                          }
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(6),
                          itemCount: groupedTransactions.length,
                          itemBuilder: (context, index) {
                            final dateKey = groupedTransactions.keys.elementAt(
                              index,
                            );
                            final transactions = groupedTransactions[dateKey]!;
                            final dayExpense = dailyExpenses[dateKey] ?? 0;

                            // Tính tổng thu nhập trong ngày
                            double dayIncome = 0;
                            for (var transaction in transactions) {
                              if (transaction.type == 'income') {
                                dayIncome += transaction.amount;
                              }
                            }

                            // Tính tổng theo ngày (thu - chi)
                            final dayTotal = dayIncome - dayExpense;

                            return _buildExpenseItem(
                              dateKey: dateKey,
                              transactions: transactions,
                              dayExpense: dayTotal,
                            );
                          },
                        );
                      },
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
                          dateKey: DateFormat(
                            'HH:mm dd/MM/yyyy',
                          ).format(event['date']),
                          transactions: event['transactions'],
                          dayExpense: event['amount'],
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

  Widget _buildTimeRangeButton(String text, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String amount,
    Color textColor, {
    bool showNegative = false,
  }) {
    final numberFormat = NumberFormat('#,###');
    final amountValue =
        double.tryParse(amount.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

    // Lấy đơn vị tiền tệ hiện tại
    final currencyType = ref.watch(currencyProvider);

    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isAmountVisible
                ? '${showNegative ? '-' : ''}${formatCurrency(amountValue, currencyType)}'
                : '•••••',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem({
    required String dateKey,
    required List<dynamic> transactions,
    required double dayExpense,
  }) {
    final isExpanded = _expandedDays[dateKey] ?? false;
    final numberFormat = NumberFormat('#,###');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header ngày
          InkWell(
            onTap: () {
              setState(() {
                _expandedDays[dateKey] = !isExpanded;
              });
            },
            splashFactory: NoSplash.splashFactory,
            hoverColor: Colors.transparent,
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
                      color: Colors.grey[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateKey,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Tổng: ${_isAmountVisible ? (dayExpense >= 0 ? '+' : '-') + formatCurrency(dayExpense.abs(), ref.watch(currencyProvider)) : '•••••'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          // Danh sách giao dịch
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: Column(
              children: transactions.map((transaction) {
                // Tìm category tương ứng
                final category = _categories.firstWhere(
                  (cat) => cat['id'] == transaction.categoryId,
                  orElse: () => {'icon': '🏷️', 'color': '0xFF6C63FF'},
                );

                // Chuyển đổi màu từ string sang Color
                final colorString = category['color'] ?? '0xFF6C63FF';
                final color = Color(int.parse(colorString));
                final bgColor = color.withOpacity(0.1);

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Icon từ category
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getIconFromEmoji(category['icon'] ?? '🏷️'),
                          color: color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Thông tin giao dịch
                      Expanded(
                        child: Text(
                          transaction.note,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Số tiền
                      Text(
                        '${transaction.type == 'expense' ? '-' : '+'}${_isAmountVisible ? formatCurrency(transaction.amount, ref.watch(currencyProvider)) : '•••••'}',
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
                                _amount.isEmpty
                                    ? '0 ${ref.watch(currencyProvider).symbol}'
                                    : '$_amount ${ref.watch(currencyProvider).symbol}',
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
                          items: (_isExpense
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
                                final selectedCategoryData = _isExpense
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
                                  bookId: currentBook.id ??
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

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6C63FF) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

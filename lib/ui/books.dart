import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../data/database/database_helper.dart';
import '../providers/providers_barrel.dart';
import './widget/widget_barrel.dart';
import '../data/models/models_barrel.dart';

class Books extends ConsumerStatefulWidget {
  const Books({super.key});

  @override
  _BooksState createState() => _BooksState();
}

class _BooksState extends ConsumerState<Books>
    with SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  String _amount = '';
  String _note = '';
  String? _selectedCategory;
  List<Map<String, dynamic>> _expenseCategories = [];
  List<Map<String, dynamic>> _incomeCategories = [];
  bool _isExpense = true;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  late TabController _tabController;
  int _selectedTabIndex = 0;

  // State để quản lý trạng thái mở rộng của mỗi ngày
  final Map<String, bool> _expandedDays = {};

  // Calendar state
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

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

  bool _isExpanded = false;
  late List<dynamic> _filteredTransactions = [];
  late double _dayExpense = 0.0;

  // Add this field to the class
  OverlayEntry? _overlayEntry;

  Widget _buildSkeletonLoading() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        toolbarHeight: 60,
        title: Container(
          width: 150,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 100,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              // Header skeleton
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 22,
                  horizontal: 20,
                ),
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 120,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatSkeleton(),
                        _buildStatSkeleton(),
                        _buildStatSkeleton(),
                      ],
                    ),
                  ],
                ),
              ),
              // Transaction list skeleton
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(6),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 80,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  width: 100,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatSkeleton() {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 80,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

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
    _overlayEntry?.remove();
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
    final currentBook = ref.watch(currentBookProvider);
    final transactions = ref.watch(transactionsProvider);
    final currencySymbol = ref.watch(currencyProvider);

    // Lấy màu nền hiện tại
    final themeColor = ref.watch(themeColorProvider);
    return books.when(
      loading: () => _buildSkeletonLoading(),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Có lỗi xảy ra: $error'))),
      data: (books) {
        if (books.isEmpty) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: themeColor,
              elevation: 0,
              toolbarHeight: 60,
              title: const Text(
                'Sổ chi tiêu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
            body: Container(
              decoration: BoxDecoration(color: themeColor),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.book,
                              size: 64,
                              color: themeColor,
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
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                _showCreateBookModal(context, themeColor);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
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
              ),
            ),
          );
        }

        return currentBook.when(
          loading: () => _buildSkeletonLoading(),
          error: (error, stack) => Scaffold(
            body: Center(child: Text('Có lỗi xảy ra: $error')),
          ),
          data: (currentBook) {
            if (currentBook == null ||
                !books.any((book) => book.id == currentBook.id)) {
              if (books.isNotEmpty) {
                ref
                    .read(currentBookProvider.notifier)
                    .setCurrentBook(books.first);
              }
              return _buildSkeletonLoading();
            }

            // Lọc transactions theo currentBook
            final filteredTransactions = transactions.when(
              data: (transactionsList) => transactionsList
                  .where((transaction) => transaction.bookId == currentBook.id)
                  .toList(),
              loading: () => [],
              error: (_, __) => [],
            );

            final totalAmount = filteredTransactions.fold(
              0.0,
              (sum, transaction) => sum + transaction.amount,
            );

            final totalIncome = filteredTransactions.fold(
              0.0,
              (sum, transaction) =>
                  transaction.type == 'income' ? sum + transaction.amount : sum,
            );

            final totalExpense = filteredTransactions.fold(
              0.0,
              (sum, transaction) => transaction.type == 'expense'
                  ? sum + transaction.amount
                  : sum,
            );

            // Tính toán balance (thu nhập - chi tiêu)
            final balance = totalIncome - totalExpense;
            final isNegative = balance < 0;

            return Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              appBar: AppBar(
                backgroundColor: themeColor,
                elevation: 0,
                toolbarHeight: 60,
                title: Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: Row(
                        children: [
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text(
                                currentBook.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                _showBookListScreen(context, themeColor);
                              },
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                width: 35,
                                height: 37,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.arrow_right_rounded,
                                  size: 35,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TabButton(
                            label: 'Hóa đơn',
                            index: 0,
                            selectedIndex: _selectedTabIndex,
                            themeColor: themeColor,
                            icon: Icons.receipt,
                            onTap: (i) {
                              _tabController.animateTo(i);
                              setState(() {
                                _selectedTabIndex = i;
                              });
                            },
                          ),
                          TabButton(
                            label: 'Lịch',
                            index: 1,
                            selectedIndex: _selectedTabIndex,
                            themeColor: themeColor,
                            icon: Icons.calendar_today,
                            onTap: (i) {
                              _tabController.animateTo(i);
                              setState(() {
                                _selectedTabIndex = i;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              body: Container(
                decoration: BoxDecoration(color: themeColor),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Tab Hóa đơn
                      Column(
                        children: [
                          // Header với thông tin tổng quan
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 22,
                              horizontal: 20,
                            ),
                            margin: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            final now = DateTime.now();
                                            final defaultStart = now.subtract(
                                                const Duration(days: 29));
                                            final defaultEnd = now;
                                            final picked =
                                                await showDateRangePicker(
                                              context: context,
                                              firstDate: DateTime(2020),
                                              lastDate: DateTime(2030),
                                              initialDateRange:
                                                  (_startDate != null &&
                                                          _endDate != null)
                                                      ? DateTimeRange(
                                                          start: _startDate!,
                                                          end: _endDate!)
                                                      : DateTimeRange(
                                                          start: defaultStart,
                                                          end: defaultEnd,
                                                        ),
                                              builder: (context, child) {
                                                return Theme(
                                                  data: Theme.of(context)
                                                      .copyWith(
                                                    colorScheme:
                                                        ColorScheme.light(
                                                      primary: themeColor,
                                                      onPrimary: Colors.white,
                                                      onSurface: themeColor,
                                                    ),
                                                    textButtonTheme:
                                                        TextButtonThemeData(
                                                      style:
                                                          TextButton.styleFrom(
                                                        foregroundColor:
                                                            themeColor,
                                                      ),
                                                    ),
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );

                                            if (picked != null) {
                                              setState(() {
                                                _startDate = picked.start;
                                                _endDate = picked.end;
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                                width: 1.2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.1),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.calendar_today,
                                                    size: 18,
                                                    color: themeColor),
                                                const SizedBox(width: 8),
                                                Builder(
                                                  builder: (context) {
                                                    final now = DateTime.now();
                                                    final defaultStart =
                                                        now.subtract(
                                                            const Duration(
                                                                days: 29));
                                                    final defaultEnd = now;
                                                    final displayStart =
                                                        _startDate ??
                                                            defaultStart;
                                                    final displayEnd =
                                                        _endDate ?? defaultEnd;
                                                    final isDefault =
                                                        _startDate == null &&
                                                            _endDate == null;
                                                    return Text(
                                                      isDefault
                                                          ? '${DateFormat('dd/MM/yyyy').format(defaultStart)} - ${DateFormat('dd/MM/yyyy').format(defaultEnd)}'
                                                          : '${DateFormat('dd/MM/yyyy').format(displayStart)} - ${DateFormat('dd/MM/yyyy').format(displayEnd)}',
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Color(0xFF2D3142),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
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
                                const SizedBox(height: 20),
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
                                          child: StatItem(
                                            title: 'Toàn bộ',
                                            amount: balance.abs().toString(),
                                            textColor: isNegative
                                                ? const Color(0xFFFF5252)
                                                : const Color(0xFF4CAF50),
                                            showNegative: isNegative,
                                            isAmountVisible: _isAmountVisible,
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
                                          child: StatItem(
                                            title: 'Thu nhập',
                                            amount: totalIncome.toString(),
                                            textColor: const Color(0xFF4CAF50),
                                            isAmountVisible: _isAmountVisible,
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
                                          child: StatItem(
                                            title: 'Chi tiêu',
                                            amount: totalExpense.toString(),
                                            textColor: const Color(0xFFFF5252),
                                            isAmountVisible: _isAmountVisible,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Danh sách các đầu mục chi tiêu
                          Expanded(
                            child: transactions.when(
                              loading: () => const TransactionListSkeleton(),
                              error: (error, stack) =>
                                  Center(child: Text('Error: $error')),
                              data: (allTransactions) {
                                // Lọc transactions theo currentBook
                                final transactionsList = allTransactions
                                    .where((t) => t.bookId == currentBook.id)
                                    .toList();

                                // Lọc theo khoảng thời gian
                                final filteredTransactions =
                                    (_startDate != null && _endDate != null)
                                        ? transactionsList.where((transaction) {
                                            final date = transaction.date;
                                            return !date
                                                    .isBefore(_startDate!) &&
                                                !date.isAfter(_endDate!);
                                          }).toList()
                                        : transactionsList;

                                if (filteredTransactions.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'Hiện chưa có chi tiêu',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }

                                // Nhóm giao dịch theo ngày
                                final groupedTransactions =
                                    <String, List<dynamic>>{};
                                final dailyExpenses = <String, double>{};

                                for (var transaction in filteredTransactions) {
                                  final dateKey = DateFormat('dd/MM/yyyy')
                                      .format(transaction.date!);
                                  if (!groupedTransactions
                                      .containsKey(dateKey)) {
                                    groupedTransactions[dateKey] = [];
                                    dailyExpenses[dateKey] = 0;
                                  }
                                  groupedTransactions[dateKey]!
                                      .add(transaction);
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
                                    final dateKey = groupedTransactions.keys
                                        .elementAt(index);
                                    final transactions =
                                        groupedTransactions[dateKey]!;
                                    final dayExpense =
                                        dailyExpenses[dateKey] ?? 0;

                                    // Tính tổng thu nhập trong ngày
                                    double dayIncome = 0;
                                    for (var transaction in transactions) {
                                      if (transaction.type == 'income') {
                                        dayIncome += transaction.amount;
                                      }
                                    }

                                    // Tính tổng theo ngày (thu - chi)
                                    final dayTotal = dayIncome - dayExpense;

                                    return ExpenseItem(
                                      dateKey: dateKey,
                                      transactions: transactions,
                                      dayExpense: dayExpense,
                                      themeColor: themeColor,
                                      categories: _categories,
                                      isAmountVisible: _isAmountVisible,
                                      currencySymbol: currencySymbol,
                                      onTransactionTap: (transaction) {
                                        _showTransactionDetailModal(
                                            context, transaction, themeColor);
                                      },
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
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
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
                                  // Chuyển đổi selectedDay thành định dạng DB để lọc
                                  final selectedDateStr =
                                      DateFormat('yyyy-MM-dd')
                                              .format(selectedDay) +
                                          'T00:00:00.000';
                                  if (_events.containsKey(selectedDay)) {
                                    final event = _events[selectedDay]![
                                        0]; // Lấy sự kiện đầu tiên
                                    _filteredTransactions =
                                        event['transactions']?.where((t) {
                                              return t['date'] ==
                                                  selectedDateStr; // So sánh với định dạng DB
                                            }).toList() ??
                                            [];
                                    _dayExpense = _filteredTransactions.fold(
                                        0.0,
                                        (sum, t) =>
                                            sum +
                                            (t['type'] == 'expense'
                                                ? -t['amount']
                                                : t['amount']));
                                  } else {
                                    _filteredTransactions = [];
                                    _dayExpense = 0.0;
                                  }
                                });
                              },
                              calendarStyle: CalendarStyle(
                                selectedDecoration: BoxDecoration(
                                  color: themeColor,
                                  shape: BoxShape.circle,
                                ),
                                markerDecoration: BoxDecoration(
                                  color: themeColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              headerStyle: const HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                              ),
                            ),
                          ),
                          IntrinsicHeight(
                            child: transactions.when(
                              loading: () => const TransactionListSkeleton(),
                              error: (error, stack) =>
                                  Center(child: Text('Error: $error')),
                              data: (allTransactions) {
                                // Lọc transactions theo currentBook
                                final transactionsByDate = allTransactions
                                    .where((t) =>
                                        t.bookId == currentBook.id &&
                                        isSameDay(t.date, _selectedDay))
                                    .toList();

                                if (transactionsByDate.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'Hiện chưa có chi tiêu',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }

                                final dayExpense =
                                    transactionsByDate.fold<double>(
                                  0.0,
                                  (sum, t) =>
                                      sum +
                                      (t.type == 'expense'
                                          ? -t.amount
                                          : t.amount),
                                );

                                return CalendarExpenseItem(
                                  dateKey: DateFormat('dd/MM/yyyy')
                                      .format(_selectedDay),
                                  transactions: transactionsByDate,
                                  dayExpense: dayExpense,
                                  themeColor: themeColor,
                                  isAmountVisible: _isAmountVisible,
                                  categories: _categories,
                                  onTapTransaction: (transaction) {
                                    _showTransactionDetailModal(
                                        context, transaction, themeColor);
                                  },
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  _showAddExpenseModal(context, currentBook, themeColor);
                },
                backgroundColor: themeColor,
                elevation: 4,
                child: const Icon(Icons.add, size: 30, color: Colors.white),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddExpenseModal(
    BuildContext context,
    Book currentBook,
    Color themeColor,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddTransactionModal(
          currentBook: currentBook,
          themeColor: themeColor,
          initialIsExpense: true,
          expenseCategories: _expenseCategories,
          incomeCategories: _incomeCategories,
        );
      },
    );
  }

  void _showTransactionDetailModal(
    BuildContext context,
    Transaction transaction,
    Color themeColor,
  ) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: SingleChildScrollView(
          child: TransactionDetailModal(
            transaction: transaction,
            themeColor: themeColor,
            categories: _categories,
            onEdit: () =>
                _showEditTransactionModal(context, transaction, themeColor),
          ),
        ),
      ),
    );
  }

  void _showEditTransactionModal(
    BuildContext context,
    Transaction transaction,
    Color themeColor,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditTransactionModal(
        transaction: transaction,
        themeColor: themeColor,
        categories: _categories,
        expenseCategories: _expenseCategories,
        incomeCategories: _incomeCategories,
      ),
    );
  }

  void _showCreateBookModal(BuildContext context, Color themeColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateBookModal(themeColor: themeColor),
    );
  }

  void _showBookListScreen(BuildContext context, Color themeColor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookListScreen(
          themeColor: themeColor,
        ),
      ),
    );
  }
}

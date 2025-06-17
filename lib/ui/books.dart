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

  Widget _buildTransactionListSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(6),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
              // Date header skeleton
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
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
                      width: 100,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              // Transaction items skeleton
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: List.generate(
                    3,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
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
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(booksProvider);
    final currentBook = ref.watch(currentBookProvider);
    final transactions = ref.watch(transactionsProvider);

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
                    Expanded(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                              currentBook.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
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
                    Expanded(
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
                          const SizedBox(width: 8),
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
                              loading: () => _buildTransactionListSkeleton(),
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
                                            final date = transaction.date!;
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

                                    return _buildExpenseItem(
                                        dateKey: dateKey,
                                        transactions: transactions,
                                        dayExpense: dayTotal,
                                        themeColor: themeColor);
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
                              loading: () => _buildTransactionListSkeleton(),
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
                                  (sum, t) => sum + t.amount,
                                );
                                return _buildExpenseItemForCalendar(
                                  dateKey: DateFormat('dd/MM/yyyy')
                                      .format(_selectedDay),
                                  transactions: transactionsByDate,
                                  dayExpense: dayExpense,
                                  themeColor: themeColor,
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

  Widget _buildExpenseItem(
      {required String dateKey,
      required List<dynamic> transactions,
      required double dayExpense,
      required Color themeColor}) {
    final isExpanded = _expandedDays[dateKey] ?? false;
    final numberFormat = NumberFormat('#,###');

    final date = DateFormat('dd/MM/yy').parse(dateKey);
    final weekdayNumber = date.weekday;
    const weekdayMap = {
      1: 'Th 2',
      2: 'Th 3',
      3: 'Th 4',
      4: 'Th 5',
      5: 'Th 6',
      6: 'Th 7',
      7: 'CN',
    };

    final formattedDate =
        '${weekdayMap[weekdayNumber]}, ${DateFormat('dd/MM').format(date)}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey
                .withOpacity(0.2), // Increased opacity for stronger shadow
            spreadRadius: 2, // Increased spread for more coverage
            blurRadius:
                8, // Increased blur for a softer, more pronounced effect
            offset: const Offset(
                0, 4), // Increased vertical offset for greater elevation
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.1), // Additional subtle shadow
            spreadRadius: 1,
            blurRadius: 2,
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
                      color: themeColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 13.5,
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

                final bgColor = themeColor.withOpacity(0.1);

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: InkWell(
                    onTap: () {
                      _showTransactionDetailModal(
                          context, transaction, themeColor);
                    },
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
                            color: themeColor,
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

  Widget _buildExpenseItemForCalendar({
    required String dateKey,
    required List<Transaction> transactions,
    required double dayExpense,
    required Color themeColor,
  }) {
    final date = DateFormat('dd/MM/yy').parse(dateKey);

    final weekdayNumber = date.weekday;

    const weekdayMap = {
      1: 'Th 2',
      2: 'Th 3',
      3: 'Th 4',
      4: 'Th 5',
      5: 'Th 6',
      6: 'Th 7',
      7: 'CN',
    };

    final formattedDate =
        '${weekdayMap[weekdayNumber]}, ${DateFormat('dd/MM').format(date)}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
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
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔒 HEADER CỐ ĐỊNH
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: themeColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 13.5,
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

          // ListView cho transaction details
          SizedBox(
            height: 230, // 👈 tùy chỉnh chiều cao cuộn
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                final category = _categories.firstWhere(
                  (cat) => cat['id'] == transaction.categoryId,
                  orElse: () => {'icon': '🏷️', 'color': '0xFF6C63FF'},
                );

                final bgColor = themeColor.withOpacity(0.1);

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: InkWell(
                    onTap: () {
                      _showTransactionDetailModal(
                          context, transaction, themeColor);
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getIconFromEmoji(category['icon'] ?? '🏷️'),
                            color: themeColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            transaction.note,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseModal(
      BuildContext context, Book currentBook, Color themeColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: StatefulBuilder(
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3142),
                                ),
                              ),
                              Row(
                                children: [
                                  TypeButton(
                                      text: 'Chi tiêu',
                                      isSelected: _isExpense == true,
                                      onTap: () {
                                        setState(() {
                                          _isExpense = true;
                                          _selectedCategory = null;
                                        });
                                      },
                                      themeColor: themeColor),
                                  const SizedBox(width: 8),
                                  TypeButton(
                                    text: 'Thu nhập',
                                    isSelected: _isExpense == false,
                                    themeColor: themeColor,
                                    onTap: () {
                                      setState(() {
                                        _isExpense = false;
                                        _selectedCategory = null;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Ghi chú',
                              labelStyle: TextStyle(
                                color: themeColor,
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
                            ),
                            onChanged: (value) => _note = value,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _amount.isEmpty
                                      ? '0 ${ref.watch(currencyProvider).symbol}'
                                      : '${formatCurrency(double.tryParse(_amount) ?? 0, ref.watch(currencyProvider))}',
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
                              labelStyle: TextStyle(
                                color: themeColor,
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
                                    bookId: currentBook.id ?? 0,
                                    userId: 1,
                                  );

                                  if (mounted) {
                                    Navigator.pop(context);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
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
          ),
        );
      },
    );
  }

  void _showTransactionDetailModal(
      BuildContext context, Transaction transaction, Color themeColor) {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: SingleChildScrollView(
            child: Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 12, bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Transaction Type and Amount
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: transaction.type == 'expense'
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  transaction.type == 'expense'
                                      ? 'Chi tiêu'
                                      : 'Thu nhập',
                                  style: TextStyle(
                                    color: transaction.type == 'expense'
                                        ? Colors.red
                                        : Colors.green,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Text(
                                '${transaction.type == 'expense' ? '-' : '+'}${formatCurrency(transaction.amount, ref.watch(currencyProvider))}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: transaction.type == 'expense'
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Category
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: themeColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getIconFromEmoji(_categories.firstWhere(
                                        (cat) =>
                                            cat['id'] == transaction.categoryId,
                                        orElse: () => {'icon': '🏷️'},
                                      )['icon'] ??
                                      '🏷️'),
                                  color: themeColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _categories.firstWhere(
                                      (cat) =>
                                          cat['id'] == transaction.categoryId,
                                      orElse: () => {'name': 'Không xác định'},
                                    )['name'] ??
                                    'Không xác định',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Note
                          if (transaction.note.isNotEmpty) ...[
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Ghi chú',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                transaction.note,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          // Date
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 20, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('dd/MM/yyyy')
                                    .format(transaction.date!),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final transactionNotifier =
                                        ref.read(transactionsProvider.notifier);
                                    await transactionNotifier
                                        .deleteTransaction(transaction.id!);
                                    // Thông báo cho người dùng
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Xóa thành công',
                                        ),
                                        backgroundColor:
                                            const Color(0xFF4CAF50),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                    if (mounted) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Xóa',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showEditTransactionModal(
                                        context, transaction, themeColor);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Chỉnh sửa',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

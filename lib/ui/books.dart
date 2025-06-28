import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../data/database/database_helper.dart';
import '../providers/providers_barrel.dart';
import '../utils/localization.dart';
import './widget/widget_barrel.dart';
import '../data/models/models_barrel.dart';
import '../utils/category_helper.dart';

class Books extends ConsumerStatefulWidget {
  const Books({super.key});

  @override
  ConsumerState<Books> createState() => _BooksState();
}

class _BooksState extends ConsumerState<Books>
    with SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _expenseCategories = [];
  List<Map<String, dynamic>> _incomeCategories = [];
  final Map<DateTime, List<Map<String, dynamic>>> _events = {};
  late TabController _tabController;
  int _selectedTabIndex = 0;

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

  // Add this field to the class
  OverlayEntry? _overlayEntry;

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
    final l10n = AppLocalizations.of(context);

    // Lấy màu nền hiện tại
    final themeColor = ref.watch(themeColorProvider);
    return books.when(
      loading: () => const SkeletonLoading(),
      error: (error, stack) => Scaffold(
          body: Center(child: Text(l10n.errorOccurredWith(error.toString())))),
      data: (books) {
        if (books.isEmpty) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: themeColor,
              elevation: 0,
              toolbarHeight: 60.h,
              title: Text(
                l10n.books,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.sp,
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
                              size: 64.w,
                              color: themeColor,
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              l10n.noBook,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2D3142),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              l10n.createFirstBook,
                              style: TextStyle(
                                  fontSize: 16.sp, color: Colors.grey),
                            ),
                            SizedBox(height: 20.h),
                            ElevatedButton(
                              onPressed: () {
                                _showCreateBookModal(context, themeColor);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 32.w,
                                  vertical: 16.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                l10n.createBook,
                                style: TextStyle(
                                  fontSize: 16.sp,
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
          loading: () => const SkeletonLoading(),
          error: (error, stack) => Scaffold(
            body: Center(child: Text(l10n.errorOccurredWith(error.toString()))),
          ),
          data: (currentBook) {
            if (currentBook == null ||
                !books.any((book) => book.id == currentBook.id)) {
              if (books.isNotEmpty) {
                ref
                    .read(currentBookProvider.notifier)
                    .setCurrentBook(books.first);
              }
              return const SkeletonLoading();
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
                toolbarHeight: 60.h,
                title: Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: Row(
                        children: [
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.only(left: 5.w),
                              child: Text(
                                currentBook.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22.sp,
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
                              borderRadius: BorderRadius.circular(999.r),
                              child: Container(
                                width: 35.w,
                                height: 37.h,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.arrow_right_rounded,
                                  size: 35.w,
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
                            label: l10n.invoice,
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
                            label: l10n.calendar,
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
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(22.r),
                      topRight: Radius.circular(22.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(0, 1.h),
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
                            padding: EdgeInsets.symmetric(
                              vertical: 22.h,
                              horizontal: 20.w,
                            ),
                            margin: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: Offset(0, 4.h),
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
                                            );

                                            if (picked != null) {
                                              setState(() {
                                                _startDate = picked.start;
                                                _endDate = picked.end;
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16.w,
                                                vertical: 10.h),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                                width: 1.2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.1),
                                                  blurRadius: 6,
                                                  offset: Offset(0, 3.h),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.calendar_today,
                                                    size: 18.w,
                                                    color: themeColor),
                                                SizedBox(width: 8.w),
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
                                                      style: TextStyle(
                                                        fontSize: 15.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: const Color(
                                                            0xFF2D3142),
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
                                        size: 24.w,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isAmountVisible = !_isAmountVisible;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.h),
                                // Stats row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: 110.w,
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: StatItem(
                                            title: l10n.all,
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
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: 110.w,
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: StatItem(
                                            title: l10n.income,
                                            amount: totalIncome.toString(),
                                            textColor: const Color(0xFF4CAF50),
                                            isAmountVisible: _isAmountVisible,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: 110.w,
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: StatItem(
                                            title: l10n.expense,
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
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.sentiment_dissatisfied_outlined,
                                        size: 100.w,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(
                                        height: 16.h,
                                      ),
                                      Text(
                                        l10n.noExpenseYet,
                                        style: TextStyle(
                                            fontSize: 17.sp,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                            fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  ));
                                }

                                // Nhóm giao dịch theo ngày
                                final groupedTransactions =
                                    <String, List<dynamic>>{};
                                final dailyExpenses = <String, double>{};

                                for (var transaction in filteredTransactions) {
                                  final dateKey = DateFormat('dd/MM/yyyy')
                                      .format(transaction.date);
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
                                  padding: EdgeInsets.all(6.w),
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
                                    print('dayTotal' + dayTotal.toString());
                                    return ExpenseItem(
                                      dateKey: dateKey,
                                      transactions: transactions,
                                      dayExpense: dayTotal,
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
                            margin: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: Offset(0, 4.h),
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
                                      l10n.noExpenseYet,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.italic,
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
              floatingActionButton: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 10.h, 20.h),
                child: FloatingActionButton(
                  onPressed: () {
                    _showAddExpenseModal(context, currentBook, themeColor);
                  },
                  backgroundColor: themeColor,
                  elevation: 4,
                  child: Icon(Icons.add, size: 30.w, color: Colors.white),
                ),
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

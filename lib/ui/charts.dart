import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/database/database_helper.dart';
import '../providers/providers_barrel.dart';
import './widget/widget_barrel.dart';

// Enum để định nghĩa các loại bộ lọc
enum FilterType {
  day,
  week,
  month,
  year,
}

class Charts extends ConsumerStatefulWidget {
  const Charts({super.key});

  @override
  ConsumerState<Charts> createState() => _ChartsState();
}

class _ChartsState extends ConsumerState<Charts>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _categories = [];
  Map<String, double> _categoryExpenses = {};
  Map<String, double> _categoryIncomes = {};
  DateTime _selectedDate = DateTime.now();
  FilterType _selectedFilter = FilterType.month;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Bắt buộc để cập nhật selected tab
    });
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final categories = await _dbHelper.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  // Phương thức để lấy khoảng thời gian dựa trên loại bộ lọc
  DateTimeRange _getDateRange() {
    final now = DateTime.now();

    switch (_selectedFilter) {
      case FilterType.day:
        return DateTimeRange(
          start: DateTime(
              _selectedDate.year, _selectedDate.month, _selectedDate.day),
          end: DateTime(_selectedDate.year, _selectedDate.month,
              _selectedDate.day, 23, 59, 59),
        );
      case FilterType.week:
        // Tính ngày đầu tuần (Thứ 2)
        final daysFromMonday = _selectedDate.weekday - 1;
        final startOfWeek =
            _selectedDate.subtract(Duration(days: daysFromMonday));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return DateTimeRange(
          start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
          end: DateTime(
              endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59),
        );
      case FilterType.month:
        return DateTimeRange(
          start: DateTime(_selectedDate.year, _selectedDate.month, 1),
          end: DateTime(
              _selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59),
        );
      case FilterType.year:
        return DateTimeRange(
          start: DateTime(_selectedDate.year, 1, 1),
          end: DateTime(_selectedDate.year, 12, 31, 23, 59, 59),
        );
    }
  }

  // Phương thức để chọn ngày dựa trên loại bộ lọc
  void _selectDate(BuildContext context) async {
    DateTime? picked;

    switch (_selectedFilter) {
      case FilterType.day:
        picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        break;
      case FilterType.week:
        picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        break;
      case FilterType.month:
        picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDatePickerMode: DatePickerMode.year,
        );
        if (picked != null) {
          picked = DateTime(picked.year, picked.month);
        }
        break;
      case FilterType.year:
        picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDatePickerMode: DatePickerMode.year,
        );
        if (picked != null) {
          picked = DateTime(picked.year);
        }
        break;
    }

    if (picked != null) {
      setState(() {
        _selectedDate = picked!;
      });
    }
  }

  // Phương thức để cập nhật ngày dựa trên loại bộ lọc
  void _updateSelectedDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
  }

  // Phương thức để lấy ngày trước đó
  DateTime _getPreviousDate() {
    switch (_selectedFilter) {
      case FilterType.day:
        return _selectedDate.subtract(const Duration(days: 1));
      case FilterType.week:
        return _selectedDate.subtract(const Duration(days: 7));
      case FilterType.month:
        return DateTime(_selectedDate.year, _selectedDate.month - 1);
      case FilterType.year:
        return DateTime(_selectedDate.year - 1);
    }
  }

  // Phương thức để lấy ngày tiếp theo
  DateTime _getNextDate() {
    switch (_selectedFilter) {
      case FilterType.day:
        return _selectedDate.add(const Duration(days: 1));
      case FilterType.week:
        return _selectedDate.add(const Duration(days: 7));
      case FilterType.month:
        return DateTime(_selectedDate.year, _selectedDate.month + 1);
      case FilterType.year:
        return DateTime(_selectedDate.year + 1);
    }
  }

  // Phương thức để kiểm tra xem có thể đi đến ngày tiếp theo không
  bool _canGoToNextDate() {
    final nextDate = _getNextDate();
    final now = DateTime.now();

    switch (_selectedFilter) {
      case FilterType.day:
        return nextDate.isBefore(now) || nextDate.isAtSameMomentAs(now);
      case FilterType.week:
        return nextDate.isBefore(now) || nextDate.isAtSameMomentAs(now);
      case FilterType.month:
        return nextDate.year < now.year ||
            (nextDate.year == now.year && nextDate.month <= now.month);
      case FilterType.year:
        return nextDate.year <= now.year;
    }
  }

  // Phương thức để format ngày hiển thị
  String _getDisplayDate() {
    final dateRange = _getDateRange();

    switch (_selectedFilter) {
      case FilterType.day:
        return DateFormat('dd/MM/yyyy').format(_selectedDate);
      case FilterType.week:
        return '${DateFormat('dd/MM').format(dateRange.start)} - ${DateFormat('dd/MM/yyyy').format(dateRange.end)}';
      case FilterType.month:
        return DateFormat('MM/yyyy').format(_selectedDate);
      case FilterType.year:
        return DateFormat('yyyy').format(_selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final currencyType = ref.watch(currencyProvider);
    final currentBook = ref.watch(currentBookProvider);
// Lấy màu nền hiện tại
    final themeColor = ref.watch(themeColorProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        selectedDate: _selectedDate,
        selectedFilter: _selectedFilter,
        onDateChanged: _updateSelectedDate,
        onDateTap: () => _selectDate(context),
        onFilterChanged: (FilterType filter) {
          setState(() {
            _selectedFilter = filter;
          });
        },
        onPreviousDate: () => _updateSelectedDate(_getPreviousDate()),
        onNextDate: () => _updateSelectedDate(_getNextDate()),
        canGoToNextDate: _canGoToNextDate(),
        displayDate: _getDisplayDate(),
        themeColor: themeColor,
      ),
      body: currentBook.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (book) {
          if (book == null) {
            return Center(
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
                          style: TextStyle(fontSize: 16, color: Colors.grey),
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
            );
          }
          return Container(
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
              child: Column(
                children: [
                  // Tab bar for expense/income analysis
                  Row(
                    children: List.generate(2, (index) {
                      final isSelected = _selectedTab == index;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTab = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 20),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            decoration: BoxDecoration(
                              color: isSelected ? themeColor : Colors.grey[200],
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color:
                                            Colors.deepPurple.withOpacity(0.3),
                                        offset: const Offset(0, 3),
                                        blurRadius: 6,
                                      )
                                    ]
                                  : [],
                              border: Border.all(
                                color: isSelected
                                    ? themeColor
                                    : Colors.grey.shade400,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  index == 0
                                      ? Icons.money_off
                                      : Icons.attach_money,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black54,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  index == 0 ? 'Chi tiêu' : 'Thu nhập',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  // Main content
                  Expanded(
                    child: _selectedTab == 0
                        ? _buildExpenseAnalysis(
                            transactions, currencyType, book.id!)
                        : _buildIncomeAnalysis(
                            transactions, currencyType, book.id!),
                  ),
                ],
              ),
            ),
          );
        },
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

  Widget _buildPieChart(
    Map<String, double> data,
    CurrencyType currencyType,
    bool isExpense,
  ) {
    final total = data.values.fold(0.0, (sum, amount) => sum + amount);
    final sortedData = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      height: 320,
      padding: const EdgeInsets.only(top: 20),
      child: Stack(
        children: [
          if (data.isEmpty)
            PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: Colors.grey[200],
                    value: 1,
                    radius: 100,
                    showTitle: false,
                  ),
                ],
                centerSpaceRadius: 60,
                sectionsSpace: 0,
              ),
            )
          else
            PieChart(
              PieChartData(
                sections: _createPieChartSections(sortedData, total, isExpense),
                centerSpaceRadius: 60,
                sectionsSpace: 2,
              ),
            ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 140, // Giới hạn chiều ngang, bạn có thể điều chỉnh
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        data.isEmpty
                            ? '0'
                            : formatCurrency(total, currencyType),
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          color: data.isEmpty
                              ? Colors.grey[400]
                              : (isExpense
                                  ? const Color(0xFFFF5252)
                                  : const Color(0xFF4CAF50)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 0),
                  Text(
                    isExpense ? 'Tổng chi tiêu' : 'Tổng thu nhập',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    _getDisplayDate(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _createPieChartSections(
    List<MapEntry<String, double>> data,
    double total,
    bool isExpense,
  ) {
    final List<Color> colors = [
      const Color(0xFFFF5252),
      const Color(0xFFFF9800),
      const Color(0xFFFFEB3B),
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFF9C27B0),
      const Color(0xFFE91E63),
      const Color(0xFF795548),
    ];

    return List.generate(data.length, (index) {
      final percentage = (data[index].value / total * 100).toStringAsFixed(1);
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: data[index].value,
        title: '$percentage%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildExpenseAnalysis(AsyncValue<List<dynamic>> transactions,
      CurrencyType currencyType, int bookId) {
    return transactions.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (transactionsList) {
        // Calculate expenses by category for selected month and current book
        _categoryExpenses.clear();

        // Filter transactions for the selected month
        for (var transaction in transactionsList) {
          if (transaction.type == 'expense' &&
              transaction.bookId == bookId &&
              transaction.date != null) {
            final dateRange = _getDateRange();
            final transactionDate = transaction.date!;

            // Kiểm tra xem giao dịch có nằm trong khoảng thời gian được chọn không
            if (transactionDate.isAfter(
                    dateRange.start.subtract(const Duration(seconds: 1))) &&
                transactionDate
                    .isBefore(dateRange.end.add(const Duration(seconds: 1)))) {
              final category = _categories.firstWhere(
                (cat) => cat['id'] == transaction.categoryId,
                orElse: () => {'name': 'Khác'},
              );
              final categoryName = category['name'] as String;
              _categoryExpenses[categoryName] =
                  (_categoryExpenses[categoryName] ?? 0) + transaction.amount;
            }
          }
        }

        // Sort expenses by amount (highest to lowest)
        final sortedExpenses = _categoryExpenses.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Column(
          children: [
            _buildPieChart(_categoryExpenses, currencyType, true),
            const SizedBox(
              height: 20,
            ),
            if (_categoryExpenses.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Không có chi tiêu trong tháng này',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedExpenses.length,
                  itemBuilder: (context, index) {
                    final category = sortedExpenses[index];
                    final totalExpense = _categoryExpenses.values.fold(
                      0.0,
                      (sum, amount) => sum + amount,
                    );
                    final percentage = (category.value / totalExpense * 100)
                        .toStringAsFixed(1);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors
                                  .primaries[index % Colors.primaries.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              category.key,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            formatCurrency(category.value, currencyType),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF5252),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildIncomeAnalysis(AsyncValue<List<dynamic>> transactions,
      CurrencyType currencyType, int bookId) {
    return transactions.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (transactionsList) {
        // Calculate income by category for selected month and current book
        _categoryIncomes.clear();

        // Filter transactions for the selected month
        for (var transaction in transactionsList) {
          if (transaction.type == 'income' &&
              transaction.bookId == bookId &&
              transaction.date != null) {
            final dateRange = _getDateRange();
            final transactionDate = transaction.date!;

            // Kiểm tra xem giao dịch có nằm trong khoảng thời gian được chọn không
            if (transactionDate.isAfter(
                    dateRange.start.subtract(const Duration(seconds: 1))) &&
                transactionDate
                    .isBefore(dateRange.end.add(const Duration(seconds: 1)))) {
              final category = _categories.firstWhere(
                (cat) => cat['id'] == transaction.categoryId,
                orElse: () => {'name': 'Khác'},
              );
              final categoryName = category['name'] as String;
              _categoryIncomes[categoryName] =
                  (_categoryIncomes[categoryName] ?? 0) + transaction.amount;
            }
          }
        }

        // Sort incomes by amount (highest to lowest)
        final sortedIncomes = _categoryIncomes.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Column(
          children: [
            _buildPieChart(_categoryIncomes, currencyType, false),
            const SizedBox(
              height: 20,
            ),
            if (_categoryIncomes.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Không có thu nhập trong tháng này',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedIncomes.length,
                  itemBuilder: (context, index) {
                    final category = sortedIncomes[index];
                    final totalIncome = _categoryIncomes.values.fold(
                      0.0,
                      (sum, amount) => sum + amount,
                    );
                    final percentage =
                        (category.value / totalIncome * 100).toStringAsFixed(1);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors
                                  .primaries[index % Colors.primaries.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              category.key,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            formatCurrency(category.value, currencyType),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DateTime selectedDate;
  final FilterType selectedFilter;
  final Function(DateTime) onDateChanged;
  final VoidCallback onDateTap;
  final Function(FilterType) onFilterChanged;
  final VoidCallback onPreviousDate;
  final VoidCallback onNextDate;
  final bool canGoToNextDate;
  final String displayDate;
  final Color themeColor;
  const CustomAppBar(
      {super.key,
      required this.selectedDate,
      required this.selectedFilter,
      required this.onDateChanged,
      required this.onDateTap,
      required this.onFilterChanged,
      required this.onPreviousDate,
      required this.onNextDate,
      required this.canGoToNextDate,
      required this.displayDate,
      required this.themeColor});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: themeColor,
      toolbarHeight: 60,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Phân tích chi tiêu',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          Row(
            children: [
              // Điều hướng ngày với dropdown bộ lọc
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: onPreviousDate,
              ),
              GestureDetector(
                onTap: onDateTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    displayDate,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              PopupMenuButton<FilterType>(
                onSelected: (FilterType filter) {
                  onFilterChanged(filter);
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<FilterType>(
                    value: FilterType.day,
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: selectedFilter == FilterType.day
                              ? themeColor
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ngày',
                          style: TextStyle(
                            color: selectedFilter == FilterType.day
                                ? themeColor
                                : Colors.black,
                            fontWeight: selectedFilter == FilterType.day
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<FilterType>(
                    value: FilterType.week,
                    child: Row(
                      children: [
                        Icon(
                          Icons.view_week,
                          size: 16,
                          color: selectedFilter == FilterType.week
                              ? themeColor
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tuần',
                          style: TextStyle(
                            color: selectedFilter == FilterType.week
                                ? themeColor
                                : Colors.black,
                            fontWeight: selectedFilter == FilterType.week
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<FilterType>(
                    value: FilterType.month,
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 16,
                          color: selectedFilter == FilterType.month
                              ? themeColor
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tháng',
                          style: TextStyle(
                            color: selectedFilter == FilterType.month
                                ? themeColor
                                : Colors.black,
                            fontWeight: selectedFilter == FilterType.month
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<FilterType>(
                    value: FilterType.year,
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 16,
                          color: selectedFilter == FilterType.year
                              ? themeColor
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Năm',
                          style: TextStyle(
                            color: selectedFilter == FilterType.year
                                ? themeColor
                                : Colors.black,
                            fontWeight: selectedFilter == FilterType.year
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                child: Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: canGoToNextDate ? onNextDate : null,
                      tooltip: _getFilterTooltip(),
                    ),
                    // Indicator cho loại bộ lọc hiện tại
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: themeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  String _getFilterTooltip() {
    switch (selectedFilter) {
      case FilterType.day:
        return 'Ngày';
      case FilterType.week:
        return 'Tuần';
      case FilterType.month:
        return 'Tháng';
      case FilterType.year:
        return 'Năm';
    }
  }
}

String formatCurrency(double amount, CurrencyType currencyType) {
  final formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: currencyType == CurrencyType.vnd ? '₫' : '\$',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

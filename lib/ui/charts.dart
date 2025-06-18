import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/database/database_helper.dart';
import '../ui/more.dart';
import '../providers/providers_barrel.dart';

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
  DateTime _selectedMonth = DateTime.now();
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

  void _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  void _updateSelectedMonth(DateTime newMonth) {
    setState(() {
      _selectedMonth = newMonth;
    });
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
        selectedMonth: _selectedMonth,
        onMonthChanged: _updateSelectedMonth,
        onMonthTap: () => _selectMonth(context),
        themeColor: themeColor,
      ),
      body: currentBook.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (book) {
          if (book == null) {
            return const Center(
              child: Text('Vui lòng chọn một sổ để xem phân tích'),
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

  Widget _buildPieChart(
      Map<String, double> data, CurrencyType currencyType, bool isExpense) {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.isEmpty ? '0' : formatCurrency(total, currencyType),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: data.isEmpty
                        ? Colors.grey[400]
                        : (isExpense
                            ? const Color(0xFFFF5252)
                            : const Color(0xFF4CAF50)),
                  ),
                ),
                Text(
                  isExpense ? 'Tổng chi tiêu' : 'Tổng thu nhập',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  DateFormat('MM/yyyy').format(_selectedMonth),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
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

        for (var transaction in transactionsList) {
          if (transaction.type == 'expense' &&
              transaction.bookId == bookId &&
              transaction.date != null &&
              transaction.date!.year == _selectedMonth.year &&
              transaction.date!.month == _selectedMonth.month) {
            final category = _categories.firstWhere(
              (cat) => cat['id'] == transaction.categoryId,
              orElse: () => {'name': 'Khác'},
            );
            final categoryName = category['name'] as String;
            _categoryExpenses[categoryName] =
                (_categoryExpenses[categoryName] ?? 0) + transaction.amount;
          }
        }

        // Sort expenses by amount (highest to lowest)
        final sortedExpenses = _categoryExpenses.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Column(
          children: [
            _buildPieChart(_categoryExpenses, currencyType, true),
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

        for (var transaction in transactionsList) {
          if (transaction.type == 'income' &&
              transaction.bookId == bookId &&
              transaction.date != null &&
              transaction.date!.year == _selectedMonth.year &&
              transaction.date!.month == _selectedMonth.month) {
            final category = _categories.firstWhere(
              (cat) => cat['id'] == transaction.categoryId,
              orElse: () => {'name': 'Khác'},
            );
            final categoryName = category['name'] as String;
            _categoryIncomes[categoryName] =
                (_categoryIncomes[categoryName] ?? 0) + transaction.amount;
          }
        }

        // Sort incomes by amount (highest to lowest)
        final sortedIncomes = _categoryIncomes.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Column(
          children: [
            _buildPieChart(_categoryIncomes, currencyType, false),
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
  final DateTime selectedMonth;
  final Function(DateTime) onMonthChanged;
  final VoidCallback onMonthTap;
  final Color themeColor;
  const CustomAppBar(
      {super.key,
      required this.selectedMonth,
      required this.onMonthChanged,
      required this.onMonthTap,
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
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  onMonthChanged(DateTime(
                    selectedMonth.year,
                    selectedMonth.month - 1,
                  ));
                },
              ),
              GestureDetector(
                onTap: onMonthTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DateFormat('MM/yyyy').format(selectedMonth),
                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: selectedMonth.year == DateTime.now().year &&
                        selectedMonth.month == DateTime.now().month
                    ? null
                    : () {
                        onMonthChanged(DateTime(
                          selectedMonth.year,
                          selectedMonth.month + 1,
                        ));
                      },
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
}

String formatCurrency(double amount, CurrencyType currencyType) {
  final formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: currencyType == CurrencyType.vnd ? '₫' : '\$',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

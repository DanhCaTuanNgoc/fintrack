import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< Updated upstream
import '../ui/more.dart'; // Import để lấy backgroundColorProvider
=======
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/database/database_helper.dart';
import '../providers/transaction_provider.dart';
import '../providers/currency_provider.dart';
>>>>>>> Stashed changes

class Charts extends ConsumerStatefulWidget {
  const Charts({super.key});

  @override
  ConsumerState<Charts> createState() => _ChartsState();
}

<<<<<<< Updated upstream
class _ChartsState extends ConsumerState<Charts> {
  @override
  Widget build(BuildContext context) {
    // Lấy màu nền từ provider
    final backgroundColor = ref.watch(backgroundColorProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: const CustomAppBar(),
      body: const Center(child: Text('Chart Content')),
=======
class _ChartsState extends ConsumerState<Charts>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _categories = [];
  Map<String, double> _categoryExpenses = {};
  Map<String, double> _categoryIncomes = {};
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

    return Scaffold(
      appBar: CustomAppBar(
        selectedMonth: _selectedMonth,
        onMonthChanged: _updateSelectedMonth,
        onMonthTap: () => _selectMonth(context),
      ),
      body: Column(
        children: [
          // Tab bar for expense/income analysis
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Chi tiêu'),
              Tab(text: 'Thu nhập'),
            ],
            labelColor: const Color(0xFF6C63FF),
            unselectedLabelColor: Colors.grey,
          ),
          // Main content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildExpenseAnalysis(transactions, currencyType),
                _buildIncomeAnalysis(transactions, currencyType),
              ],
            ),
          ),
        ],
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

  Widget _buildExpenseAnalysis(
      AsyncValue<List<dynamic>> transactions, CurrencyType currencyType) {
    return transactions.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (transactionsList) {
        // Calculate expenses by category for selected month
        _categoryExpenses.clear();

        for (var transaction in transactionsList) {
          if (transaction.type == 'expense' &&
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

  Widget _buildIncomeAnalysis(
      AsyncValue<List<dynamic>> transactions, CurrencyType currencyType) {
    return transactions.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (transactionsList) {
        // Calculate income by category for selected month
        _categoryIncomes.clear();

        for (var transaction in transactionsList) {
          if (transaction.type == 'income' &&
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
>>>>>>> Stashed changes
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DateTime selectedMonth;
  final Function(DateTime) onMonthChanged;
  final VoidCallback onMonthTap;

  const CustomAppBar({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
    required this.onMonthTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
<<<<<<< Updated upstream
      title: const Text(
        'Phân tích',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Color(0xFF2D3142),
        ),
=======
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Phân tích chi tiêu',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF2D3142),
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
                    color: const Color(0xFF6C63FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DateFormat('MM/yyyy').format(selectedMonth),
                    style: const TextStyle(
                      color: Colors.white,
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
>>>>>>> Stashed changes
      ),
      backgroundColor: Colors.white,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/database/database_helper.dart';
import '../providers/providers_barrel.dart';
import '../utils/localization.dart';
import './widget/widget_barrel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    final l10n = AppLocalizations.of(context);

    // Lấy màu nền hiện tại
    final themeColor = ref.watch(themeColorProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        selectedMonth: _selectedMonth,
        onMonthChanged: _updateSelectedMonth,
        onMonthTap: () => _selectMonth(context),
        themeColor: themeColor,
        l10n: l10n,
      ),
      body: currentBook.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('${l10n.error}: $error')),
        data: (book) {
          if (book == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    margin: EdgeInsets.all(16.w),
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
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          l10n.createFirstBook,
                          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
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
                            l10n.createFirstBook,
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
            );
          }
          return Container(
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
                            margin: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 20.h),
                            padding: EdgeInsets.symmetric(
                                vertical: 12.h, horizontal: 20.w),
                            decoration: BoxDecoration(
                              color: isSelected ? themeColor : Colors.grey[200],
                              borderRadius: BorderRadius.circular(30.r),
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
                                width: 1.2.w,
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
                                  size: 20.w,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  index == 0 ? l10n.expense : l10n.income,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
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
                            transactions, currencyType, book.id!, l10n)
                        : _buildIncomeAnalysis(
                            transactions, currencyType, book.id!, l10n),
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
    AppLocalizations l10n,
  ) {
    final total = data.values.fold(0.0, (sum, amount) => sum + amount);
    final sortedData = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      height: 320.h,
      padding: EdgeInsets.only(top: 20.h),
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
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 140.w, // Giới hạn chiều ngang, bạn có thể điều chỉnh
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        data.isEmpty
                            ? '0'
                            : formatCurrency(total, currencyType),
                        style: TextStyle(
                          fontSize: 16.5.sp,
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
                  Text(
                    isExpense ? l10n.totalExpense : l10n.totalIncome,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    DateFormat('MM/yyyy').format(_selectedMonth),
                    style: TextStyle(
                      fontSize: 12.sp,
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
        titleStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildExpenseAnalysis(AsyncValue<List<dynamic>> transactions,
      CurrencyType currencyType, int bookId, AppLocalizations l10n) {
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
            _buildPieChart(_categoryExpenses, currencyType, true, l10n),
            SizedBox(
              height: 20.h,
            ),
            if (_categoryExpenses.isEmpty)
              Padding(
                padding: EdgeInsets.all(16.0.w),
                child: Text(
                  l10n.noExpenseThisMonth,
                  style: TextStyle(
                    fontSize: 16.sp,
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
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
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
                            width: 12.w,
                            height: 12.h,
                            decoration: BoxDecoration(
                              color: Colors
                                  .primaries[index % Colors.primaries.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              category.key,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            formatCurrency(category.value, currencyType),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFF5252),
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
      CurrencyType currencyType, int bookId, AppLocalizations l10n) {
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
            _buildPieChart(_categoryIncomes, currencyType, false, l10n),
            SizedBox(
              height: 20.h,
            ),
            if (_categoryIncomes.isEmpty)
              Padding(
                padding: EdgeInsets.all(16.0.w),
                child: Text(
                  l10n.noIncomeThisMonth,
                  style: TextStyle(
                    fontSize: 16.sp,
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
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
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
                            width: 12.w,
                            height: 12.h,
                            decoration: BoxDecoration(
                              color: Colors
                                  .primaries[index % Colors.primaries.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              category.key,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            formatCurrency(category.value, currencyType),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4CAF50),
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
  final AppLocalizations l10n;
  const CustomAppBar(
      {super.key,
      required this.selectedMonth,
      required this.onMonthChanged,
      required this.onMonthTap,
      required this.themeColor,
      required this.l10n});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: themeColor,
      toolbarHeight: 60.h,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.analysis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22.sp,
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                ),
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
                      EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.w),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    DateFormat('MM/yyyy').format(selectedMonth),
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
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

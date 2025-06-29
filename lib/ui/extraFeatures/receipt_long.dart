import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database_helper.dart';
import '../../providers/providers_barrel.dart';
import 'package:flutter/scheduler.dart';
import '../../data/models/more/periodic_invoice.dart';
import 'package:intl/intl.dart';
import '../widget/widget_barrel.dart';
import '../../utils/category_helper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/localization.dart';
import '../widget/custom_snackbar.dart';

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
  final _filterFormKey = GlobalKey<FormState>();
  final _addInvoiceFormKey = GlobalKey<FormState>();

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

  Future<void> _loadBooks() async {
    final userBooks = await _dbHelper.getBooksByUser(1); // user ID = 1
    setState(() {
      books = userBooks;
      if (books.isNotEmpty) {
        selectedBook = books.first;
      }
    });
  }

  // Hàm làm mới trạng thái hóa đơn định kỳ nếu đã đến hạn
  Future<void> _refreshPeriodicInvoices() async {
    final notifier = ref.read(periodicInvoicesProvider.notifier);
    await notifier.refreshPeriodicInvoices();
  }

  void _clearFilters() {
    setState(() {
      _selectedBookFilterId = null;
      _selectedCategoryFilter = null;
      _minAmountController.clear();
      _maxAmountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final allInvoices = ref.watch(periodicInvoicesProvider);
    final themeColor = ref.watch(themeColorProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.periodicInvoices,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: themeColor,
        elevation: 0,
        leading: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30.r),
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, color: Colors.white, size: 24.w),
          ),
        ),
        titleSpacing: 0,
      ),
      body: ref.watch(periodicInvoicesProvider).when(
            data: (allInvoices) {
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
                final amountMatch =
                    (minAmount == null || invoice.amount >= minAmount) &&
                        (maxAmount == null || invoice.amount <= maxAmount);

                return bookMatch && categoryMatch && amountMatch;
              }).toList();

              return Column(
                children: [
                  _buildFilterBar(),
                  Expanded(
                    child: filteredInvoices.isEmpty
                        ? Center(
                            child: Text(
                              l10n.noPeriodicInvoicesYet,
                              style: TextStyle(
                                color: const Color(0xFF9E9E9E),
                                fontSize: 16.sp,
                              ),
                            ),
                          )
                        : ListView(
                            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                            children: [
                              // Hiển thị section hóa đơn vừa làm mới
                              if (filteredInvoices.isNotEmpty) ...[
                                // Duyệt và hiển thị từng hóa đơn vừa làm mới
                                ...filteredInvoices.map((invoice) =>
                                    _buildInvoiceCard(context, invoice)),
                                SizedBox(height: 20.h),
                              ],
                            ],
                          ),
                  ),
                  // Nút thêm hóa đơn mới
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1.r,
                          blurRadius: 4.r,
                          offset: Offset(0, -2.h),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _showAddInvoiceDialog(context, themeColor);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          l10n.createNewInvoice,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => Center(
              child: CircularProgressIndicator(
                color: themeColor,
              ),
            ),
            error: (error, stackTrace) => Center(
              child: Text('Đã xảy ra lỗi: $error',
                  style: TextStyle(fontSize: 14.sp)),
            ),
          ),
    );
  }

  Widget _buildFilterBar() {
    final themeColor = ref.watch(themeColorProvider);
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1.r,
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Icon(Icons.filter_list, color: themeColor, size: 24.w),
        title: Text(
          l10n.filter,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: const Color(0xFF2D3142),
          ),
        ),
        shape: const Border(),
        collapsedShape: const Border(),
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _filterFormKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedBookFilterId,
                              hint: Text(
                                l10n.allBooks,
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              isExpanded: true,
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              items: [
                                DropdownMenuItem<int>(
                                  value: null,
                                  child: Text(
                                    l10n.allBooks,
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                ),
                                ...books
                                    .map<DropdownMenuItem<int>>(
                                        (book) => DropdownMenuItem(
                                              value: book['id'],
                                              child: Text(book['name']),
                                            ))
                                    .toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedBookFilterId = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategoryFilter,
                              hint: Text(
                                l10n.allCategories,
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              isExpanded: true,
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              items: [
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: Text(
                                    l10n.allCategories,
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                ),
                                ...receipLong
                                    .map<DropdownMenuItem<String>>(
                                      (category) => DropdownMenuItem<String>(
                                        value: category['name'],
                                        child: Row(
                                          children: [
                                            Text(category['icon']),
                                            SizedBox(width: 8.w),
                                            Expanded(
                                              child: Text(
                                                CategoryHelper
                                                    .getLocalizedCategoryName(
                                                        category['icon'], l10n),
                                                style:
                                                    TextStyle(fontSize: 13.sp),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategoryFilter = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minAmountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.minimumAmount,
                            labelStyle: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13.sp),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide:
                                  BorderSide(color: themeColor, width: 2.w),
                            ),
                            prefixIcon: Icon(Icons.attach_money,
                                color: themeColor, size: 20.w),
                          ),
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                double.tryParse(value) == null) {
                              return l10n.enterValidNumber;
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: TextFormField(
                          controller: _maxAmountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.maximumAmount,
                            labelStyle: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13.sp),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide:
                                  BorderSide(color: themeColor, width: 2.w),
                            ),
                            prefixIcon: Icon(Icons.attach_money,
                                color: themeColor, size: 20.w),
                          ),
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                double.tryParse(value) == null) {
                              return l10n.enterValidNumber;
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_filterFormKey.currentState!.validate()) {
                          _clearFilters();
                        }
                      },
                      icon: Icon(Icons.clear, size: 20.w),
                      label: Text(l10n.clearFilter,
                          style: TextStyle(fontSize: 15.sp)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
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

  Widget _buildInvoiceCard(BuildContext context, PeriodicInvoice invoice) {
    final isOverdue = invoice.isOverdue();
    final nextDueDate = invoice.nextDueDate ?? invoice.calculateNextDueDate();
    final themeColor = ref.watch(themeColorProvider);
    final l10n = AppLocalizations.of(context);

    // Tìm tên sổ chi tiêu dựa trên bookId
    String bookName = l10n.noBook;
    if (invoice.bookId != null && books.isNotEmpty) {
      try {
        final book = books.firstWhere((b) => b['id'] == invoice.bookId);
        bookName = book['name'];
      } catch (e) {
        bookName = l10n.bookNotExists;
      }
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      splashColor: const Color.fromARGB(0, 255, 255, 255),
      highlightColor: const Color.fromARGB(0, 255, 255, 255),
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.sp),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(24.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.sp),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      padding: EdgeInsets.all(16.sp),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        size: 36.sp,
                        color: themeColor,
                      ),
                    ),
                    SizedBox(height: 16.sp),
                    // Title
                    Text(
                      invoice.name,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.sp),
                    // Status chip
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isOverdue
                            ? Colors.red.withOpacity(0.1)
                            : invoice.isPaid
                                ? Colors.green.withOpacity(0.1)
                                : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        isOverdue
                            ? l10n.overdue
                            : invoice.isPaid
                                ? l10n.paid
                                : l10n.pendingPayment,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: isOverdue
                              ? Colors.red
                              : invoice.isPaid
                                  ? Colors.green
                                  : Colors.blue,
                        ),
                      ),
                    ),
                    SizedBox(height: 18.sp),
                    // Amount
                    Text(
                      formatCurrency(
                          invoice.amount, ref.watch(currencyProvider)),
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: isOverdue
                            ? Colors.red
                            : invoice.isPaid
                                ? Colors.green
                                : themeColor,
                      ),
                    ),
                    SizedBox(height: 18.sp),
                    // Details
                    _buildDetailRow(Icons.calendar_today, l10n.frequency,
                        _getFrequencyText(invoice.frequency, context)),
                    SizedBox(height: 10.h),
                    _buildDetailRow(Icons.book, l10n.expenseBook, bookName),
                    if (nextDueDate != null) ...[
                      SizedBox(height: 10.h),
                      _buildDetailRow(Icons.schedule, 'Next Due Date',
                          DateFormat('dd/MM/yyyy').format(nextDueDate)),
                    ],
                    SizedBox(height: 24.sp),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48.sp,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey[300]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.sp),
                                ),
                              ),
                              child: Text(
                                l10n.cancel,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.sp),
                        Expanded(
                          child: Container(
                            height: 48.sp,
                            child: ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(periodicInvoicesProvider.notifier)
                                    .removePeriodicInvoice(invoice.id);
                                Future.delayed(Duration.zero, () {
                                  Navigator.pop(context);
                                  CustomSnackBar.showSuccess(
                                    context,
                                    message: l10n.success,
                                  );
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[500],
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.sp),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.delete_outline,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 6),
                                  Text(
                                    l10n.delete,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                  size: 24.w,
                ),
              ),
              SizedBox(width: 16.w),
              // Content section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and status row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            invoice.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A1A),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: isOverdue
                                ? Colors.red.withOpacity(0.1)
                                : invoice.isPaid
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            isOverdue
                                ? l10n.overdue
                                : invoice.isPaid
                                    ? l10n.paid
                                    : l10n.pendingPayment,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: isOverdue
                                  ? Colors.red
                                  : invoice.isPaid
                                      ? Colors.green
                                      : Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            formatCurrency(
                                invoice.amount, ref.watch(currencyProvider)),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _getFrequencyText(invoice.frequency, context),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for detail row in dialog
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24.w, color: Colors.grey.shade500),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              fontSize: 16.sp),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontSize: 16.sp),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _getFrequencyText(String frequency, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (frequency) {
      case 'daily':
        return l10n.daily;
      case 'weekly':
        return l10n.weekly;
      case 'monthly':
        return l10n.monthly;
      case 'yearly':
        return l10n.yearly;
      default:
        return frequency;
    }
  }

  String _getCategoryIconFromName(String categoryName) {
    // Map category names to their corresponding icons
    switch (categoryName) {
      case 'Ăn uống':
        return '🍔';
      case 'Di chuyển':
        return '🚗';
      case 'Mua sắm':
        return '🛍';
      case 'Giải trí':
        return '🎮';
      case 'Học tập':
        return '📚';
      case 'Làm đẹp':
        return '💅';
      case 'Sinh hoạt':
        return '🏠';
      case 'Lương':
        return '💰';
      case 'Thưởng':
        return '🎁';
      case 'Đầu tư':
        return '📈';
      default:
        return '💸'; // Default icon for unknown categories
    }
  }

  void _showAddInvoiceDialog(BuildContext context, Color themeColor) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedFrequency = 'monthly';
    String? selectedCategory;
    Map<String, dynamic>? selectedBookForInvoice = selectedBook;
    final currencyType = ref.watch(currencyProvider);
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Form(
                      key: _addInvoiceFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40.w,
                            height: 4.h,
                            margin: EdgeInsets.only(top: 12.h, bottom: 20.h),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Column(
                              children: [
                                Text(
                                  l10n.createPeriodicInvoice,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2D3142),
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: nameController,
                                        decoration: InputDecoration(
                                          labelText: l10n.invoiceName,
                                          labelStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.sp,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                            borderSide: BorderSide(
                                              color: themeColor,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                            borderSide: BorderSide(
                                              color: themeColor,
                                              width: 2.w,
                                            ),
                                          ),
                                          prefixIcon: Icon(Icons.receipt,
                                              color: themeColor),
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return l10n.pleaseEnterInvoiceName;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8.w,
                                    ),
                                    Expanded(
                                      child: DropdownButtonFormField<int>(
                                        value: selectedBookForInvoice?['id'],
                                        decoration: InputDecoration(
                                          labelText: l10n.expenseBook,
                                          labelStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.sp,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                            borderSide: BorderSide(
                                              color: themeColor,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                            borderSide: BorderSide(
                                              color: themeColor,
                                              width: 2.w,
                                            ),
                                          ),
                                          prefixIcon: Icon(Icons.book,
                                              color: themeColor),
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
                                                  books.firstWhere(
                                                      (b) => b['id'] == value);
                                            });
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                TextFormField(
                                  controller: amountController,
                                  decoration: InputDecoration(
                                    labelText: l10n.paymentAmount,
                                    labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14.sp,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      borderSide: BorderSide(
                                        color: themeColor,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      borderSide: BorderSide(
                                        color: themeColor,
                                        width: 2.w,
                                      ),
                                    ),
                                    prefixIcon: Icon(Icons.attach_money,
                                        color: themeColor),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    CurrencyInputFormatter(currencyType)
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return l10n.enterAmount;
                                    }
                                    final amount =
                                        getNumericValueFromFormattedText(value);
                                    if (amount <= 0) {
                                      return l10n.amountMustBeGreaterThanZero;
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        isExpanded: true,
                                        value: selectedFrequency,
                                        decoration: InputDecoration(
                                          labelText: l10n.frequency,
                                          labelStyle: TextStyle(
                                            color: themeColor,
                                            fontSize: 14.sp,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                            borderSide: BorderSide(
                                              color: themeColor,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                            borderSide: BorderSide(
                                              color: themeColor,
                                              width: 2.w,
                                            ),
                                          ),
                                          prefixIcon: Icon(Icons.schedule,
                                              color: themeColor),
                                        ),
                                        items: [
                                          DropdownMenuItem(
                                              value: 'daily',
                                              child: Text(
                                                l10n.daily,
                                                style: TextStyle(fontSize: 13),
                                              )),
                                          DropdownMenuItem(
                                              value: 'weekly',
                                              child: Text(
                                                l10n.weekly,
                                                style: TextStyle(fontSize: 13),
                                              )),
                                          DropdownMenuItem(
                                              value: 'monthly',
                                              child: Text(
                                                l10n.monthly,
                                                style: TextStyle(fontSize: 13),
                                              )),
                                          DropdownMenuItem(
                                              value: 'yearly',
                                              child: Text(
                                                l10n.yearly,
                                                style: TextStyle(fontSize: 13),
                                              )),
                                        ],
                                        onChanged: (value) {
                                          if (value != null) {
                                            setModalState(() {
                                              selectedFrequency = value;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: selectedCategory,
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          labelText: l10n.category,
                                          labelStyle: TextStyle(
                                            color: themeColor,
                                            fontSize: 14.sp,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                            borderSide: BorderSide(
                                              color: themeColor,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                            borderSide: BorderSide(
                                              color: themeColor,
                                              width: 2.w,
                                            ),
                                          ),
                                          prefixIcon: Icon(Icons.category,
                                              color: themeColor),
                                        ),
                                        items: receipLong
                                            .map<DropdownMenuItem<String>>(
                                              (category) =>
                                                  DropdownMenuItem<String>(
                                                value: category['name'],
                                                child: Row(
                                                  children: [
                                                    Text(category['icon']),
                                                    SizedBox(width: 8.w),
                                                    Expanded(
                                                      child: Text(
                                                        CategoryHelper
                                                            .getLocalizedCategoryName(
                                                                category[
                                                                    'icon'],
                                                                l10n),
                                                        style: TextStyle(
                                                            fontSize: 13.sp),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
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
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                TextFormField(
                                  controller: descriptionController,
                                  decoration: InputDecoration(
                                    labelText: l10n.details,
                                    labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14.sp,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      borderSide: BorderSide(
                                        color: themeColor,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      borderSide: BorderSide(
                                        color: themeColor,
                                        width: 2.w,
                                      ),
                                    ),
                                    prefixIcon: Icon(Icons.description,
                                        color: themeColor),
                                  ),
                                  maxLines: 1,
                                ),
                                SizedBox(height: 24.h),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_addInvoiceFormKey.currentState!
                                          .validate()) {
                                        try {
                                          final categoryIcon =
                                              receipLong.firstWhere(
                                            (cat) =>
                                                cat['name'] == selectedCategory,
                                          )['icon'];

                                          final newInvoice = PeriodicInvoice(
                                            id: DateTime.now()
                                                .millisecondsSinceEpoch
                                                .toString(),
                                            name: nameController.text.trim(),
                                            amount:
                                                getNumericValueFromFormattedText(
                                                    amountController.text),
                                            startDate: DateTime.now(),
                                            frequency: selectedFrequency,
                                            category: categoryIcon,
                                            description: descriptionController
                                                .text
                                                .trim(),
                                            bookId:
                                                selectedBookForInvoice!['id'],
                                          );

                                          await ref
                                              .read(periodicInvoicesProvider
                                                  .notifier)
                                              .addPeriodicInvoice(newInvoice);
                                          Navigator.pop(context);

                                          // Thông báo thành công
                                          CustomSnackBar.showSuccess(
                                            context,
                                            message: l10n
                                                .invoiceAddedSuccessfullyWith(
                                                    selectedBookForInvoice![
                                                        'name']),
                                          );
                                        } catch (e) {
                                          CustomSnackBar.showError(
                                            context,
                                            message:
                                                l10n.errorCreatingInvoiceWith(
                                                    e.toString()),
                                          );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: themeColor,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      l10n.createInvoice,
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

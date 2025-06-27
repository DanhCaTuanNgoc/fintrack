import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/book_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/more/transaction_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/more/notifications_provider.dart';
import 'more/notification.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 🔀 Danh sách các màu chủ đạo có thể chọn
final List<Color> primaryVariants = [
  Color(0xFF6C63FF), // Tím
  Color(0xFF2196F3), // Xanh dương
  Color(0xFF4CAF50), // Xanh lá
  Color(0xFFFF5722), // Cam
  Color(0xFFFF4081), // Hồng
  Color(0xFF9C27B0), // Tím đậm
  Color(0xFF3F51B5), // Indigo
  Color(0xFF00BCD4), // Cyan
  Color(0xFFFF9800), // Cam sáng
  Color(0xFF795548), // Nâu
  Color(0xFF607D8B), // Xám xanh
];

final List<String> _themeColorNames = [
  'Tím',
  'Xanh dương',
  'Lá',
  'Cam',
  'Hồng',
  'Tím đậm',
  'Indigo',
  'Cyan',
  'Cam sáng',
  'Nâu',
  'Xám xanh',
];

class More extends ConsumerStatefulWidget {
  const More({super.key});

  @override
  _MoreState createState() => _MoreState();
}

class _MoreState extends ConsumerState<More> {
  int? _currentColorIndex;

  @override
  void initState() {
    super.initState();
    _loadThemeColor();
  }

  Future<void> _loadThemeColor() async {
    final prefs = await SharedPreferences.getInstance();
    final int index = prefs.getInt('theme_color') ?? 0;

    setState(() {
      _currentColorIndex = index;
    });
  }

  Future<void> removeData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Logger.root.info('\x1B[32mSuccessfully cleared SharedPreferences\x1B[0m');
  }

  @override
  Widget build(BuildContext context) {
    // Lấy đơn vị tiền tệ hiện tại từ provider
    final currentCurrency = ref.watch(currencyProvider);

    // Lấy màu nền hiện tại
    final themeColor = ref.watch(themeColorProvider);

    return Scaffold(
      backgroundColor: Colors.white, // Áp dụng màu nền
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: EdgeInsets.only(left: 14.w),
          child: Text(
            'Cài đặt',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22.sp,
              color: const Color(0xFF2D3142),
            ),
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.delete_forever, color: Color(0xFF2D3142)),
        //     onPressed: () async {
        //       await removeData();
        //       await ref.read(booksProvider.notifier).deleteAllBooks();
        //     },
        //   ),
        // ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(children: [_buildSettingsCard(currentCurrency)]),
      ),
    );
  }

  Widget _buildSettingsCard(CurrencyType currentCurrency) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2.r,
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.language,
            title: 'Ngôn ngữ',
            onTap: () {
              _showLanguageDialog();
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.currency_exchange,
            title: 'Tiền tệ',
            subtitle: currentCurrency.displayName,
            onTap: () {
              _showCurrencyDialog(currentCurrency);
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.color_lens,
            title: 'Màu chủ đạo',
            subtitle: _themeColorNames[_currentColorIndex ?? 0],
            onTap: () {
              _showBackgroundColorDialog();
            },
          ),
          _buildDivider(),
          Consumer(
            builder: (context, ref, child) {
              final notifications = ref.watch(notificationsProvider);
              final unreadCount = notifications.where((n) => !n.isRead).length;

              return _buildSettingItem(
                icon: Icons.notifications,
                title: 'Thông báo',
                badge: unreadCount > 0 ? unreadCount.toString() : null,
                onTap: () {
                  _showNotificationDialog();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child:
          Divider(height: 1.h, thickness: 1.h, color: const Color(0xFFEEEEEE)),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: const Color(0xFF2D3142), size: 24.w),
                ),
                if (badge != null && badge.isNotEmpty)
                  Positioned(
                    right: -5.w,
                    top: -5.h,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE57373),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white, width: 1.w),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2D3142),
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.w,
              color: const Color(0xFF9E9E9E),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Chọn ngôn ngữ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3142),
            fontSize: 18.sp,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption(
              title: 'Tiếng Việt',
              isSelected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildDialogOption(
              title: 'English',
              isSelected: false,
              onTap: () {
                Navigator.pop(context);
                // Áp dụng ngôn ngữ tại đây
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog(CurrencyType currentCurrency) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Chọn tiền tệ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3142),
            fontSize: 18.sp,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption(
              title: 'VND (₫)',
              isSelected: currentCurrency == CurrencyType.vnd,
              onTap: () {
                _updateCurrency(CurrencyType.vnd);
                Navigator.pop(context);
              },
            ),
            _buildDialogOption(
              title: 'USD (\$)',
              isSelected: currentCurrency == CurrencyType.usd,
              onTap: () {
                _updateCurrency(CurrencyType.usd);
                Navigator.pop(context);
              },
            ),
            _buildDialogOption(
              title: 'EUR (€)',
              isSelected: currentCurrency == CurrencyType.eur,
              onTap: () {
                _updateCurrency(CurrencyType.eur);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBackgroundColorDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Chọn màu chủ đạo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3142),
            fontSize: 18.sp,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(primaryVariants.length, (index) {
            return _buildDialogOption(
              title: _themeColorNames[index],
              isSelected: _currentColorIndex == index,
              color: primaryVariants[index],
              onTap: () {
                setState(() {
                  _currentColorIndex = index;
                });

                // Lưu màu mới
                ref.read(themeColorProvider.notifier).setThemeColor(index);

                // Đóng dialog
                Navigator.pop(context);

                // Thông báo cho người dùng
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đã đổi màu nền thành ${_themeColorNames[index]}',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    backgroundColor: const Color(0xFF4CAF50),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  void _updateCurrency(CurrencyType newCurrency) async {
    final oldCurrency = ref.read(currencyProvider);

    if (oldCurrency != newCurrency) {
      // Lấy danh sách giao dịch hiện tại
      final transactionNotifier = ref.read(transactionsProvider.notifier);
      await transactionNotifier.updateAllTransactionCurrencies(
        oldCurrency,
        newCurrency,
      );

      // Cập nhật đơn vị tiền tệ mới
      ref.read(currencyProvider.notifier).setCurrency(newCurrency);

      // Hiển thị thông báo cho người dùng
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã chuyển sang ${newCurrency.displayName} và cập nhật tất cả giao dịch',
            style: TextStyle(fontSize: 16.sp),
          ),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
    }
  }

  Widget _buildDialogOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        child: Row(
          children: [
            if (color != null)
              Container(
                width: 24.w,
                height: 24.w,
                margin: EdgeInsets.only(right: 12.w),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
              ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF2D3142),
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: const Color(0xFF4CAF50),
                size: 20.w,
              ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationScreen(),
      ),
    );
  }
}

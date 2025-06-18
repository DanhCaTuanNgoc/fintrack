import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/book_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';
import 'more/notification.dart';
import 'more/receipt_long.dart';

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
        title: const Padding(
          padding: EdgeInsets.only(left: 14.0),
          child: Text(
            'Cài đặt',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Color(0xFF2D3142),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Color(0xFF2D3142)),
            onPressed: () async {
              await removeData();
              await ref.read(booksProvider.notifier).deleteAllBooks();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [_buildSettingsCard(currentCurrency)]),
      ),
    );
  }

  Widget _buildSettingsCard(CurrencyType currentCurrency) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 16,
            offset: const Offset(0, 4),
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
            subtitle: _themeColorNames[_currentColorIndex!],
            onTap: () {
              _showBackgroundColorDialog();
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.receipt_long,
            title: 'Hóa đơn định kì',
            onTap: () {
              _showPeriodicInvoiceDialog();
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
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF2D3142), size: 24),
                ),
                if (badge != null)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF9E9E9E),
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
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Chọn ngôn ngữ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3142),
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
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Chọn tiền tệ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3142),
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
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Chọn màu chủ đạo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3142),
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
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          children: [
            if (color != null)
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300),
                ),
              ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF2D3142),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showPeriodicInvoiceDialog() {
    showDialog(
      context: context,
      builder: (context) => const ReceiptLongScreen(),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/book_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/transaction_provider.dart';

// Provider lưu trữ màu nền hiện tại
final backgroundColorProvider = StateProvider<Color>((ref) {
  return const Color(0xFFF8F9FA); // Màu mặc định
});

class More extends ConsumerStatefulWidget {
  const More({super.key});

  @override
  _MoreState createState() => _MoreState();
}

class _MoreState extends ConsumerState<More> {
  // Danh sách các màu nền có sẵn
  final List<Color> _backgroundColors = [
    const Color(0xFFF8F9FA), // Xám nhạt - mặc định
    const Color(0xFFE3F2FD), // Xanh dương nhạt
    const Color(0xFFF3E5F5), // Tím nhạt
    const Color(0xFFFFF8E1), // Vàng nhạt
    const Color(0xFFE8F5E9), // Xanh lá nhạt
  ];

  // Tên các màu
  final List<String> _colorNames = [
    'Xám nhạt',
    'Xanh dương nhạt',
    'Tím nhạt',
    'Vàng nhạt',
    'Xanh lá nhạt',
  ];

  // Chỉ số màu hiện tại
  int _currentColorIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedColor();
  }

  // Tải màu nền đã lưu
  Future<void> _loadSavedColor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIndex = prefs.getInt('background_color_index') ?? 0;
      if (savedIndex < _backgroundColors.length) {
        setState(() {
          _currentColorIndex = savedIndex;
        });
        ref.read(backgroundColorProvider.notifier).state =
            _backgroundColors[savedIndex];
      }
    } catch (e) {
      print('Lỗi khi tải màu nền: $e');
    }
  }

  // Lưu màu nền đã chọn
  Future<void> _saveColorIndex(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('background_color_index', index);
    } catch (e) {
      print('Lỗi khi lưu màu nền: $e');
    }
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
    final backgroundColor = ref.watch(backgroundColorProvider);

    return Scaffold(
      backgroundColor: backgroundColor, // Áp dụng màu nền
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF2D3142),
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
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.settings,
            title: 'Cài đặt',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng đang phát triển')),
              );
            },
          ),
          _buildDivider(),
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
            title: 'Màu nền',
            subtitle: _colorNames[_currentColorIndex],
            onTap: () {
              _showBackgroundColorDialog();
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF2D3142), size: 24),
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
      builder:
          (context) => AlertDialog(
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
      builder:
          (context) => AlertDialog(
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

  void _showBackgroundColorDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Chọn màu nền',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_backgroundColors.length, (index) {
                return _buildDialogOption(
                  title: _colorNames[index],
                  isSelected: _currentColorIndex == index,
                  color: _backgroundColors[index],
                  onTap: () {
                    setState(() {
                      _currentColorIndex = index;
                    });

                    // Cập nhật màu toàn cục
                    ref.read(backgroundColorProvider.notifier).state =
                        _backgroundColors[index];

                    // Lưu màu mới
                    _saveColorIndex(index);

                    // Đóng dialog
                    Navigator.pop(context);

                    // Thông báo cho người dùng
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Đã đổi màu nền thành ${_colorNames[index]}',
                        ),
                        backgroundColor: _backgroundColors[index],
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
                  color:
                      isSelected
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
}

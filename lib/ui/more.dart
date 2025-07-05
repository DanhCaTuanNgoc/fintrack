import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/currency_provider.dart';
import '../providers/more/transaction_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/more/notifications_provider.dart';
import '../providers/more/locale_provider.dart';
import 'more/notification.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/localization.dart';
import '../utils/languages.dart';
import 'widget/components/custom_snackbar.dart';

// 🔀 Danh sách các màu chủ đạo có thể chọn
const List<Color> primaryVariants = [
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
  Color(0xFF2D3142), // Đen có độ bóng
];

class More extends ConsumerStatefulWidget {
  const More({super.key});

  @override
  ConsumerState<More> createState() => _MoreState();
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

    // Lấy ngôn ngữ hiện tại
    final currentLanguage = ref.watch(localeProvider);

    // Lấy AppLocalizations
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white, // Áp dụng màu nền
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: EdgeInsets.only(left: 14.w),
          child: Text(
            l10n.settings,
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
        child: Column(children: [
          _buildSettingsCard(currentCurrency, currentLanguage, l10n)
        ]),
      ),
    );
  }

  Widget _buildSettingsCard(CurrencyType currentCurrency,
      AppLanguage currentLanguage, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
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
            title: l10n.language,
            subtitle: currentLanguage.displayName,
            onTap: () {
              _showLanguageDialog(l10n);
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.currency_exchange,
            title: l10n.currency,
            subtitle: currentCurrency.displayName,
            onTap: () {
              _showCurrencyDialog(currentCurrency);
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.color_lens,
            title: l10n.themeColor,
            subtitle: _getThemeColorName(l10n),
            onTap: () {
              _showBackgroundColorDialog(l10n);
            },
          ),
          _buildDivider(),
          Consumer(
            builder: (context, ref, child) {
              final notifications = ref.watch(notificationsProvider);
              final unreadCount = notifications.where((n) => !n.isRead).length;

              return _buildSettingItem(
                icon: Icons.notifications,
                title: l10n.notifications,
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

  String _getThemeColorName(AppLocalizations l10n) {
    final colorNames = [
      l10n.purple,
      l10n.blue,
      l10n.green,
      l10n.orange,
      l10n.pink,
      l10n.darkPurple,
      l10n.indigo,
      l10n.cyan,
      l10n.brightOrange,
      l10n.brown,
      l10n.blueGrey,
      l10n.black,
    ];
    return colorNames[_currentColorIndex ?? 0];
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
    Widget? trailing,
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
            trailing ??
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

  void _showLanguageDialog(AppLocalizations l10n) {
    final currentLanguage = ref.read(localeProvider);
    final supportedLanguages = ref.read(supportedLanguagesProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          l10n.chooseLanguage,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3142),
            fontSize: 18.sp,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: supportedLanguages.map((language) {
            return _buildDialogOption(
              title: language.displayName,
              isSelected: currentLanguage == language,
              onTap: () async {
                await ref.read(localeProvider.notifier).setLanguage(language);
                if (!mounted) return;
                Navigator.pop(context);
                Future.delayed(Duration.zero, () {
                  if (mounted) {
                    CustomSnackBar.showSuccess(
                      context,
                      message: _getLanguageChangeMessage(language, l10n),
                    );
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getLanguageChangeMessage(
      AppLanguage language, AppLocalizations l10n) {
    switch (language) {
      case AppLanguage.vietnamese:
        return l10n.switchedToVietnamese;
      case AppLanguage.english:
        return l10n.switchedToEnglish;
      default:
        return 'Switched to ${language.displayName}';
    }
  }

  void _showCurrencyDialog(CurrencyType currentCurrency) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          l10n.currency,
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

  void _showBackgroundColorDialog(AppLocalizations l10n) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          l10n.chooseThemeColor,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3142),
            fontSize: 18.sp,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 330.h, // Cố định chiều cao để có thể scroll
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Grid layout cho màu sắc
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: primaryVariants.length,
                  itemBuilder: (context, index) {
                    return _buildColorGridItem(
                      color: primaryVariants[index],
                      isSelected: _currentColorIndex == index,
                      title: _getColorNameByIndex(index, l10n),
                      onTap: () {
                        setState(() {
                          _currentColorIndex = index;
                        });

                        // Lưu màu mới
                        ref
                            .read(themeColorProvider.notifier)
                            .setThemeColor(index);

                        // Đóng dialog
                        Navigator.pop(context);

                        // Thông báo cho người dùng
                        CustomSnackBar.showSuccess(
                          context,
                          message: l10n.themeColorChanged(
                              _getColorNameByIndex(index, l10n)),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorGridItem({
    required Color color,
    required bool isSelected,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.r),
          border: isSelected
              ? Border.all(color: const Color(0xFF4CAF50), width: 3.w)
              : Border.all(color: Colors.grey.shade300, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Gradient overlay để text dễ đọc hơn
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
            // Check icon nếu được chọn
            if (isSelected)
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12.w,
                  ),
                ),
              ),
            // Tên màu ở dưới
            Positioned(
              bottom: 8.h,
              left: 8.w,
              right: 8.w,
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      offset: Offset(0, 1.h),
                      blurRadius: 2.r,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getColorNameByIndex(int index, AppLocalizations l10n) {
    final colorNames = [
      l10n.purple,
      l10n.blue,
      l10n.green,
      l10n.orange,
      l10n.pink,
      l10n.darkPurple,
      l10n.indigo,
      l10n.cyan,
      l10n.brightOrange,
      l10n.brown,
      l10n.blueGrey,
      l10n.black,
    ];
    return colorNames[index];
  }

  void _updateCurrency(CurrencyType newCurrency) async {
    final oldCurrency = ref.read(currencyProvider);
    final l10n = AppLocalizations.of(context);

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
      if (mounted) {
        CustomSnackBar.showSuccess(
          context,
          message: l10n.currencyChanged(newCurrency.displayName),
        );
      }
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
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        margin: EdgeInsets.symmetric(vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F8F0) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: isSelected
              ? Border.all(color: const Color(0xFF4CAF50), width: 2.w)
              : null,
        ),
        child: Row(
          children: [
            if (color != null)
              Container(
                width: 32.w,
                height: 32.w,
                margin: EdgeInsets.only(right: 16.w),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade300, width: 1.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF2D3142),
                ),
              ),
            ),
            if (isSelected)
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16.w,
                ),
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

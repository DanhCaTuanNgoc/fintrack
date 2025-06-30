import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _defaultColor = Color(0xFF6C63FF); // Màu đen có độ bóng mặc định
// 🔀 Danh sách các màu chủ đạo có thể chọn
final List<Color> _primaryVariants = [
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

// Để sử dụng ngoài file khác
List<Color> get primaryVariants => _primaryVariants;

final themeColorProvider = StateNotifierProvider<ThemeColorNotifier, Color>(
  (ref) => ThemeColorNotifier(),
);

class ThemeColorNotifier extends StateNotifier<Color> {
  ThemeColorNotifier() : super(_defaultColor) {
    _loadThemeColor();
  }

  Future<void> _loadThemeColor() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('theme_color') ?? 0;
    if (index >= 0 && index < _primaryVariants.length) {
      state = _primaryVariants[index];
    }
  }

  Future<void> setThemeColor(int index) async {
    if (index >= 0 && index < _primaryVariants.length) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_color', index);
      state = _primaryVariants[index];
    }
  }

  int get currentIndex => _primaryVariants.indexOf(state);
}

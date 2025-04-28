import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Danh sách màu nền có sẵn
final List<Color> backgroundColors = [
  const Color(0xFFF8F9FA), // Xám nhạt (mặc định)
  const Color(0xFFE3F2FD), // Xanh dương nhạt
  const Color(0xFFF3E5F5), // Tím nhạt
  const Color(0xFFFFF8E1), // Vàng nhạt
  const Color(0xFFE8F5E9), // Xanh lá nhạt
];

// Tên các màu nền
final List<String> colorNames = [
  'Xám nhạt',
  'Xanh dương nhạt',
  'Tím nhạt',
  'Vàng nhạt',
  'Xanh lá nhạt',
];

// Provider cho màu nền hiện tại
final backgroundColorProvider =
    StateNotifierProvider<BackgroundColorNotifier, Color>((ref) {
      return BackgroundColorNotifier();
    });

// Provider cho chỉ số màu nền hiện tại
final backgroundColorIndexProvider = StateProvider<int>((ref) => 0);

// Provider lưu trữ và quản lý màu nền
class BackgroundColorNotifier extends StateNotifier<Color> {
  BackgroundColorNotifier() : super(backgroundColors[0]) {
    _loadSavedColor();
  }

  // Tải màu nền đã lưu
  Future<void> _loadSavedColor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIndex = prefs.getInt('background_color_index') ?? 0;
      if (savedIndex < backgroundColors.length) {
        state = backgroundColors[savedIndex];
      }
    } catch (e) {
      print('Lỗi khi tải màu nền: $e');
    }
  }

  // Đặt màu nền mới
  Future<void> setColor(int index) async {
    if (index >= 0 && index < backgroundColors.length) {
      state = backgroundColors[index];
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('background_color_index', index);
      } catch (e) {
        print('Lỗi khi lưu màu nền: $e');
      }
    }
  }
}

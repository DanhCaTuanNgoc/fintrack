import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/languages.dart';
import '../../data/database/database_helper.dart';
import '../../utils/localization.dart';

/// Provider quản lý ngôn ngữ hiện tại
class LocaleNotifier extends StateNotifier<AppLanguage> {
  LocaleNotifier() : super(SupportedLanguages.defaultLanguage) {
    _loadLanguage();
  }

  /// Tải ngôn ngữ từ SharedPreferences
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ??
        SupportedLanguages.defaultLanguage.languageCode;

    final language = SupportedLanguages.fromLanguageCode(languageCode) ??
        SupportedLanguages.defaultLanguage;

    state = language;
  }

  /// Thay đổi ngôn ngữ
  Future<void> setLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', language.languageCode);
    state = language;

    // Cập nhật categories khi ngôn ngữ thay đổi
    try {
      final dbHelper = DatabaseHelper.instance;
      final l10n = AppLocalizations(language.locale);
      await dbHelper.updateCategoriesOnLanguageChange(l10n);
    } catch (e) {
      // Log error nhưng không làm crash app
      print('Error updating categories on language change: $e');
    }
  }

  /// Lấy ngôn ngữ hiện tại
  AppLanguage get currentLanguage => state;

  /// Lấy Locale hiện tại
  Locale get currentLocale => state.locale;

  /// Kiểm tra xem có phải ngôn ngữ mặc định không
  bool get isDefaultLanguage => state == SupportedLanguages.defaultLanguage;
}

/// Provider cho ngôn ngữ hiện tại
final localeProvider = StateNotifierProvider<LocaleNotifier, AppLanguage>(
  (ref) => LocaleNotifier(),
);

/// Provider cho Locale object
final localeObjectProvider = Provider<Locale>((ref) {
  final language = ref.watch(localeProvider);
  return language.locale;
});

/// Provider cho danh sách ngôn ngữ được hỗ trợ
final supportedLanguagesProvider = Provider<List<AppLanguage>>((ref) {
  return SupportedLanguages.all;
});

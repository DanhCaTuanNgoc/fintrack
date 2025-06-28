import 'package:flutter/material.dart';

/// Enum định nghĩa tất cả các ngôn ngữ được hỗ trợ
enum AppLanguage {
  vietnamese,
  english,
  // Thêm ngôn ngữ mới ở đây
  // french,
  // german,
  // spanish,
  // chinese,
  // japanese,
  // korean,
}

/// Extension cung cấp thông tin cho mỗi ngôn ngữ
extension AppLanguageExtension on AppLanguage {
  /// Mã ngôn ngữ ISO 639-1
  String get languageCode {
    switch (this) {
      case AppLanguage.vietnamese:
        return 'vi';
      case AppLanguage.english:
        return 'en';
      // Thêm case cho ngôn ngữ mới
      // case AppLanguage.french:
      //   return 'fr';
    }
  }

  /// Mã quốc gia ISO 3166-1 alpha-2
  String get countryCode {
    switch (this) {
      case AppLanguage.vietnamese:
        return 'VN';
      case AppLanguage.english:
        return 'US';
      // Thêm case cho ngôn ngữ mới
      // case AppLanguage.french:
      //   return 'FR';
    }
  }

  /// Tên hiển thị của ngôn ngữ trong ngôn ngữ đó
  String get nativeName {
    switch (this) {
      case AppLanguage.vietnamese:
        return 'Tiếng Việt';
      case AppLanguage.english:
        return 'English';
      // Thêm case cho ngôn ngữ mới
      // case AppLanguage.french:
      //   return 'Français';
    }
  }

  /// Tên hiển thị của ngôn ngữ bằng tiếng Anh
  String get englishName {
    switch (this) {
      case AppLanguage.vietnamese:
        return 'Vietnamese';
      case AppLanguage.english:
        return 'English';
      // Thêm case cho ngôn ngữ mới
      // case AppLanguage.french:
      //   return 'French';
    }
  }

  /// Locale object cho Flutter
  Locale get locale {
    return Locale(languageCode, countryCode);
  }

  /// Tên hiển thị (sử dụng tên bản địa)
  String get displayName => nativeName;
}

/// Class quản lý danh sách ngôn ngữ được hỗ trợ
class SupportedLanguages {
  /// Danh sách tất cả ngôn ngữ được hỗ trợ
  static const List<AppLanguage> all = [
    AppLanguage.vietnamese,
    AppLanguage.english,
    // Thêm ngôn ngữ mới vào đây
    // AppLanguage.french,
  ];

  /// Ngôn ngữ mặc định
  static const AppLanguage defaultLanguage = AppLanguage.vietnamese;

  /// Danh sách Locale được hỗ trợ cho Flutter
  static List<Locale> get supportedLocales {
    return all.map((lang) => lang.locale).toList();
  }

  /// Tìm ngôn ngữ theo mã ngôn ngữ
  static AppLanguage? fromLanguageCode(String languageCode) {
    try {
      return all.firstWhere((lang) => lang.languageCode == languageCode);
    } catch (e) {
      return null;
    }
  }

  /// Tìm ngôn ngữ theo Locale
  static AppLanguage? fromLocale(Locale locale) {
    return fromLanguageCode(locale.languageCode);
  }

  /// Kiểm tra xem một Locale có được hỗ trợ không
  static bool isSupported(Locale locale) {
    return fromLocale(locale) != null;
  }

  /// Lấy ngôn ngữ fallback khi không tìm thấy ngôn ngữ phù hợp
  static AppLanguage getFallbackLanguage() {
    return defaultLanguage;
  }
}

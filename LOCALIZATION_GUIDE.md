# Hướng dẫn sử dụng tính năng đa ngôn ngữ

## Tổng quan

Ứng dụng Fintrack đã được tích hợp tính năng đa ngôn ngữ với cấu trúc linh hoạt, dễ dàng thêm ngôn ngữ mới. Hệ thống sử dụng `flutter_localizations` và một hệ thống quản lý ngôn ngữ tùy chỉnh.

## Các ngôn ngữ được hỗ trợ

- **Tiếng Việt** (vi-VN) - Ngôn ngữ mặc định
- **Tiếng Anh** (en-US)
- *Có thể dễ dàng thêm ngôn ngữ mới*

## Cấu trúc file

### 1. Quản lý ngôn ngữ
- `lib/utils/languages.dart` - Định nghĩa enum AppLanguage và class SupportedLanguages
- `lib/providers/locale_provider.dart` - Provider quản lý trạng thái ngôn ngữ

### 2. Chuỗi văn bản
- `lib/l10n/strings_vi.dart` - Tất cả chuỗi tiếng Việt
- `lib/l10n/strings_en.dart` - Tất cả chuỗi tiếng Anh
- `lib/l10n/strings_barrel.dart` - Export tất cả file strings
- `lib/l10n/strings_template.dart` - Template để tạo ngôn ngữ mới

### 3. Localization
- `lib/utils/localization.dart` - Class AppLocalizations và AppLocalizationsDelegate

### 4. Cấu hình trong main.dart
- Đã tích hợp `flutter_localizations` và `AppLocalizationsDelegate`

## Cách sử dụng

### 1. Lấy chuỗi đã được dịch

```dart
import '../utils/localization.dart';

// Trong widget
final l10n = AppLocalizations.of(context);
Text(l10n.settings) // Hiển thị "Cài đặt" hoặc "Settings" tùy theo ngôn ngữ
```

### 2. Thay đổi ngôn ngữ

```dart
// Thay đổi sang tiếng Anh
ref.read(localeProvider.notifier).setLanguage(AppLanguage.english);

// Thay đổi sang tiếng Việt
ref.read(localeProvider.notifier).setLanguage(AppLanguage.vietnamese);
```

### 3. Lấy ngôn ngữ hiện tại

```dart
final currentLanguage = ref.watch(localeProvider);
print(currentLanguage.displayName); // "Tiếng Việt" hoặc "English"
```

### 4. Lấy danh sách ngôn ngữ được hỗ trợ

```dart
final supportedLanguages = ref.watch(supportedLanguagesProvider);
```

## Thêm ngôn ngữ mới (Dễ dàng!)

### Bước 1: Tạo file strings cho ngôn ngữ mới

Copy file `lib/l10n/strings_template.dart` và đổi tên thành `strings_[language_code].dart`

Ví dụ cho tiếng Pháp: `lib/l10n/strings_fr.dart`

```dart
/// Tất cả chuỗi văn bản tiếng Pháp
class FrenchStrings {
  // Settings
  static const String settings = 'Paramètres';
  static const String language = 'Langue';
  static const String currency = 'Devise';
  // ... thêm tất cả các chuỗi khác
}
```

### Bước 2: Cập nhật languages.dart

Thêm ngôn ngữ mới vào enum và extension:

```dart
enum AppLanguage {
  vietnamese,
  english,
  french, // Thêm dòng này
}

extension AppLanguageExtension on AppLanguage {
  String get languageCode {
    switch (this) {
      case AppLanguage.vietnamese: return 'vi';
      case AppLanguage.english: return 'en';
      case AppLanguage.french: return 'fr'; // Thêm case này
    }
  }
  
  String get countryCode {
    switch (this) {
      case AppLanguage.vietnamese: return 'VN';
      case AppLanguage.english: return 'US';
      case AppLanguage.french: return 'FR'; // Thêm case này
    }
  }
  
  String get nativeName {
    switch (this) {
      case AppLanguage.vietnamese: return 'Tiếng Việt';
      case AppLanguage.english: return 'English';
      case AppLanguage.french: return 'Français'; // Thêm case này
    }
  }
  
  String get englishName {
    switch (this) {
      case AppLanguage.vietnamese: return 'Vietnamese';
      case AppLanguage.english: return 'English';
      case AppLanguage.french: return 'French'; // Thêm case này
    }
  }
}

class SupportedLanguages {
  static const List<AppLanguage> all = [
    AppLanguage.vietnamese,
    AppLanguage.english,
    AppLanguage.french, // Thêm dòng này
  ];
}
```

### Bước 3: Cập nhật strings_barrel.dart

```dart
export 'strings_vi.dart';
export 'strings_en.dart';
export 'strings_fr.dart'; // Thêm dòng này
```

### Bước 4: Cập nhật localization.dart

Thêm case mới vào method `_getString()` và tạo method mới:

```dart
String _getString(String key) {
  switch (locale.languageCode) {
    case 'vi': return _getVietnameseString(key);
    case 'en': return _getEnglishString(key);
    case 'fr': return _getFrenchString(key); // Thêm case này
    default: return _getEnglishString(key);
  }
}

String _getFrenchString(String key) {
  switch (key) {
    case 'settings': return FrenchStrings.settings;
    case 'language': return FrenchStrings.language;
    case 'currency': return FrenchStrings.currency;
    // ... thêm tất cả các case khác
    default: return key;
  }
}
```

### Bước 5: Cập nhật more.dart (nếu cần)

Thêm case mới vào method `_getLanguageChangeMessage()`:

```dart
String _getLanguageChangeMessage(AppLanguage language, AppLocalizations l10n) {
  switch (language) {
    case AppLanguage.vietnamese: return l10n.switchedToVietnamese;
    case AppLanguage.english: return l10n.switchedToEnglish;
    case AppLanguage.french: return 'Passé au français'; // Thêm case này
    default: return 'Switched to ${language.displayName}';
  }
}
```

### Bước 6: Thêm chuỗi thông báo chuyển ngôn ngữ

Thêm vào file strings mới:

```dart
// Trong FrenchStrings
static const String switchedToFrench = 'Passé au français';
```

Và thêm vào AppLocalizations:

```dart
// Trong AppLocalizations
String get switchedToFrench => _getString('switchedToFrench');

// Trong _getFrenchString
case 'switchedToFrench': return FrenchStrings.switchedToFrench;
```

## Lưu ý

1. **Lưu trữ**: Ngôn ngữ được lưu trong SharedPreferences với key `language_code`
2. **Mặc định**: Ngôn ngữ mặc định là tiếng Việt
3. **Cập nhật UI**: Khi thay đổi ngôn ngữ, UI sẽ tự động cập nhật nhờ vào Riverpod
4. **Fallback**: Nếu không tìm thấy chuỗi dịch, sẽ sử dụng chuỗi tiếng Anh làm fallback
5. **Tự động**: Dialog chọn ngôn ngữ sẽ tự động hiển thị tất cả ngôn ngữ được hỗ trợ

## Ví dụ hoàn chỉnh

```dart
class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(localeProvider);
    final supportedLanguages = ref.watch(supportedLanguagesProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.language),
            subtitle: Text(currentLanguage.displayName),
            onTap: () => _showLanguageDialog(context, ref, l10n, supportedLanguages),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, 
                          AppLocalizations l10n, List<AppLanguage> supportedLanguages) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chooseLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: supportedLanguages.map((language) {
            return ListTile(
              title: Text(language.displayName),
              onTap: () {
                ref.read(localeProvider.notifier).setLanguage(language);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
```

## Troubleshooting

### Lỗi "AppLocalizations.of(context) returns null"
- Đảm bảo đã thêm `AppLocalizationsDelegate()` vào `localizationsDelegates` trong MaterialApp
- Kiểm tra xem locale hiện tại có được hỗ trợ không

### UI không cập nhật khi thay đổi ngôn ngữ
- Đảm bảo đang sử dụng `ref.watch(localeProvider)` thay vì `ref.read(localeProvider)`
- Kiểm tra xem widget có được wrap trong ConsumerWidget không

### Chuỗi hiển thị không đúng ngôn ngữ
- Kiểm tra xem chuỗi đã được thêm vào file strings tương ứng chưa
- Đảm bảo mã ngôn ngữ (languageCode) đúng với locale
- Kiểm tra xem đã thêm case trong method `_get[Language]String()` chưa

### Lỗi khi thêm ngôn ngữ mới
- Đảm bảo đã thêm đầy đủ tất cả các case trong extension AppLanguageExtension
- Kiểm tra xem đã export file strings mới trong strings_barrel.dart chưa
- Đảm bảo đã thêm method `_get[Language]String()` trong localization.dart

## Ưu điểm của cấu trúc mới

1. **Dễ mở rộng**: Chỉ cần copy template và thêm vài dòng code
2. **Tách biệt**: Mỗi ngôn ngữ có file riêng, dễ quản lý
3. **Tự động**: Dialog chọn ngôn ngữ tự động hiển thị tất cả ngôn ngữ
4. **Type-safe**: Sử dụng enum và extension, tránh lỗi typo
5. **Fallback**: Có hệ thống fallback khi không tìm thấy chuỗi
6. **Performance**: Sử dụng const strings, tối ưu hiệu suất 
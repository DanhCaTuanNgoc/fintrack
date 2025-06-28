import '../l10n/strings_barrel.dart';
import 'localization.dart';

/// Helper class để chuyển đổi tên categories dựa trên icon
///
/// Cách sử dụng trong UI:
/// ```dart
/// final l10n = AppLocalizations.of(context);
/// final categoryName = CategoryHelper.getLocalizedCategoryName(category['icon'], l10n);
/// Text(categoryName)
/// ```
class CategoryHelper {
  /// Lấy tên category đã được localize dựa trên icon
  static String getLocalizedCategoryName(String? icon, AppLocalizations l10n) {
    switch (icon) {
      case '🍔':
        return l10n.foodAndDrinks;
      case '🚗':
        return l10n.transportation;
      case '🛍':
        return l10n.shopping;
      case '🎮':
        return l10n.entertainment;
      case '📚':
        return l10n.education;
      case '💅':
        return l10n.beauty;
      case '🏠':
        return l10n.household;
      case '💰':
        return l10n.salary;
      case '🎁':
        return l10n.bonus;
      case '📈':
        return l10n.investment;
      default:
        return icon ?? '';
    }
  }

  /// Lấy danh sách categories mặc định đã được localize
  static List<Map<String, String>> getDefaultCategories(AppLocalizations l10n) {
    return [
      {'name': l10n.foodAndDrinks, 'type': 'expense', 'icon': '🍔'},
      {'name': l10n.transportation, 'type': 'expense', 'icon': '🚗'},
      {'name': l10n.shopping, 'type': 'expense', 'icon': '🛍'},
      {'name': l10n.entertainment, 'type': 'expense', 'icon': '🎮'},
      {'name': l10n.education, 'type': 'expense', 'icon': '📚'},
      {'name': l10n.beauty, 'type': 'expense', 'icon': '💅'},
      {'name': l10n.household, 'type': 'expense', 'icon': '🏠'},
      {'name': l10n.salary, 'type': 'income', 'icon': '💰'},
      {'name': l10n.bonus, 'type': 'income', 'icon': '🎁'},
      {'name': l10n.investment, 'type': 'income', 'icon': '📈'},
    ];
  }

  /// Lấy danh sách categories mặc định cho database (tiếng Việt)
  static List<Map<String, String>> getDefaultCategoriesForDatabase() {
    return [
      {'name': 'Ăn uống', 'type': 'expense', 'icon': '🍔'},
      {'name': 'Di chuyển', 'type': 'expense', 'icon': '🚗'},
      {'name': 'Mua sắm', 'type': 'expense', 'icon': '🛍'},
      {'name': 'Giải trí', 'type': 'expense', 'icon': '🎮'},
      {'name': 'Học tập', 'type': 'expense', 'icon': '📚'},
      {'name': 'Làm đẹp', 'type': 'expense', 'icon': '💅'},
      {'name': 'Sinh hoạt', 'type': 'expense', 'icon': '🏠'},
      {'name': 'Lương', 'type': 'income', 'icon': '💰'},
      {'name': 'Thưởng', 'type': 'income', 'icon': '🎁'},
      {'name': 'Đầu tư', 'type': 'income', 'icon': '📈'},
    ];
  }
}

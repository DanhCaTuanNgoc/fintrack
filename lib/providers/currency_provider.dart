import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum để biểu diễn các loại tiền tệ được hỗ trợ
enum CurrencyType { vnd, usd, eur }

// Extension để lấy ký hiệu tiền tệ
extension CurrencySymbol on CurrencyType {
  String get symbol {
    switch (this) {
      case CurrencyType.vnd:
        return '₫';
      case CurrencyType.usd:
        return '\$';
      case CurrencyType.eur:
        return '€';
    }
  }

  String get name {
    switch (this) {
      case CurrencyType.vnd:
        return 'VND';
      case CurrencyType.usd:
        return 'USD';
      case CurrencyType.eur:
        return 'EUR';
    }
  }

  String get displayName {
    return '$name ($symbol)';
  }
}

// Tỷ giá hối đoái so với VND (tỷ giá mẫu, cần cập nhật từ API thực tế)
const Map<CurrencyType, double> exchangeRates = {
  CurrencyType.vnd: 1.0,
  CurrencyType.usd: 24500.0, // 1 USD = 24,500 VND
  CurrencyType.eur: 26800.0, // 1 EUR = 26,800 VND
};

// Provider cho tiền tệ hiện tại
final currencyProvider = StateNotifierProvider<CurrencyNotifier, CurrencyType>((
  ref,
) {
  return CurrencyNotifier();
});

// Provider lưu trữ tỷ giá chuyển đổi
final exchangeRateProvider = Provider<double>((ref) {
  final currentCurrency = ref.watch(currencyProvider);
  return exchangeRates[currentCurrency] ?? 1.0;
});

// Lớp notifier để quản lý trạng thái tiền tệ
class CurrencyNotifier extends StateNotifier<CurrencyType> {
  CurrencyNotifier() : super(CurrencyType.vnd) {
    _loadSavedCurrency();
  }

  // Tải cài đặt tiền tệ đã lưu từ SharedPreferences
  Future<void> _loadSavedCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? currencyString = prefs.getString('currency');

      if (currencyString != null) {
        state = _stringToCurrencyType(currencyString);
      }
    } catch (e) {
      // Nếu có lỗi, giữ nguyên mặc định (VND)
      print('Lỗi khi tải cài đặt tiền tệ: $e');
    }
  }

  // Chuyển đổi string thành CurrencyType
  CurrencyType _stringToCurrencyType(String value) {
    switch (value.toLowerCase()) {
      case 'usd':
        return CurrencyType.usd;
      case 'eur':
        return CurrencyType.eur;
      case 'vnd':
      default:
        return CurrencyType.vnd;
    }
  }

  // Cập nhật loại tiền tệ
  Future<void> setCurrency(CurrencyType currency) async {
    try {
      // Cập nhật trạng thái
      state = currency;

      // Lưu vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currency', currency.name.toLowerCase());
    } catch (e) {
      print('Lỗi khi lưu cài đặt tiền tệ: $e');
    }
  }
}

// Hàm chuyển đổi số tiền giữa các đơn vị tiền tệ
double convertCurrency(
  double amount,
  CurrencyType fromCurrency,
  CurrencyType toCurrency,
) {
  if (fromCurrency == toCurrency) {
    return amount;
  }

  // Chuyển đổi sang VND trước
  double amountInVND = amount;
  if (fromCurrency != CurrencyType.vnd) {
    amountInVND = amount * exchangeRates[fromCurrency]!;
  }

  // Chuyển từ VND sang tiền tệ đích
  if (toCurrency == CurrencyType.vnd) {
    return amountInVND;
  } else {
    return amountInVND / exchangeRates[toCurrency]!;
  }
}

// Định dạng số tiền theo đơn vị tiền tệ
String formatCurrency(double amount, CurrencyType currency) {
  String formatted = '';

  // Định dạng cơ bản không sử dụng thư viện formatter
  if (currency == CurrencyType.vnd) {
    // Định dạng VND chỉ hiển thị số nguyên
    formatted = amount.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    formatted = '$formatted${currency.symbol}';
  } else {
    // Định dạng USD và EUR với 2 chữ số thập phân
    String amountStr = amount.toStringAsFixed(2);
    String wholePart = amountStr.split('.')[0];
    String decimalPart = amountStr.split('.')[1];

    wholePart = wholePart.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    if (currency == CurrencyType.usd) {
      formatted = '${currency.symbol}$wholePart.$decimalPart';
    } else {
      formatted = '$wholePart.$decimalPart${currency.symbol}';
    }
  }

  return formatted;
}

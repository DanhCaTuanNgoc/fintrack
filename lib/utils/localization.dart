import 'package:flutter/material.dart';
import '../l10n/strings_barrel.dart';
import 'languages.dart';

/// Class quản lý localization cho ứng dụng
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  /// Lấy instance của AppLocalizations từ context
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Common
  String get cancel => _getString('cancel');
  String get confirm => _getString('confirm');
  String get save => _getString('save');
  String get delete => _getString('delete');
  String get edit => _getString('edit');
  String get add => _getString('add');
  String get close => _getString('close');
  String get loading => _getString('loading');
  String get error => _getString('error');
  String get success => _getString('success');
  String get total => _getString('total');

  // Books/Wallets
  String get editBookName => _getString('editBookName');
  String get newBookName => _getString('newBookName');
  String get bookNameExists => _getString('bookNameExists');
  String get pleaseChooseDifferentName =>
      _getString('pleaseChooseDifferentName');
  String get updateBookNameSuccess => _getString('updateBookNameSuccess');
  String get updateBookError => _getString('updateBookError');
  String get pleaseEnterBookName => _getString('pleaseEnterBookName');
  String get saveChanges => _getString('saveChanges');

  // Savings
  String get savings => _getString('savings');
  String get savingsGoals => _getString('savingsGoals');
  String get createSavingsGoal => _getString('createSavingsGoal');
  String get goalName => _getString('goalName');
  String get targetAmount => _getString('targetAmount');
  String get currentAmount => _getString('currentAmount');
  String get progress => _getString('progress');
  String get deadline => _getString('deadline');
  String get savingsOverdue => _getString('savingsOverdue');
  String get savingsClosed => _getString('savingsClosed');

  // Saving Goals
  String get editSavingsGoal => _getString('editSavingsGoal');
  String get deleteSavingsGoal => _getString('deleteSavingsGoal');
  String get confirmDelete => _getString('confirmDelete');
  String get confirmDeleteMessage => _getString('confirmDeleteMessage');
  String get deleteSuccess => _getString('deleteSuccess');
  String get updateSuccess => _getString('updateSuccess');
  String get currentInformation => _getString('currentInformation');
  String get savedAmount => _getString('savedAmount');
  String get progressLabel => _getString('progressLabel');
  String get dataLoadError => _getString('dataLoadError');
  String get completed => _getString('completed');
  String get overdue => _getString('overdue');
  String get closed => _getString('closed');
  String get inProgress => _getString('inProgress');
  String get target => _getString('target');
  String get targetCompletionDate => _getString('targetCompletionDate');
  String get savingsBookName => _getString('savingsBookName');
  String get enterName => _getString('enterName');
  String get enterAmount => _getString('enterAmount');
  String get amountMustBeGreaterThanZero =>
      _getString('amountMustBeGreaterThanZero');
  String get startDate => _getString('startDate');
  String get chooseDate => _getString('chooseDate');
  String get targetDate => _getString('targetDate');
  String get chooseDateOptional => _getString('chooseDateOptional');
  String get pleaseSelectStartDate => _getString('pleaseSelectStartDate');
  String get targetAmountCannotBeLessThanSaved =>
      _getString('targetAmountCannotBeLessThanSaved');

  // New additions
  String get noBook => _getString('noBook');
  String get createFirstBook => _getString('createFirstBook');
  String get expense => _getString('expense');
  String get income => _getString('income');
  String get totalExpense => _getString('totalExpense');
  String get totalIncome => _getString('totalIncome');
  String get noExpenseThisMonth => _getString('noExpenseThisMonth');
  String get noIncomeThisMonth => _getString('noIncomeThisMonth');

  // Settings & More
  String get settings => _getString('settings');
  String get language => _getString('language');
  String get currency => _getString('currency');
  String get themeColor => _getString('themeColor');
  String get notifications => _getString('notifications');
  String get black => _getString('black');
  String get purple => _getString('purple');
  String get blue => _getString('blue');
  String get green => _getString('green');
  String get orange => _getString('orange');
  String get pink => _getString('pink');
  String get darkPurple => _getString('darkPurple');
  String get indigo => _getString('indigo');
  String get cyan => _getString('cyan');
  String get brightOrange => _getString('brightOrange');
  String get brown => _getString('brown');
  String get blueGrey => _getString('blueGrey');
  String get chooseLanguage => _getString('chooseLanguage');
  String get chooseThemeColor => _getString('chooseThemeColor');
  String get extraFeatures => _getString('extraFeatures');
  String get setupAndTrack => _getString('setupAndTrack');
  String get periodicInvoices => _getString('periodicInvoices');
  String get managePeriodicBills => _getString('managePeriodicBills');
  String get books => _getString('books');
  String get createBook => _getString('createBook');
  String get editTransaction => _getString('editTransaction');
  String get note => _getString('note');
  String get selectExpenseCategory => _getString('selectExpenseCategory');
  String get selectIncomeCategory => _getString('selectIncomeCategory');
  String get category => _getString('category');
  String get chooseCategory => _getString('chooseCategory');
  String get addTransaction => _getString('addTransaction');
  String get createFlexibleSavingsGoal =>
      _getString('createFlexibleSavingsGoal');
  String get createPeriodicSavingsGoal =>
      _getString('createPeriodicSavingsGoal');
  String get expenseBookList => _getString('expenseBookList');
  String get charts => _getString('charts');
  String get more => _getString('more');
  String get pleaseSelectFrequency => _getString('pleaseSelectFrequency');
  String get tryAgain => _getString('tryAgain');
  String get confirmDeleteInvoice => _getString('confirmDeleteInvoice');
  String get minimumAmount => _getString('minimumAmount');
  String get maximumAmount => _getString('maximumAmount');
  String get invoiceName => _getString('invoiceName');
  String get expenseBook => _getString('expenseBook');
  String get paymentAmount => _getString('paymentAmount');
  String get details => _getString('details');
  String get noteOptional => _getString('noteOptional');
  String get periodicDeposit => _getString('periodicDeposit');
  String get reminderFrequency => _getString('reminderFrequency');
  String get editPeriodicSavingsGoal => _getString('editPeriodicSavingsGoal');
  String get periodicAmount => _getString('periodicAmount');
  String get chooseFrequency => _getString('chooseFrequency');
  String get daily => _getString('daily');
  String get weekly => _getString('weekly');
  String get monthly => _getString('monthly');
  String get enterPeriodicAmount => _getString('enterPeriodicAmount');
  String get periodicAmountMustBeGreaterThanZero =>
      _getString('periodicAmountMustBeGreaterThanZero');
  String get updateBook => _getString('updateBook');

  // Message switching
  String get switchedToVietnamese => _getString('switchedToVietnamese');
  String get switchedToEnglish => _getString('switchedToEnglish');

  // New addition
  String get analysis => _getString('analysis');

  // New addition
  String get invoice => _getString('invoice');
  String get calendar => _getString('calendar');
  String get all => _getString('all');
  String get noExpenseYet => _getString('noExpenseYet');
  String get noPeriodicInvoicesYet => _getString('noPeriodicInvoicesYet');
  String get createNewInvoice => _getString('createNewInvoice');
  String get filter => _getString('filter');
  String get allBooks => _getString('allBooks');
  String get allCategories => _getString('allCategories');
  String get enterValidNumber => _getString('enterValidNumber');
  String get clearFilter => _getString('clearFilter');
  String get paid => _getString('paid');
  String get pendingPayment => _getString('pendingPayment');
  String get frequency => _getString('frequency');
  String get createPeriodicInvoice => _getString('createPeriodicInvoice');
  String get pleaseEnterInvoiceName => _getString('pleaseEnterInvoiceName');
  String get createInvoice => _getString('createInvoice');
  String get bookNotExists => _getString('bookNotExists');

  // New additions
  String get pay => _getString('pay');
  String get payNow => _getString('payNow');
  String get invoiceAddedSuccessfully => _getString('invoiceAddedSuccessfully');
  String get errorCreatingInvoice => _getString('errorCreatingInvoice');
  String get yearly => _getString('yearly');

  // New addition
  String get amount => _getString('amount');
  String paidSuccessfullyWith(String invoiceName) =>
      _getString('paidSuccessfully').replaceFirst('{invoiceName}', invoiceName);
  String paymentErrorWith(String error) =>
      _getString('paymentError').replaceFirst('{error}', error);
  String invoiceAddedSuccessfullyWith(String bookName) =>
      _getString('invoiceAddedSuccessfully')
          .replaceFirst('{bookName}', bookName);
  String errorCreatingInvoiceWith(String error) =>
      _getString('errorCreatingInvoice').replaceFirst('{error}', error);

  // Deposit Savings Screen
  String get flexibleSavingsBook => _getString('flexibleSavingsBook');
  String get periodicSavingsBook => _getString('periodicSavingsBook');
  String get saved => _getString('saved');
  String get remaining => _getString('remaining');
  String get targetDateLabel => _getString('targetDateLabel');
  String get periodicDepositLabel => _getString('periodicDepositLabel');
  String get depositHistory => _getString('depositHistory');
  String get noDepositHistory => _getString('noDepositHistory');
  String get deposit => _getString('deposit');
  String get depositMoney => _getString('depositMoney');
  String get confirmDeposit => _getString('confirmDeposit');
  String get depositBeforeNextPeriod => _getString('depositBeforeNextPeriod');
  String get youAreDepositingBeforeNextPeriod =>
      _getString('youAreDepositingBeforeNextPeriod');
  String get continueDeposit => _getString('continueDeposit');
  String get frequencyDaily => _getString('frequencyDaily');
  String get frequencyWeekly => _getString('frequencyWeekly');
  String get frequencyMonthly => _getString('frequencyMonthly');

  // Flexible Savings Screen
  String get flexibleSavings => _getString('flexibleSavings');
  String get noFlexibleSavings => _getString('noFlexibleSavings');
  String get createNewSavings => _getString('createNewSavings');

  // Periodic Savings Screen
  String get periodicSavings => _getString('periodicSavings');
  String get noPeriodicSavings => _getString('noPeriodicSavings');

  // Savings Goals Screen
  String get savingsGoalsTitle => _getString('savingsGoalsTitle');
  String get flexibleSavingsDescription =>
      _getString('flexibleSavingsDescription');
  String get periodicSavingsDescription =>
      _getString('periodicSavingsDescription');

  // Add Amount Dialog
  String get enterAmountToDeposit => _getString('enterAmountToDeposit');
  String get amountHint => _getString('amountHint');

  // Notification Screen
  String get noNotifications => _getString('noNotifications');
  String get refresh => _getString('refresh');
  String get markAllAsRead => _getString('markAllAsRead');
  String get deleteAllRead => _getString('deleteAllRead');
  String get justNow => _getString('justNow');
  String daysAgoWith(int days) =>
      _getString('daysAgoWith').replaceFirst('{days}', days.toString());
  String hoursAgoWith(int hours) =>
      _getString('hoursAgoWith').replaceFirst('{hours}', hours.toString());
  String minutesAgoWith(int minutes) => _getString('minutesAgoWith')
      .replaceFirst('{minutes}', minutes.toString());

  // Weekdays
  String get monday => _getString('monday');
  String get tuesday => _getString('tuesday');
  String get wednesday => _getString('wednesday');
  String get thursday => _getString('thursday');
  String get friday => _getString('friday');
  String get saturday => _getString('saturday');

  String get targetAmountLabel => _getString('targetAmountLabel');
  String get startDateLabel => _getString('startDateLabel');
  String get chooseDateLabel => _getString('chooseDateLabel');
  String get deleteSavingsBook => _getString('deleteSavingsBook');
  String get deleteExpenseBook => _getString('deleteExpenseBook');
  String get deleteExpenseBookSuccess => _getString('deleteExpenseBookSuccess');
  String get deletingExpenseBook => _getString('deletingExpenseBook');
  String get update => _getString('update');
  String get foodAndDrinks => _getString('foodAndDrinks');
  String get transportation => _getString('transportation');
  String get shopping => _getString('shopping');
  String get entertainment => _getString('entertainment');
  String get education => _getString('education');
  String get beauty => _getString('beauty');
  String get household => _getString('household');
  String get salary => _getString('salary');
  String get bonus => _getString('bonus');
  String get investment => _getString('investment');
  String get nextDueDate => _getString('nextDueDate');
  // Methods for placeholders
  String themeColorChanged(String color) {
    final template = _getString('themeColorChanged');
    return template.replaceAll('{color}', color);
  }

  String currencyChanged(String currency) {
    final template = _getString('currencyChanged');
    return template.replaceAll('{currency}', currency);
  }

  String paidSuccessfully(String invoiceName) {
    final template = _getString('paidSuccessfully');
    return template.replaceAll('{invoiceName}', invoiceName);
  }

  String paymentError(String error) {
    final template = _getString('paymentError');
    return template.replaceAll('{error}', error);
  }

  String errorOccurred(String error) {
    final template = _getString('errorOccurred');
    return template.replaceAll('{error}', error);
  }

  String errorOccurredWith(String error) =>
      _getString('errorOccurred').replaceFirst('{error}', error);

  String confirmDeleteExpenseBook(String bookName) {
    final template = _getString('confirmDeleteExpenseBook');
    return template.replaceAll('{bookName}', bookName);
  }

  String deleteExpenseBookError(String error) {
    final template = _getString('deleteExpenseBookError');
    return template.replaceAll('{error}', error);
  }

  String get sunday => _getString('sunday');
  // Helper functions for dynamic strings
  String depositSuccessWith(String amount) =>
      _getString('depositSuccess').replaceFirst('{amount}', amount);

  /// Lấy chuỗi theo ngôn ngữ hiện tại
  String _getString(String key) {
    switch (locale.languageCode) {
      case 'vi':
        return _getVietnameseString(key);
      case 'en':
        return _getEnglishString(key);
      default:
        return _getEnglishString(key);
    }
  }

  /// Lấy chuỗi tiếng Việt
  String _getVietnameseString(String key) {
    // This is a temporary map to hold translations.
    // Ideally, these should come from a proper localization management system.
    final Map<String, String> translations = {
      'cancel': 'Hủy',
      'confirm': 'Xác nhận',
      'save': 'Lưu',
      'delete': 'Xóa',
      'edit': 'Chỉnh sửa',
      'add': 'Thêm',
      'close': 'Đóng',
      'loading': 'Đang tải...',
      'error': 'Lỗi',
      'success': 'Thành công',
      'total': 'Tổng',
      'editBookName': 'Chỉnh sửa tên sổ chi tiêu',
      'newBookName': 'Tên sổ chi tiêu mới',
      'bookNameExists': 'Tên sổ đã tồn tại',
      'pleaseChooseDifferentName':
          'Vui lòng chọn một tên khác cho sổ chi tiêu của bạn.',
      'updateBookNameSuccess': 'Cập nhật tên sổ chi tiêu thành công',
      'updateBookError': 'Đã xảy ra lỗi khi cập nhật sổ. Vui lòng thử lại.',
      'pleaseEnterBookName': 'Vui lòng nhập tên sổ chi tiêu',
      'saveChanges': 'Lưu thay đổi',
      'editSavingsGoal': 'Chỉnh sửa sổ tiết kiệm',
      'deleteSavingsGoal': 'Xóa sổ tiết kiệm',
      'confirmDelete': 'Xác nhận xóa',
      'confirmDeleteMessage':
          'Bạn có chắc chắn muốn xóa sổ tiết kiệm "{goalName}"?.',
      'deleteSuccess': 'Đã xóa thành công!',
      'updateSuccess': 'Cập nhật thành công!',
      'currentInformation': 'Thông tin hiện tại:',
      'savedAmount': 'Đã tiết kiệm:',
      'progressLabel': 'Tiến độ:',
      'dataLoadError': 'Lỗi tải dữ liệu',
      'completed': 'Đã hoàn thành',
      'overdue': 'Đã quá hạn',
      'closed': 'Đã đóng',
      'inProgress': 'Đang tiến hành',
      'target': 'Mục tiêu',
      'targetCompletionDate': 'Ngày hoàn thành mục tiêu',
      'savingsBookName': 'Tên sổ tiết kiệm',
      'enterName': 'Nhập tên',
      'enterAmount': 'Nhập số tiền',
      'amountMustBeGreaterThanZero': 'Số tiền phải lớn hơn 0',
      'startDate': 'Ngày bắt đầu',
      'chooseDate': 'Chọn ngày',
      'targetDate': 'Ngày mục tiêu',
      'chooseDateOptional': 'Chọn ngày (tùy chọn)',
      'pleaseSelectStartDate': 'Vui lòng chọn ngày bắt đầu',
      'targetAmountCannotBeLessThanSaved':
          'Số tiền mục tiêu không được nhỏ hơn số tiền đã tiết kiệm ({savedAmount})',
      'noBook': 'Chưa có sổ chi tiêu nào',
      'createFirstBook': 'Hãy tạo sổ chi tiêu đầu tiên của bạn',
      'expense': 'Chi tiêu',
      'income': 'Thu nhập',
      'noExpenseThisMonth': 'Không có chi tiêu trong tháng này',
      'totalExpense': 'Tổng chi tiêu',
      'totalIncome': 'Tổng thu nhập',
      'noIncomeThisMonth': 'Không có thu nhập trong tháng này',
      'analysis': 'Phân tích chi tiêu',
      'settings': 'Cài đặt',
      'language': 'Ngôn ngữ',
      'currency': 'Tiền tệ',
      'themeColor': 'Màu chủ đạo',
      'notifications': 'Thông báo',
      'black': 'Đen',
      'purple': 'Tím',
      'blue': 'Xanh dương',
      'green': 'Xanh lá',
      'orange': 'Cam',
      'pink': 'Hồng',
      'darkPurple': 'Tím đậm',
      'indigo': 'Indigo',
      'cyan': 'Cyan',
      'brightOrange': 'Cam sáng',
      'brown': 'Nâu',
      'blueGrey': 'Xám xanh',
      'chooseLanguage': 'Chọn ngôn ngữ',
      'chooseThemeColor': 'Chọn màu chủ đạo',
      'extraFeatures': 'Tiện ích bổ sung',
      'savingsGoals': 'Mục tiêu tiết kiệm',
      'setupAndTrack': 'Thiết lập và theo dõi mục tiêu tiết kiệm',
      'periodicInvoices': 'Hóa đơn định kỳ',
      'managePeriodicBills': 'Quản lý hóa đơn định kỳ',
      'books': 'Sổ',
      'createBook': 'Tạo sổ chi tiêu mới',
      'progress': 'Tiến độ',
      'editTransaction': 'Chỉnh sửa giao dịch',
      'note': 'Ghi chú',
      'selectExpenseCategory': 'Chọn danh mục chi tiêu',
      'selectIncomeCategory': 'Chọn danh mục thu nhập',
      'category': 'Danh mục',
      'chooseCategory': 'Chọn danh mục',
      'addTransaction': 'Thêm giao dịch',
      'createFlexibleSavingsGoal': 'Tạo sổ tiết kiệm linh hoạt',
      'createPeriodicSavingsGoal': 'Tạo sổ tiết kiệm định kỳ',
      'targetAmount': 'Số tiền mục tiêu',
      'expenseBookList': 'Danh sách sổ chi tiêu',
      'switchedToVietnamese': 'Đã chuyển sang Tiếng Việt',
      'switchedToEnglish': 'Switched to English',
      'charts': 'Biểu đồ',
      'more': 'Thêm',
      'pleaseSelectFrequency': 'Vui lòng chọn tần suất',
      'tryAgain': 'Thử lại',
      'confirmDeleteInvoice': 'Xác nhận xóa',
      'minimumAmount': 'Số tiền tối thiểu',
      'maximumAmount': 'Số tiền tối đa',
      'invoiceName': 'Tên hóa đơn',
      'expenseBook': 'Sổ chi tiêu',
      'paymentAmount': 'Số tiền thanh toán',
      'details': 'Chi tiết',
      'noteOptional': 'Ghi chú (tùy chọn)',
      'periodicDeposit': 'Nạp định kỳ',
      'paidSuccessfully': 'Đã thanh toán {invoiceName}',
      'paymentError': 'Lỗi khi thanh toán: {error}',
      'errorOccurred': 'Có lỗi xảy ra: {error}',
      'reminderFrequency': 'Tần suất nhắc nhở',
      'editPeriodicSavingsGoal': 'Chỉnh sửa sổ tiết kiệm định kỳ',
      'periodicAmount': 'Số tiền định kỳ',
      'chooseFrequency': 'Chọn tần suất',
      'daily': 'Hàng ngày',
      'weekly': 'Hàng tuần',
      'monthly': 'Hàng tháng',
      'enterPeriodicAmount': 'Nhập số tiền định kỳ',
      'periodicAmountMustBeGreaterThanZero': 'Số tiền định kỳ phải lớn hơn 0',
      'updateBook': 'Cập nhật sổ',
      'invoice': 'Hóa đơn',
      'calendar': 'Lịch',
      'all': 'Toàn bộ',
      'noExpenseYet': 'Hiện chưa có chi tiêu',
      'noPeriodicInvoicesYet': 'Chưa có hóa đơn định kỳ nào',
      'createNewInvoice': 'Tạo hóa đơn mới',
      'filter': 'Bộ lọc',
      'allBooks': 'Tất cả sổ',
      'allCategories': 'Tất cả danh mục',
      'enterValidNumber': 'Nhập số hợp lệ',
      'clearFilter': 'Xóa bộ lọc',
      'paid': 'Đã thanh toán',
      'pendingPayment': 'Chờ thanh toán',
      'frequency': 'Tần suất',
      'createPeriodicInvoice': 'Tạo hóa đơn định kỳ',
      'pleaseEnterInvoiceName': 'Vui lòng nhập tên hóa đơn',
      'createInvoice': 'Tạo hóa đơn',
      'bookNotExists': 'Sổ không tồn tại',
      'pay': 'Thanh toán',
      'payNow': 'Thanh toán ngay',
      'invoiceAddedSuccessfully':
          'Đã thêm hóa đơn định kỳ thành công vào sổ {bookName}',
      'errorCreatingInvoice': 'Lỗi khi tạo hóa đơn: {error}',
      'yearly': 'Hàng năm',
      'themeColorChanged': 'Đã đổi màu nền thành {color}',
      'currencyChanged': 'Đã chuyển sang {currency}',
      'flexibleSavingsBook': 'Sổ tiết kiệm linh hoạt',
      'periodicSavingsBook': 'Sổ tiết kiệm định kỳ',
      'saved': 'Đã tiết kiệm',
      'remaining': 'Còn lại',
      'targetDateLabel': 'Ngày mục tiêu:',
      'periodicDepositLabel': 'Nạp định kỳ:',
      'depositHistory': 'Lịch sử nạp tiền',
      'noDepositHistory': 'Chưa có lịch sử nạp tiền',
      'deposit': 'Nạp tiền',
      'depositMoney': 'Bỏ tiền tiết kiệm',
      'confirmDeposit': 'Xác nhận nạp tiền',
      'depositBeforeNextPeriod': 'Nạp trước kỳ tiếp theo?',
      'youAreDepositingBeforeNextPeriod': 'Bạn đang nạp trước kỳ tiếp theo:',
      'continueDeposit': 'Bỏ tiết kiệm',
      'frequencyDaily': 'hàng ngày',
      'frequencyWeekly': 'hàng tuần',
      'frequencyMonthly': 'hàng tháng',
      'flexibleSavings': 'Tiết kiệm linh hoạt',
      'noFlexibleSavings': 'Không có sổ tiết kiệm linh hoạt nào',
      'createNewSavings': 'Tạo tiết kiệm mới',
      'savingsOverdue': 'Sổ tiết kiệm này đã quá hạn.',
      'savingsClosed': 'Sổ tiết kiệm này đã được đóng.',
      'periodicSavings': 'Tiết kiệm định kỳ',
      'noPeriodicSavings': 'Không có sổ tiết kiệm định kỳ nào',
      'savingsGoalsTitle': 'Mục tiêu tiết kiệm',
      'flexibleSavingsDescription':
          'Không có kế hoạch, gửi tiền theo tâm trạng của bạn',
      'periodicSavingsDescription': 'Gửi tiền theo định kỳ',
      'enterAmountToDeposit': 'Nhập số tiền để gửi',
      'amountHint': 'Số tiền',
      'depositSuccess': 'Đã nạp {amount} vào sổ tiết kiệm!',
      'noNotifications': 'Không có thông báo nào!',
      'refresh': 'Làm mới',
      'markAllAsRead': 'Đánh dấu tất cả đã đọc',
      'deleteAllRead': 'Xóa tất cả đã đọc',
      'justNow': 'Vừa xong',
      'daysAgoWith': '{days} ngày trước',
      'hoursAgoWith': '{hours} giờ trước',
      'minutesAgoWith': '{minutes} phút trước',
      'daysAgo': '{days} ngày trước',
      'hoursAgo': '{hours} giờ trước',
      'minutesAgo': '{minutes} phút trước',
      'monday': 'Th 2',
      'tuesday': 'Th 3',
      'wednesday': 'Th 4',
      'thursday': 'Th 5',
      'friday': 'Th 6',
      'saturday': 'Th 7',
      'sunday': 'CN',
      'deleteSavingsBook': 'Xóa sổ tiết kiệm',
      'deleteExpenseBook': 'Xóa sổ chi tiêu',
      'confirmDeleteExpenseBook': 'Bạn có chắc chắn muốn xóa sổ "{bookName}"?',
      'deleteExpenseBookSuccess': 'Xóa sổ thành công',
      'deleteExpenseBookError': 'Có lỗi xảy ra khi xóa sổ: {error}',
      'deletingExpenseBook': 'Đang xóa sổ...',
      'update': 'Cập nhật',
      'foodAndDrinks': 'Ăn uống',
      'transportation': 'Di chuyển',
      'shopping': 'Mua sắm',
      'entertainment': 'Giải trí',
      'education': 'Học tập',
      'beauty': 'Làm đẹp',
      'household': 'Sinh hoạt',
      'salary': 'Lương',
      'bonus': 'Thưởng',
      'investment': 'Đầu tư',
      'amount': 'Số tiền',
      'nextDueDate': 'Ngày đến hạn'
    };
    return translations[key] ?? key;
  }

  /// Lấy chuỗi tiếng Anh
  String _getEnglishString(String key) {
    final Map<String, String> translations = {
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'close': 'Close',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'total': 'Total',
      'editBookName': 'Edit Expense Book Name',
      'newBookName': 'New Expense Book Name',
      'bookNameExists': 'Book name already exists',
      'pleaseChooseDifferentName':
          'Please choose a different name for your expense book.',
      'updateBookNameSuccess': 'Expense book name updated successfully',
      'updateBookError':
          'An error occurred while updating the book. Please try again.',
      'pleaseEnterBookName': 'Please enter the expense book name',
      'saveChanges': 'Save Changes',
      'editSavingsGoal': 'Edit Savings Goal',
      'deleteSavingsGoal': 'Delete Savings Goal',
      'confirmDelete': 'Confirm Delete',
      'confirmDeleteMessage':
          'Are you sure you want to delete the savings goal "{goalName}"?.',
      'deleteSuccess': 'Deleted successfully!',
      'updateSuccess': 'Updated successfully!',
      'currentInformation': 'Current Information:',
      'savedAmount': 'Saved Amount:',
      'progressLabel': 'Progress:',
      'dataLoadError': 'Error loading data',
      'completed': 'Completed',
      'overdue': 'Overdue',
      'closed': 'Closed',
      'inProgress': 'In Progress',
      'target': 'Target',
      'targetCompletionDate': 'Target Completion Date',
      'savingsBookName': 'Savings Book Name',
      'enterName': 'Enter Name',
      'enterAmount': 'Enter Amount',
      'amountMustBeGreaterThanZero': 'Amount must be greater than 0',
      'startDate': 'Start Date',
      'chooseDate': 'Choose Date',
      'targetDate': 'Target Date',
      'chooseDateOptional': 'Choose Date (optional)',
      'pleaseSelectStartDate': 'Please select a start date',
      'targetAmountCannotBeLessThanSaved':
          'Target amount cannot be less than the saved amount ({savedAmount})',
      'noBook': 'No expense book found',
      'createFirstBook': 'Let\'s create your first expense book',
      'expense': 'Expense',
      'income': 'Income',
      'noExpenseThisMonth': 'No expenses this month',
      'totalExpense': 'Total Expense',
      'totalIncome': 'Total Income',
      'noIncomeThisMonth': 'No income this month',
      'analysis': 'Expense Analysis',
      'settings': 'Settings',
      'language': 'Language',
      'currency': 'Currency',
      'themeColor': 'Theme Color',
      'notifications': 'Notifications',
      'black': 'Black',
      'purple': 'Purple',
      'blue': 'Blue',
      'green': 'Green',
      'orange': 'Orange',
      'pink': 'Pink',
      'darkPurple': 'Dark Purple',
      'indigo': 'Indigo',
      'cyan': 'Cyan',
      'brightOrange': 'Bright Orange',
      'brown': 'Brown',
      'blueGrey': 'Blue Grey',
      'chooseLanguage': 'Choose Language',
      'chooseThemeColor': 'Choose Theme Color',
      'extraFeatures': 'Extra Features',
      'savingsGoals': 'Savings Goals',
      'setupAndTrack': 'Set up and track savings goals',
      'periodicInvoices': 'Recurring Invoices',
      'managePeriodicBills': 'Manage periodic bills',
      'books': 'Books',
      'createBook': 'Create New Book',
      'progress': 'Progress',
      'editTransaction': 'Edit Transaction',
      'note': 'Note',
      'selectExpenseCategory': 'Select Expense Category',
      'selectIncomeCategory': 'Select Income Category',
      'category': 'Category',
      'chooseCategory': 'Choose Category',
      'addTransaction': 'Add Transaction',
      'createFlexibleSavingsGoal': 'Create Flexible Savings Goal',
      'createPeriodicSavingsGoal': 'Create Periodic Savings Goal',
      'targetAmount': 'Target Amount',
      'expenseBookList': 'Expense Book List',
      'switchedToVietnamese': 'Đã chuyển sang Tiếng Việt',
      'switchedToEnglish': 'Switched to English',
      'charts': 'Charts',
      'more': 'More',
      'pleaseSelectFrequency': 'Please select frequency',
      'tryAgain': 'Try Again',
      'confirmDeleteInvoice': 'Confirm Delete',
      'minimumAmount': 'Minimum Amount',
      'maximumAmount': 'Maximum Amount',
      'invoiceName': 'Invoice Name',
      'expenseBook': 'Expense Book',
      'paymentAmount': 'Payment Amount',
      'details': 'Details',
      'noteOptional': 'Note (optional)',
      'periodicDeposit': 'Periodic Deposit',
      'paidSuccessfully': 'Paid {invoiceName} successfully',
      'paymentError': 'Error during payment: {error}',
      'errorOccurred': 'An error occurred: {error}',
      'reminderFrequency': 'Reminder Frequency',
      'editPeriodicSavingsGoal': 'Edit Periodic Savings Goal',
      'periodicAmount': 'Periodic Amount',
      'chooseFrequency': 'Choose Frequency',
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'enterPeriodicAmount': 'Enter periodic amount',
      'periodicAmountMustBeGreaterThanZero':
          'Periodic amount must be greater than 0',
      'updateBook': 'Update Book',
      'invoice': 'Invoice',
      'calendar': 'Calendar',
      'all': 'All',
      'noExpenseYet': 'No expenses yet',
      'noPeriodicInvoicesYet': 'No periodic invoices yet',
      'createNewInvoice': 'Create New Invoice',
      'filter': 'Filter',
      'allBooks': 'All Books',
      'allCategories': 'All Categories',
      'enterValidNumber': 'Enter a valid number',
      'clearFilter': 'Clear Filter',
      'paid': 'Paid',
      'pendingPayment': 'Pending',
      'frequency': 'Frequency',
      'createPeriodicInvoice': 'Create Periodic Invoice',
      'pleaseEnterInvoiceName': 'Please enter invoice name',
      'createInvoice': 'Create Invoice',
      'bookNotExists': 'Book does not exist',
      'pay': 'Pay',
      'payNow': 'Pay Now',
      'invoiceAddedSuccessfully':
          'Successfully added periodic invoice to book {bookName}',
      'errorCreatingInvoice': 'Error creating invoice: {error}',
      'yearly': 'Yearly',
      'themeColorChanged': 'Theme color changed to {color}',
      'currencyChanged': 'Currency changed to {currency}',
      'flexibleSavingsBook': 'Flexible Savings Book',
      'periodicSavingsBook': 'Periodic Savings Book',
      'saved': 'Saved',
      'remaining': 'Remaining',
      'targetDateLabel': 'Target Date:',
      'periodicDepositLabel': 'Periodic Deposit:',
      'depositHistory': 'Deposit History',
      'noDepositHistory': 'No deposit history',
      'deposit': 'Deposit',
      'depositMoney': 'Deposit Money',
      'confirmDeposit': 'Confirm Deposit',
      'depositBeforeNextPeriod': 'Deposit before next period?',
      'youAreDepositingBeforeNextPeriod':
          'You are depositing before the next period:',
      'continueDeposit': 'Deposit',
      'frequencyDaily': 'daily',
      'frequencyWeekly': 'weekly',
      'frequencyMonthly': 'monthly',
      'flexibleSavings': 'Flexible Savings',
      'noFlexibleSavings': 'No flexible savings goals',
      'createNewSavings': 'Create New Savings',
      'savingsOverdue': 'This savings goal is overdue.',
      'savingsClosed': 'This savings goal is closed.',
      'periodicSavings': 'Periodic Savings',
      'noPeriodicSavings': 'No periodic savings goals',
      'savingsGoalsTitle': 'Savings Goals',
      'flexibleSavingsDescription': 'No plan, deposit based on your mood',
      'periodicSavingsDescription': 'Deposit periodically',
      'enterAmountToDeposit': 'Enter amount to deposit',
      'amountHint': 'Amount',
      'depositSuccess': 'Deposited {amount} to savings goal!',
      'noNotifications': 'No notifications!',
      'refresh': 'Refresh',
      'markAllAsRead': 'Mark all as read',
      'deleteAllRead': 'Delete all read',
      'justNow': 'Just now',
      'daysAgoWith': '{days} days ago',
      'hoursAgoWith': '{hours} hours ago',
      'minutesAgoWith': '{minutes} minutes ago',
      'daysAgo': '{days}d ago',
      'hoursAgo': '{hours}h ago',
      'minutesAgo': '{minutes}m ago',
      'monday': 'Mon',
      'tuesday': 'Tue',
      'wednesday': 'Wed',
      'thursday': 'Thu',
      'friday': 'Fri',
      'saturday': 'Sat',
      'sunday': 'Sun',
      'deleteSavingsBook': 'Delete Savings Book',
      'deleteExpenseBook': 'Delete Expense Book',
      'confirmDeleteExpenseBook':
          'Are you sure you want to delete the book "{bookName}"?',
      'deleteExpenseBookSuccess': 'Book deleted successfully',
      'deleteExpenseBookError': 'Error deleting book: {error}',
      'deletingExpenseBook': 'Deleting book...',
      'update': 'Update',
      'foodAndDrinks': 'Food & Drinks',
      'transportation': 'Transportation',
      'shopping': 'Shopping',
      'entertainment': 'Entertainment',
      'education': 'Education',
      'beauty': 'Beauty',
      'household': 'Household',
      'salary': 'Salary',
      'bonus': 'Bonus',
      'investment': 'Investment',
      'amount': 'Amount',
      'nextDueDate': 'Next Due Date'
    };
    return translations[key] ?? key;
  }

  /// Danh sách Locale được hỗ trợ
  static List<Locale> get supportedLocales =>
      SupportedLanguages.supportedLocales;
}

/// Delegate cho AppLocalizations
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return SupportedLanguages.isSupported(locale);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

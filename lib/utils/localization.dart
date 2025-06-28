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

  /// Lấy chuỗi văn bản theo ngôn ngữ hiện tại
  String get settings => _getString('settings');
  String get language => _getString('language');
  String get currency => _getString('currency');
  String get themeColor => _getString('themeColor');
  String get notifications => _getString('notifications');

  // Language names
  String get vietnamese => _getString('vietnamese');
  String get english => _getString('english');

  // Dialog titles
  String get chooseLanguage => _getString('chooseLanguage');
  String get chooseCurrency => _getString('chooseCurrency');
  String get chooseThemeColor => _getString('chooseThemeColor');

  // Messages
  String get switchedToVietnamese => _getString('switchedToVietnamese');
  String get switchedToEnglish => _getString('switchedToEnglish');

  // Common
  String get cancel => _getString('cancel');
  String get confirm => _getString('confirm');
  String get save => _getString('save');
  String get delete => _getString('delete');
  String get edit => _getString('edit');
  String get add => _getString('add');
  String get close => _getString('close');
  String get back => _getString('back');
  String get next => _getString('next');
  String get previous => _getString('previous');
  String get done => _getString('done');
  String get loading => _getString('loading');
  String get error => _getString('error');
  String get success => _getString('success');
  String get warning => _getString('warning');
  String get info => _getString('info');

  // Home
  String get home => _getString('home');
  String get dashboard => _getString('dashboard');
  String get overview => _getString('overview');
  String get summary => _getString('summary');

  // Transactions
  String get transactions => _getString('transactions');
  String get income => _getString('income');
  String get expense => _getString('expense');
  String get transfer => _getString('transfer');
  String get amount => _getString('amount');
  String get date => _getString('date');
  String get time => _getString('time');
  String get category => _getString('category');
  String get description => _getString('description');
  String get note => _getString('note');

  // Books/Wallets
  String get books => _getString('books');
  String get wallets => _getString('wallets');
  String get createBook => _getString('createBook');
  String get createWallet => _getString('createWallet');
  String get bookName => _getString('bookName');
  String get walletName => _getString('walletName');
  String get balance => _getString('balance');
  String get totalBalance => _getString('totalBalance');

  // Savings
  String get savings => _getString('savings');
  String get savingsGoals => _getString('savingsGoals');
  String get createSavingsGoal => _getString('createSavingsGoal');
  String get goalName => _getString('goalName');
  String get targetAmount => _getString('targetAmount');
  String get currentAmount => _getString('currentAmount');
  String get progress => _getString('progress');
  String get deadline => _getString('deadline');

  // Charts
  String get charts => _getString('charts');
  String get statistics => _getString('statistics');
  String get monthly => _getString('monthly');
  String get yearly => _getString('yearly');
  String get weekly => _getString('weekly');
  String get daily => _getString('daily');

  // More
  String get more => _getString('more');
  String get profile => _getString('profile');
  String get help => _getString('help');
  String get about => _getString('about');
  String get feedback => _getString('feedback');
  String get rateApp => _getString('rateApp');
  String get shareApp => _getString('shareApp');
  String get privacyPolicy => _getString('privacyPolicy');
  String get termsOfService => _getString('termsOfService');
  String get version => _getString('version');
  String get buildNumber => _getString('buildNumber');

  // Extra Features
  String get extraFeatures => _getString('extraFeatures');
  String get periodicInvoices => _getString('periodicInvoices');
  String get setupAndTrack => _getString('setupAndTrack');
  String get managePeriodicBills => _getString('managePeriodicBills');

  // Welcome Screen
  String get welcome => _getString('welcome');
  String get welcomeToFintrack => _getString('welcomeToFintrack');
  String get welcomeSubtitle => _getString('welcomeSubtitle');
  String get termsAndConditions => _getString('termsAndConditions');
  String get acceptTerms => _getString('acceptTerms');
  String get createFirstBook => _getString('createFirstBook');
  String get bookNameHint => _getString('bookNameHint');
  String get getStarted => _getString('getStarted');
  String get skip => _getString('skip');

  // Time
  String get today => _getString('today');
  String get yesterday => _getString('yesterday');
  String get tomorrow => _getString('tomorrow');
  String get thisWeek => _getString('thisWeek');
  String get lastWeek => _getString('lastWeek');
  String get nextWeek => _getString('nextWeek');
  String get thisMonth => _getString('thisMonth');
  String get lastMonth => _getString('lastMonth');
  String get nextMonth => _getString('nextMonth');
  String get thisYear => _getString('thisYear');
  String get lastYear => _getString('lastYear');
  String get nextYear => _getString('nextYear');

  // Numbers
  String get zero => _getString('zero');
  String get one => _getString('one');
  String get two => _getString('two');
  String get three => _getString('three');
  String get four => _getString('four');
  String get five => _getString('five');
  String get six => _getString('six');
  String get seven => _getString('seven');
  String get eight => _getString('eight');
  String get nine => _getString('nine');
  String get ten => _getString('ten');

  // Colors
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

  /// Lấy chuỗi với placeholder
  String currencyChanged(String currency) {
    final template = _getString('currencyChanged');
    return template.replaceAll('{currency}', currency);
  }

  String themeColorChanged(String color) {
    final template = _getString('themeColorChanged');
    return template.replaceAll('{color}', color);
  }

  /// Lấy chuỗi theo ngôn ngữ hiện tại
  String _getString(String key) {
    switch (locale.languageCode) {
      case 'vi':
        return _getVietnameseString(key);
      case 'en':
        return _getEnglishString(key);
      // Thêm case cho ngôn ngữ mới
      // case 'fr':
      //   return _getFrenchString(key);
      default:
        return _getEnglishString(key); // Fallback to English
    }
  }

  /// Lấy chuỗi tiếng Việt
  String _getVietnameseString(String key) {
    switch (key) {
      case 'settings':
        return VietnameseStrings.settings;
      case 'language':
        return VietnameseStrings.language;
      case 'currency':
        return VietnameseStrings.currency;
      case 'themeColor':
        return VietnameseStrings.themeColor;
      case 'notifications':
        return VietnameseStrings.notifications;
      case 'vietnamese':
        return VietnameseStrings.vietnamese;
      case 'english':
        return VietnameseStrings.english;
      case 'chooseLanguage':
        return VietnameseStrings.chooseLanguage;
      case 'chooseCurrency':
        return VietnameseStrings.chooseCurrency;
      case 'chooseThemeColor':
        return VietnameseStrings.chooseThemeColor;
      case 'switchedToVietnamese':
        return VietnameseStrings.switchedToVietnamese;
      case 'switchedToEnglish':
        return VietnameseStrings.switchedToEnglish;
      case 'currencyChanged':
        return VietnameseStrings.currencyChanged;
      case 'themeColorChanged':
        return VietnameseStrings.themeColorChanged;
      case 'cancel':
        return VietnameseStrings.cancel;
      case 'confirm':
        return VietnameseStrings.confirm;
      case 'save':
        return VietnameseStrings.save;
      case 'delete':
        return VietnameseStrings.delete;
      case 'edit':
        return VietnameseStrings.edit;
      case 'add':
        return VietnameseStrings.add;
      case 'close':
        return VietnameseStrings.close;
      case 'back':
        return VietnameseStrings.back;
      case 'next':
        return VietnameseStrings.next;
      case 'previous':
        return VietnameseStrings.previous;
      case 'done':
        return VietnameseStrings.done;
      case 'loading':
        return VietnameseStrings.loading;
      case 'error':
        return VietnameseStrings.error;
      case 'success':
        return VietnameseStrings.success;
      case 'warning':
        return VietnameseStrings.warning;
      case 'info':
        return VietnameseStrings.info;
      case 'home':
        return VietnameseStrings.home;
      case 'dashboard':
        return VietnameseStrings.dashboard;
      case 'overview':
        return VietnameseStrings.overview;
      case 'summary':
        return VietnameseStrings.summary;
      case 'transactions':
        return VietnameseStrings.transactions;
      case 'income':
        return VietnameseStrings.income;
      case 'expense':
        return VietnameseStrings.expense;
      case 'transfer':
        return VietnameseStrings.transfer;
      case 'amount':
        return VietnameseStrings.amount;
      case 'date':
        return VietnameseStrings.date;
      case 'time':
        return VietnameseStrings.time;
      case 'category':
        return VietnameseStrings.category;
      case 'description':
        return VietnameseStrings.description;
      case 'note':
        return VietnameseStrings.note;
      case 'books':
        return VietnameseStrings.books;
      case 'wallets':
        return VietnameseStrings.wallets;
      case 'createBook':
        return VietnameseStrings.createBook;
      case 'createWallet':
        return VietnameseStrings.createWallet;
      case 'bookName':
        return VietnameseStrings.bookName;
      case 'walletName':
        return VietnameseStrings.walletName;
      case 'balance':
        return VietnameseStrings.balance;
      case 'totalBalance':
        return VietnameseStrings.totalBalance;
      case 'savings':
        return VietnameseStrings.savings;
      case 'savingsGoals':
        return VietnameseStrings.savingsGoals;
      case 'createSavingsGoal':
        return VietnameseStrings.createSavingsGoal;
      case 'goalName':
        return VietnameseStrings.goalName;
      case 'targetAmount':
        return VietnameseStrings.targetAmount;
      case 'currentAmount':
        return VietnameseStrings.currentAmount;
      case 'progress':
        return VietnameseStrings.progress;
      case 'deadline':
        return VietnameseStrings.deadline;
      case 'charts':
        return VietnameseStrings.charts;
      case 'statistics':
        return VietnameseStrings.statistics;
      case 'monthly':
        return VietnameseStrings.monthly;
      case 'yearly':
        return VietnameseStrings.yearly;
      case 'weekly':
        return VietnameseStrings.weekly;
      case 'daily':
        return VietnameseStrings.daily;
      case 'more':
        return VietnameseStrings.more;
      case 'profile':
        return VietnameseStrings.profile;
      case 'help':
        return VietnameseStrings.help;
      case 'about':
        return VietnameseStrings.about;
      case 'feedback':
        return VietnameseStrings.feedback;
      case 'rateApp':
        return VietnameseStrings.rateApp;
      case 'shareApp':
        return VietnameseStrings.shareApp;
      case 'privacyPolicy':
        return VietnameseStrings.privacyPolicy;
      case 'termsOfService':
        return VietnameseStrings.termsOfService;
      case 'version':
        return VietnameseStrings.version;
      case 'buildNumber':
        return VietnameseStrings.buildNumber;
      case 'today':
        return VietnameseStrings.today;
      case 'yesterday':
        return VietnameseStrings.yesterday;
      case 'tomorrow':
        return VietnameseStrings.tomorrow;
      case 'thisWeek':
        return VietnameseStrings.thisWeek;
      case 'lastWeek':
        return VietnameseStrings.lastWeek;
      case 'nextWeek':
        return VietnameseStrings.nextWeek;
      case 'thisMonth':
        return VietnameseStrings.thisMonth;
      case 'lastMonth':
        return VietnameseStrings.lastMonth;
      case 'nextMonth':
        return VietnameseStrings.nextMonth;
      case 'thisYear':
        return VietnameseStrings.thisYear;
      case 'lastYear':
        return VietnameseStrings.lastYear;
      case 'nextYear':
        return VietnameseStrings.nextYear;
      case 'zero':
        return VietnameseStrings.zero;
      case 'one':
        return VietnameseStrings.one;
      case 'two':
        return VietnameseStrings.two;
      case 'three':
        return VietnameseStrings.three;
      case 'four':
        return VietnameseStrings.four;
      case 'five':
        return VietnameseStrings.five;
      case 'six':
        return VietnameseStrings.six;
      case 'seven':
        return VietnameseStrings.seven;
      case 'eight':
        return VietnameseStrings.eight;
      case 'nine':
        return VietnameseStrings.nine;
      case 'ten':
        return VietnameseStrings.ten;
      case 'purple':
        return VietnameseStrings.purple;
      case 'blue':
        return VietnameseStrings.blue;
      case 'green':
        return VietnameseStrings.green;
      case 'orange':
        return VietnameseStrings.orange;
      case 'pink':
        return VietnameseStrings.pink;
      case 'darkPurple':
        return VietnameseStrings.darkPurple;
      case 'indigo':
        return VietnameseStrings.indigo;
      case 'cyan':
        return VietnameseStrings.cyan;
      case 'brightOrange':
        return VietnameseStrings.brightOrange;
      case 'brown':
        return VietnameseStrings.brown;
      case 'blueGrey':
        return VietnameseStrings.blueGrey;
      default:
        return key;
    }
  }

  /// Lấy chuỗi tiếng Anh
  String _getEnglishString(String key) {
    switch (key) {
      case 'settings':
        return EnglishStrings.settings;
      case 'language':
        return EnglishStrings.language;
      case 'currency':
        return EnglishStrings.currency;
      case 'themeColor':
        return EnglishStrings.themeColor;
      case 'notifications':
        return EnglishStrings.notifications;
      case 'vietnamese':
        return EnglishStrings.vietnamese;
      case 'english':
        return EnglishStrings.english;
      case 'chooseLanguage':
        return EnglishStrings.chooseLanguage;
      case 'chooseCurrency':
        return EnglishStrings.chooseCurrency;
      case 'chooseThemeColor':
        return EnglishStrings.chooseThemeColor;
      case 'switchedToVietnamese':
        return EnglishStrings.switchedToVietnamese;
      case 'switchedToEnglish':
        return EnglishStrings.switchedToEnglish;
      case 'currencyChanged':
        return EnglishStrings.currencyChanged;
      case 'themeColorChanged':
        return EnglishStrings.themeColorChanged;
      case 'cancel':
        return EnglishStrings.cancel;
      case 'confirm':
        return EnglishStrings.confirm;
      case 'save':
        return EnglishStrings.save;
      case 'delete':
        return EnglishStrings.delete;
      case 'edit':
        return EnglishStrings.edit;
      case 'add':
        return EnglishStrings.add;
      case 'close':
        return EnglishStrings.close;
      case 'back':
        return EnglishStrings.back;
      case 'next':
        return EnglishStrings.next;
      case 'previous':
        return EnglishStrings.previous;
      case 'done':
        return EnglishStrings.done;
      case 'loading':
        return EnglishStrings.loading;
      case 'error':
        return EnglishStrings.error;
      case 'success':
        return EnglishStrings.success;
      case 'warning':
        return EnglishStrings.warning;
      case 'info':
        return EnglishStrings.info;
      case 'home':
        return EnglishStrings.home;
      case 'dashboard':
        return EnglishStrings.dashboard;
      case 'overview':
        return EnglishStrings.overview;
      case 'summary':
        return EnglishStrings.summary;
      case 'transactions':
        return EnglishStrings.transactions;
      case 'income':
        return EnglishStrings.income;
      case 'expense':
        return EnglishStrings.expense;
      case 'transfer':
        return EnglishStrings.transfer;
      case 'amount':
        return EnglishStrings.amount;
      case 'date':
        return EnglishStrings.date;
      case 'time':
        return EnglishStrings.time;
      case 'category':
        return EnglishStrings.category;
      case 'description':
        return EnglishStrings.description;
      case 'note':
        return EnglishStrings.note;
      case 'books':
        return EnglishStrings.books;
      case 'wallets':
        return EnglishStrings.wallets;
      case 'createBook':
        return EnglishStrings.createBook;
      case 'createWallet':
        return EnglishStrings.createWallet;
      case 'bookName':
        return EnglishStrings.bookName;
      case 'walletName':
        return EnglishStrings.walletName;
      case 'balance':
        return EnglishStrings.balance;
      case 'totalBalance':
        return EnglishStrings.totalBalance;
      case 'savings':
        return EnglishStrings.savings;
      case 'savingsGoals':
        return EnglishStrings.savingsGoals;
      case 'createSavingsGoal':
        return EnglishStrings.createSavingsGoal;
      case 'goalName':
        return EnglishStrings.goalName;
      case 'targetAmount':
        return EnglishStrings.targetAmount;
      case 'currentAmount':
        return EnglishStrings.currentAmount;
      case 'progress':
        return EnglishStrings.progress;
      case 'deadline':
        return EnglishStrings.deadline;
      case 'charts':
        return EnglishStrings.charts;
      case 'statistics':
        return EnglishStrings.statistics;
      case 'monthly':
        return EnglishStrings.monthly;
      case 'yearly':
        return EnglishStrings.yearly;
      case 'weekly':
        return EnglishStrings.weekly;
      case 'daily':
        return EnglishStrings.daily;
      case 'more':
        return EnglishStrings.more;
      case 'profile':
        return EnglishStrings.profile;
      case 'help':
        return EnglishStrings.help;
      case 'about':
        return EnglishStrings.about;
      case 'feedback':
        return EnglishStrings.feedback;
      case 'rateApp':
        return EnglishStrings.rateApp;
      case 'shareApp':
        return EnglishStrings.shareApp;
      case 'privacyPolicy':
        return EnglishStrings.privacyPolicy;
      case 'termsOfService':
        return EnglishStrings.termsOfService;
      case 'version':
        return EnglishStrings.version;
      case 'buildNumber':
        return EnglishStrings.buildNumber;
      case 'today':
        return EnglishStrings.today;
      case 'yesterday':
        return EnglishStrings.yesterday;
      case 'tomorrow':
        return EnglishStrings.tomorrow;
      case 'thisWeek':
        return EnglishStrings.thisWeek;
      case 'lastWeek':
        return EnglishStrings.lastWeek;
      case 'nextWeek':
        return EnglishStrings.nextWeek;
      case 'thisMonth':
        return EnglishStrings.thisMonth;
      case 'lastMonth':
        return EnglishStrings.lastMonth;
      case 'nextMonth':
        return EnglishStrings.nextMonth;
      case 'thisYear':
        return EnglishStrings.thisYear;
      case 'lastYear':
        return EnglishStrings.lastYear;
      case 'nextYear':
        return EnglishStrings.nextYear;
      case 'zero':
        return EnglishStrings.zero;
      case 'one':
        return EnglishStrings.one;
      case 'two':
        return EnglishStrings.two;
      case 'three':
        return EnglishStrings.three;
      case 'four':
        return EnglishStrings.four;
      case 'five':
        return EnglishStrings.five;
      case 'six':
        return EnglishStrings.six;
      case 'seven':
        return EnglishStrings.seven;
      case 'eight':
        return EnglishStrings.eight;
      case 'nine':
        return EnglishStrings.nine;
      case 'ten':
        return EnglishStrings.ten;
      case 'purple':
        return EnglishStrings.purple;
      case 'blue':
        return EnglishStrings.blue;
      case 'green':
        return EnglishStrings.green;
      case 'orange':
        return EnglishStrings.orange;
      case 'pink':
        return EnglishStrings.pink;
      case 'darkPurple':
        return EnglishStrings.darkPurple;
      case 'indigo':
        return EnglishStrings.indigo;
      case 'cyan':
        return EnglishStrings.cyan;
      case 'brightOrange':
        return EnglishStrings.brightOrange;
      case 'brown':
        return EnglishStrings.brown;
      case 'blueGrey':
        return EnglishStrings.blueGrey;
      default:
        return key;
    }
  }

  // Thêm method cho ngôn ngữ mới
  // String _getFrenchString(String key) {
  //   switch (key) {
  //     case 'settings': return FrenchStrings.settings;
  //     // ... thêm các case khác
  //     default: return key;
  //   }
  // }

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

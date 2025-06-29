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
  String get note => _getString('Note');
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
    switch (key) {
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
      case 'loading':
        return VietnameseStrings.loading;
      case 'error':
        return VietnameseStrings.error;
      case 'success':
        return VietnameseStrings.success;
      case 'total':
        return VietnameseStrings.total;
      case 'editBookName':
        return VietnameseStrings.editBookName;
      case 'newBookName':
        return VietnameseStrings.newBookName;
      case 'bookNameExists':
        return VietnameseStrings.bookNameExists;
      case 'pleaseChooseDifferentName':
        return VietnameseStrings.pleaseChooseDifferentName;
      case 'updateBookNameSuccess':
        return VietnameseStrings.updateBookNameSuccess;
      case 'updateBookError':
        return VietnameseStrings.updateBookError;
      case 'pleaseEnterBookName':
        return VietnameseStrings.pleaseEnterBookName;
      case 'saveChanges':
        return VietnameseStrings.saveChanges;
      case 'editSavingsGoal':
        return VietnameseStrings.editSavingsGoal;
      case 'deleteSavingsGoal':
        return VietnameseStrings.deleteSavingsGoal;
      case 'confirmDelete':
        return VietnameseStrings.confirmDelete;
      case 'confirmDeleteMessage':
        return VietnameseStrings.confirmDeleteMessage;
      case 'deleteSuccess':
        return VietnameseStrings.deleteSuccess;
      case 'updateSuccess':
        return VietnameseStrings.updateSuccess;
      case 'currentInformation':
        return VietnameseStrings.currentInformation;
      case 'savedAmount':
        return VietnameseStrings.savedAmount;
      case 'progressLabel':
        return VietnameseStrings.progressLabel;
      case 'dataLoadError':
        return VietnameseStrings.dataLoadError;
      case 'completed':
        return VietnameseStrings.completed;
      case 'overdue':
        return VietnameseStrings.overdue;
      case 'closed':
        return VietnameseStrings.closed;
      case 'inProgress':
        return VietnameseStrings.inProgress;
      case 'target':
        return VietnameseStrings.target;
      case 'targetCompletionDate':
        return VietnameseStrings.targetCompletionDate;
      case 'savingsBookName':
        return VietnameseStrings.savingsBookName;
      case 'enterName':
        return VietnameseStrings.enterName;
      case 'enterAmount':
        return VietnameseStrings.enterAmount;
      case 'amountMustBeGreaterThanZero':
        return VietnameseStrings.amountMustBeGreaterThanZero;
      case 'startDate':
        return VietnameseStrings.startDate;
      case 'chooseDate':
        return VietnameseStrings.chooseDate;
      case 'targetDate':
        return VietnameseStrings.targetDate;
      case 'chooseDateOptional':
        return VietnameseStrings.chooseDateOptional;
      case 'pleaseSelectStartDate':
        return VietnameseStrings.pleaseSelectStartDate;
      case 'targetAmountCannotBeLessThanSaved':
        return VietnameseStrings.targetAmountCannotBeLessThanSaved;
      case 'noBook':
        return VietnameseStrings.noBook;
      case 'createFirstBook':
        return VietnameseStrings.createFirstBook;
      case 'expense':
        return VietnameseStrings.expense;
      case 'income':
        return VietnameseStrings.income;
      case 'noExpenseThisMonth':
        return VietnameseStrings.noExpenseThisMonth;
      case 'totalExpense':
        return VietnameseStrings.totalExpense;
      case 'totalIncome':
        return VietnameseStrings.totalIncome;
      case 'noIncomeThisMonth':
        return VietnameseStrings.noIncomeThisMonth;
      case 'analysis':
        return VietnameseStrings.analysis;
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
      case 'black':
        return VietnameseStrings.black;
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
      case 'chooseLanguage':
        return VietnameseStrings.chooseLanguage;
      case 'chooseThemeColor':
        return VietnameseStrings.chooseThemeColor;
      case 'extraFeatures':
        return VietnameseStrings.extraFeatures;
      case 'savingsGoals':
        return VietnameseStrings.savingsGoals;
      case 'setupAndTrack':
        return VietnameseStrings.setupAndTrack;
      case 'periodicInvoices':
        return VietnameseStrings.periodicInvoices;
      case 'managePeriodicBills':
        return VietnameseStrings.managePeriodicBills;
      case 'books':
        return VietnameseStrings.books;
      case 'createBook':
        return VietnameseStrings.createBook;
      case 'progress':
        return VietnameseStrings.progress;
      case 'editTransaction':
        return VietnameseStrings.editTransaction;
      case 'note':
        return VietnameseStrings.note;
      case 'selectExpenseCategory':
        return VietnameseStrings.selectExpenseCategory;
      case 'selectIncomeCategory':
        return VietnameseStrings.selectIncomeCategory;
      case 'category':
        return VietnameseStrings.category;
      case 'chooseCategory':
        return VietnameseStrings.chooseCategory;
      case 'addTransaction':
        return VietnameseStrings.addTransaction;
      case 'createFlexibleSavingsGoal':
        return VietnameseStrings.createFlexibleSavingsGoal;
      case 'createPeriodicSavingsGoal':
        return VietnameseStrings.createPeriodicSavingsGoal;
      case 'targetAmount':
        return VietnameseStrings.targetAmount;
      case 'expenseBookList':
        return VietnameseStrings.expenseBookList;
      case 'switchedToVietnamese':
        return VietnameseStrings.switchedToVietnamese;
      case 'switchedToEnglish':
        return VietnameseStrings.switchedToEnglish;
      case 'charts':
        return VietnameseStrings.charts;
      case 'more':
        return VietnameseStrings.more;
      case 'pleaseSelectFrequency':
        return VietnameseStrings.pleaseSelectFrequency;
      case 'tryAgain':
        return VietnameseStrings.tryAgain;
      case 'confirmDeleteInvoice':
        return VietnameseStrings.confirmDeleteInvoice;
      case 'minimumAmount':
        return VietnameseStrings.minimumAmount;
      case 'maximumAmount':
        return VietnameseStrings.maximumAmount;
      case 'invoiceName':
        return VietnameseStrings.invoiceName;
      case 'expenseBook':
        return VietnameseStrings.expenseBook;
      case 'paymentAmount':
        return VietnameseStrings.paymentAmount;
      case 'details':
        return VietnameseStrings.details;
      case 'noteOptional':
        return VietnameseStrings.noteOptional;
      case 'periodicDeposit':
        return VietnameseStrings.periodicDeposit;
      case 'paidSuccessfully':
        return VietnameseStrings.paidSuccessfully;
      case 'paymentError':
        return VietnameseStrings.paymentError;
      case 'errorOccurred':
        return VietnameseStrings.errorOccurred;
      case 'reminderFrequency':
        return VietnameseStrings.reminderFrequency;
      case 'editPeriodicSavingsGoal':
        return VietnameseStrings.editPeriodicSavingsGoal;
      case 'periodicAmount':
        return VietnameseStrings.periodicAmount;
      case 'chooseFrequency':
        return VietnameseStrings.chooseFrequency;
      case 'daily':
        return VietnameseStrings.daily;
      case 'weekly':
        return VietnameseStrings.weekly;
      case 'monthly':
        return VietnameseStrings.monthly;
      case 'enterPeriodicAmount':
        return VietnameseStrings.enterPeriodicAmount;
      case 'periodicAmountMustBeGreaterThanZero':
        return VietnameseStrings.periodicAmountMustBeGreaterThanZero;
      case 'updateBook':
        return VietnameseStrings.updateBook;
      case 'invoice':
        return VietnameseStrings.invoice;
      case 'calendar':
        return VietnameseStrings.calendar;
      case 'all':
        return VietnameseStrings.all;
      case 'noExpenseYet':
        return VietnameseStrings.noExpenseYet;
      case 'noPeriodicInvoicesYet':
        return VietnameseStrings.noPeriodicInvoicesYet;
      case 'createNewInvoice':
        return VietnameseStrings.createNewInvoice;
      case 'filter':
        return VietnameseStrings.filter;
      case 'allBooks':
        return VietnameseStrings.allBooks;
      case 'allCategories':
        return VietnameseStrings.allCategories;
      case 'enterValidNumber':
        return VietnameseStrings.enterValidNumber;
      case 'clearFilter':
        return VietnameseStrings.clearFilter;
      case 'paid':
        return VietnameseStrings.paid;
      case 'pendingPayment':
        return VietnameseStrings.pendingPayment;
      case 'frequency':
        return VietnameseStrings.frequency;
      case 'createPeriodicInvoice':
        return VietnameseStrings.createPeriodicInvoice;
      case 'pleaseEnterInvoiceName':
        return VietnameseStrings.pleaseEnterInvoiceName;
      case 'createInvoice':
        return VietnameseStrings.createInvoice;
      case 'bookNotExists':
        return VietnameseStrings.bookNotExists;
      case 'pay':
        return VietnameseStrings.pay;
      case 'payNow':
        return VietnameseStrings.payNow;
      case 'invoiceAddedSuccessfully':
        return VietnameseStrings.invoiceAddedSuccessfully;
      case 'errorCreatingInvoice':
        return VietnameseStrings.errorCreatingInvoice;
      case 'yearly':
        return VietnameseStrings.yearly;
      case 'themeColorChanged':
        return VietnameseStrings.themeColorChanged;
      case 'currencyChanged':
        return VietnameseStrings.currencyChanged;
      case 'flexibleSavingsBook':
        return VietnameseStrings.flexibleSavingsBook;
      case 'periodicSavingsBook':
        return VietnameseStrings.periodicSavingsBook;
      case 'saved':
        return VietnameseStrings.saved;
      case 'remaining':
        return VietnameseStrings.remaining;
      case 'targetDateLabel':
        return VietnameseStrings.targetDateLabel;
      case 'periodicDepositLabel':
        return VietnameseStrings.periodicDepositLabel;
      case 'depositHistory':
        return VietnameseStrings.depositHistory;
      case 'noDepositHistory':
        return VietnameseStrings.noDepositHistory;
      case 'deposit':
        return VietnameseStrings.deposit;
      case 'depositMoney':
        return VietnameseStrings.depositMoney;
      case 'confirmDeposit':
        return VietnameseStrings.confirmDeposit;
      case 'depositBeforeNextPeriod':
        return VietnameseStrings.depositBeforeNextPeriod;
      case 'youAreDepositingBeforeNextPeriod':
        return VietnameseStrings.youAreDepositingBeforeNextPeriod;
      case 'continueDeposit':
        return VietnameseStrings.continueDeposit;
      case 'frequencyDaily':
        return VietnameseStrings.frequencyDaily;
      case 'frequencyWeekly':
        return VietnameseStrings.frequencyWeekly;
      case 'frequencyMonthly':
        return VietnameseStrings.frequencyMonthly;
      case 'flexibleSavings':
        return VietnameseStrings.flexibleSavings;
      case 'noFlexibleSavings':
        return VietnameseStrings.noFlexibleSavings;
      case 'createNewSavings':
        return VietnameseStrings.createNewSavings;
      case 'savingsOverdue':
        return VietnameseStrings.savingsOverdue;
      case 'savingsClosed':
        return VietnameseStrings.savingsClosed;
      case 'periodicSavings':
        return VietnameseStrings.periodicSavings;
      case 'noPeriodicSavings':
        return VietnameseStrings.noPeriodicSavings;
      case 'savingsGoalsTitle':
        return VietnameseStrings.savingsGoalsTitle;
      case 'flexibleSavingsDescription':
        return VietnameseStrings.flexibleSavingsDescription;
      case 'periodicSavingsDescription':
        return VietnameseStrings.periodicSavingsDescription;
      case 'enterAmountToDeposit':
        return VietnameseStrings.enterAmountToDeposit;
      case 'amountHint':
        return VietnameseStrings.amountHint;
      case 'depositSuccess':
        return VietnameseStrings.depositSuccess;
      case 'noNotifications':
        return VietnameseStrings.noNotifications;
      case 'refresh':
        return VietnameseStrings.refresh;
      case 'markAllAsRead':
        return VietnameseStrings.markAllAsRead;
      case 'deleteAllRead':
        return VietnameseStrings.deleteAllRead;
      case 'justNow':
        return VietnameseStrings.justNow;
      case 'daysAgoWith':
        return VietnameseStrings.daysAgoWith;
      case 'hoursAgoWith':
        return VietnameseStrings.hoursAgoWith;
      case 'minutesAgoWith':
        return VietnameseStrings.minutesAgoWith;
      case 'daysAgo':
        return VietnameseStrings.daysAgo;
      case 'hoursAgo':
        return VietnameseStrings.hoursAgo;
      case 'minutesAgo':
        return VietnameseStrings.minutesAgo;
      case 'monday':
        return VietnameseStrings.monday;
      case 'tuesday':
        return VietnameseStrings.tuesday;
      case 'wednesday':
        return VietnameseStrings.wednesday;
      case 'thursday':
        return VietnameseStrings.thursday;
      case 'friday':
        return VietnameseStrings.friday;
      case 'saturday':
        return VietnameseStrings.saturday;
      case 'sunday':
        return VietnameseStrings.sunday;
      case 'deleteSavingsBook':
        return VietnameseStrings.deleteSavingsBook;
      case 'deleteExpenseBook':
        return VietnameseStrings.deleteExpenseBook;
      case 'confirmDeleteExpenseBook':
        return VietnameseStrings.confirmDeleteExpenseBook;
      case 'deleteExpenseBookSuccess':
        return VietnameseStrings.deleteExpenseBookSuccess;
      case 'deleteExpenseBookError':
        return VietnameseStrings.deleteExpenseBookError;
      case 'deletingExpenseBook':
        return VietnameseStrings.deletingExpenseBook;
      case 'update':
        return VietnameseStrings.update;
      default:
        return key;
    }
  }

  /// Lấy chuỗi tiếng Anh
  String _getEnglishString(String key) {
    switch (key) {
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
      case 'loading':
        return EnglishStrings.loading;
      case 'error':
        return EnglishStrings.error;
      case 'success':
        return EnglishStrings.success;
      case 'total':
        return EnglishStrings.total;
      case 'editBookName':
        return EnglishStrings.editBookName;
      case 'newBookName':
        return EnglishStrings.newBookName;
      case 'bookNameExists':
        return EnglishStrings.bookNameExists;
      case 'pleaseChooseDifferentName':
        return EnglishStrings.pleaseChooseDifferentName;
      case 'updateBookNameSuccess':
        return EnglishStrings.updateBookNameSuccess;
      case 'updateBookError':
        return EnglishStrings.updateBookError;
      case 'pleaseEnterBookName':
        return EnglishStrings.pleaseEnterBookName;
      case 'saveChanges':
        return EnglishStrings.saveChanges;
      case 'editSavingsGoal':
        return EnglishStrings.editSavingsGoal;
      case 'deleteSavingsGoal':
        return EnglishStrings.deleteSavingsGoal;
      case 'confirmDelete':
        return EnglishStrings.confirmDelete;
      case 'confirmDeleteMessage':
        return EnglishStrings.confirmDeleteMessage;
      case 'deleteSuccess':
        return EnglishStrings.deleteSuccess;
      case 'updateSuccess':
        return EnglishStrings.updateSuccess;
      case 'currentInformation':
        return EnglishStrings.currentInformation;
      case 'savedAmount':
        return EnglishStrings.savedAmount;
      case 'progressLabel':
        return EnglishStrings.progressLabel;
      case 'dataLoadError':
        return EnglishStrings.dataLoadError;
      case 'completed':
        return EnglishStrings.completed;
      case 'overdue':
        return EnglishStrings.overdue;
      case 'closed':
        return EnglishStrings.closed;
      case 'inProgress':
        return EnglishStrings.inProgress;
      case 'target':
        return EnglishStrings.target;
      case 'targetCompletionDate':
        return EnglishStrings.targetCompletionDate;
      case 'savingsBookName':
        return EnglishStrings.savingsBookName;
      case 'enterName':
        return EnglishStrings.enterName;
      case 'enterAmount':
        return EnglishStrings.enterAmount;
      case 'amountMustBeGreaterThanZero':
        return EnglishStrings.amountMustBeGreaterThanZero;
      case 'startDate':
        return EnglishStrings.startDate;
      case 'chooseDate':
        return EnglishStrings.chooseDate;
      case 'targetDate':
        return EnglishStrings.targetDate;
      case 'chooseDateOptional':
        return EnglishStrings.chooseDateOptional;
      case 'pleaseSelectStartDate':
        return EnglishStrings.pleaseSelectStartDate;
      case 'targetAmountCannotBeLessThanSaved':
        return EnglishStrings.targetAmountCannotBeLessThanSaved;
      case 'noBook':
        return EnglishStrings.noBook;
      case 'createFirstBook':
        return EnglishStrings.createFirstBook;
      case 'expense':
        return EnglishStrings.expense;
      case 'income':
        return EnglishStrings.income;
      case 'noExpenseThisMonth':
        return EnglishStrings.noExpenseThisMonth;
      case 'totalExpense':
        return EnglishStrings.totalExpense;
      case 'totalIncome':
        return EnglishStrings.totalIncome;
      case 'noIncomeThisMonth':
        return EnglishStrings.noIncomeThisMonth;
      case 'analysis':
        return EnglishStrings.analysis;
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
      case 'black':
        return EnglishStrings.black;
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
      case 'chooseLanguage':
        return EnglishStrings.chooseLanguage;
      case 'chooseThemeColor':
        return EnglishStrings.chooseThemeColor;
      case 'extraFeatures':
        return EnglishStrings.extraFeatures;
      case 'savingsGoals':
        return EnglishStrings.savingsGoals;
      case 'setupAndTrack':
        return EnglishStrings.setupAndTrack;
      case 'periodicInvoices':
        return EnglishStrings.periodicInvoices;
      case 'managePeriodicBills':
        return EnglishStrings.managePeriodicBills;
      case 'books':
        return EnglishStrings.books;
      case 'createBook':
        return EnglishStrings.createBook;
      case 'progress':
        return EnglishStrings.progress;
      case 'editTransaction':
        return EnglishStrings.editTransaction;
      case 'note':
        return EnglishStrings.note;
      case 'selectExpenseCategory':
        return EnglishStrings.selectExpenseCategory;
      case 'selectIncomeCategory':
        return EnglishStrings.selectIncomeCategory;
      case 'category':
        return EnglishStrings.category;
      case 'chooseCategory':
        return EnglishStrings.chooseCategory;
      case 'addTransaction':
        return EnglishStrings.addTransaction;
      case 'createFlexibleSavingsGoal':
        return EnglishStrings.createFlexibleSavingsGoal;
      case 'createPeriodicSavingsGoal':
        return EnglishStrings.createPeriodicSavingsGoal;
      case 'targetAmount':
        return EnglishStrings.targetAmount;
      case 'expenseBookList':
        return EnglishStrings.expenseBookList;
      case 'switchedToVietnamese':
        return EnglishStrings.switchedToVietnamese;
      case 'switchedToEnglish':
        return EnglishStrings.switchedToEnglish;
      case 'charts':
        return EnglishStrings.charts;
      case 'more':
        return EnglishStrings.more;
      case 'pleaseSelectFrequency':
        return EnglishStrings.pleaseSelectFrequency;
      case 'tryAgain':
        return EnglishStrings.tryAgain;
      case 'confirmDeleteInvoice':
        return EnglishStrings.confirmDeleteInvoice;
      case 'minimumAmount':
        return EnglishStrings.minimumAmount;
      case 'maximumAmount':
        return EnglishStrings.maximumAmount;
      case 'invoiceName':
        return EnglishStrings.invoiceName;
      case 'expenseBook':
        return EnglishStrings.expenseBook;
      case 'paymentAmount':
        return EnglishStrings.paymentAmount;
      case 'details':
        return EnglishStrings.details;
      case 'noteOptional':
        return EnglishStrings.noteOptional;
      case 'periodicDeposit':
        return EnglishStrings.periodicDeposit;
      case 'paidSuccessfully':
        return EnglishStrings.paidSuccessfully;
      case 'paymentError':
        return EnglishStrings.paymentError;
      case 'errorOccurred':
        return EnglishStrings.errorOccurred;
      case 'reminderFrequency':
        return EnglishStrings.reminderFrequency;
      case 'editPeriodicSavingsGoal':
        return EnglishStrings.editPeriodicSavingsGoal;
      case 'periodicAmount':
        return EnglishStrings.periodicAmount;
      case 'chooseFrequency':
        return EnglishStrings.chooseFrequency;
      case 'daily':
        return EnglishStrings.daily;
      case 'weekly':
        return EnglishStrings.weekly;
      case 'monthly':
        return EnglishStrings.monthly;
      case 'enterPeriodicAmount':
        return EnglishStrings.enterPeriodicAmount;
      case 'periodicAmountMustBeGreaterThanZero':
        return EnglishStrings.periodicAmountMustBeGreaterThanZero;
      case 'updateBook':
        return EnglishStrings.updateBook;
      case 'invoice':
        return EnglishStrings.invoice;
      case 'calendar':
        return EnglishStrings.calendar;
      case 'all':
        return EnglishStrings.all;
      case 'noExpenseYet':
        return EnglishStrings.noExpenseYet;
      case 'noPeriodicInvoicesYet':
        return EnglishStrings.noPeriodicInvoicesYet;
      case 'createNewInvoice':
        return EnglishStrings.createNewInvoice;
      case 'filter':
        return EnglishStrings.filter;
      case 'allBooks':
        return EnglishStrings.allBooks;
      case 'allCategories':
        return EnglishStrings.allCategories;
      case 'enterValidNumber':
        return EnglishStrings.enterValidNumber;
      case 'clearFilter':
        return EnglishStrings.clearFilter;
      case 'paid':
        return EnglishStrings.paid;
      case 'pendingPayment':
        return EnglishStrings.pendingPayment;
      case 'frequency':
        return EnglishStrings.frequency;
      case 'createPeriodicInvoice':
        return EnglishStrings.createPeriodicInvoice;
      case 'pleaseEnterInvoiceName':
        return EnglishStrings.pleaseEnterInvoiceName;
      case 'createInvoice':
        return EnglishStrings.createInvoice;
      case 'bookNotExists':
        return EnglishStrings.bookNotExists;
      case 'pay':
        return EnglishStrings.pay;
      case 'payNow':
        return EnglishStrings.payNow;
      case 'invoiceAddedSuccessfully':
        return EnglishStrings.invoiceAddedSuccessfully;
      case 'errorCreatingInvoice':
        return EnglishStrings.errorCreatingInvoice;
      case 'yearly':
        return EnglishStrings.yearly;
      case 'themeColorChanged':
        return EnglishStrings.themeColorChanged;
      case 'currencyChanged':
        return EnglishStrings.currencyChanged;
      case 'flexibleSavingsBook':
        return EnglishStrings.flexibleSavingsBook;
      case 'periodicSavingsBook':
        return EnglishStrings.periodicSavingsBook;
      case 'saved':
        return EnglishStrings.saved;
      case 'remaining':
        return EnglishStrings.remaining;
      case 'targetDateLabel':
        return EnglishStrings.targetDateLabel;
      case 'periodicDepositLabel':
        return EnglishStrings.periodicDepositLabel;
      case 'depositHistory':
        return EnglishStrings.depositHistory;
      case 'noDepositHistory':
        return EnglishStrings.noDepositHistory;
      case 'deposit':
        return EnglishStrings.deposit;
      case 'depositMoney':
        return EnglishStrings.depositMoney;
      case 'confirmDeposit':
        return EnglishStrings.confirmDeposit;
      case 'depositBeforeNextPeriod':
        return EnglishStrings.depositBeforeNextPeriod;
      case 'youAreDepositingBeforeNextPeriod':
        return EnglishStrings.youAreDepositingBeforeNextPeriod;
      case 'continueDeposit':
        return EnglishStrings.continueDeposit;
      case 'frequencyDaily':
        return EnglishStrings.frequencyDaily;
      case 'frequencyWeekly':
        return EnglishStrings.frequencyWeekly;
      case 'frequencyMonthly':
        return EnglishStrings.frequencyMonthly;
      case 'flexibleSavings':
        return EnglishStrings.flexibleSavings;
      case 'noFlexibleSavings':
        return EnglishStrings.noFlexibleSavings;
      case 'createNewSavings':
        return EnglishStrings.createNewSavings;
      case 'savingsOverdue':
        return EnglishStrings.savingsOverdue;
      case 'savingsClosed':
        return EnglishStrings.savingsClosed;
      case 'periodicSavings':
        return EnglishStrings.periodicSavings;
      case 'noPeriodicSavings':
        return EnglishStrings.noPeriodicSavings;
      case 'savingsGoalsTitle':
        return EnglishStrings.savingsGoalsTitle;
      case 'flexibleSavingsDescription':
        return EnglishStrings.flexibleSavingsDescription;
      case 'periodicSavingsDescription':
        return EnglishStrings.periodicSavingsDescription;
      case 'enterAmountToDeposit':
        return EnglishStrings.enterAmountToDeposit;
      case 'amountHint':
        return EnglishStrings.amountHint;
      case 'depositSuccess':
        return EnglishStrings.depositSuccess;
      case 'noNotifications':
        return EnglishStrings.noNotifications;
      case 'refresh':
        return EnglishStrings.refresh;
      case 'markAllAsRead':
        return EnglishStrings.markAllAsRead;
      case 'deleteAllRead':
        return EnglishStrings.deleteAllRead;
      case 'justNow':
        return EnglishStrings.justNow;
      case 'daysAgoWith':
        return EnglishStrings.daysAgoWith;
      case 'hoursAgoWith':
        return EnglishStrings.hoursAgoWith;
      case 'minutesAgoWith':
        return EnglishStrings.minutesAgoWith;
      case 'daysAgo':
        return EnglishStrings.daysAgo;
      case 'hoursAgo':
        return EnglishStrings.hoursAgo;
      case 'minutesAgo':
        return EnglishStrings.minutesAgo;
      case 'monday':
        return EnglishStrings.monday;
      case 'tuesday':
        return EnglishStrings.tuesday;
      case 'wednesday':
        return EnglishStrings.wednesday;
      case 'thursday':
        return EnglishStrings.thursday;
      case 'friday':
        return EnglishStrings.friday;
      case 'saturday':
        return EnglishStrings.saturday;
      case 'sunday':
        return EnglishStrings.sunday;
      case 'deleteSavingsBook':
        return EnglishStrings.deleteSavingsBook;
      case 'deleteExpenseBook':
        return EnglishStrings.deleteExpenseBook;
      case 'confirmDeleteExpenseBook':
        return EnglishStrings.confirmDeleteExpenseBook;
      case 'deleteExpenseBookSuccess':
        return EnglishStrings.deleteExpenseBookSuccess;
      case 'deleteExpenseBookError':
        return EnglishStrings.deleteExpenseBookError;
      case 'deletingExpenseBook':
        return EnglishStrings.deletingExpenseBook;
      case 'update':
        return EnglishStrings.update;
      default:
        return key;
    }
  }

  /// Danh sách Locale được hỗ trợ
  static List<Locale> get supportedLocales =>
      SupportedLanguages.supportedLocales;

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

  String get targetAmountLabel => _getString('targetAmountLabel');
  String get startDateLabel => _getString('startDateLabel');
  String get chooseDateLabel => _getString('chooseDateLabel');
  String get deleteSavingsBook => _getString('deleteSavingsBook');
  String get deleteExpenseBook => _getString('deleteExpenseBook');
  String get deleteExpenseBookSuccess => _getString('deleteExpenseBookSuccess');
  String get deletingExpenseBook => _getString('deletingExpenseBook');
  String get update => _getString('update');
  String get foodAndDrinks => _getString('Foood');
  String get transportation => _getString('Transportation');
  String get shopping => _getString('Shopping');
  String get entertainment => _getString('Entertainment');
  String get education => _getString('Education');
  String get beauty => _getString('Beauty');
  String get household => _getString('Household');
  String get salary => _getString('Salary');
  String get bonus => _getString('Bonus');
  String get investment => _getString('Investment');

  String confirmDeleteExpenseBook(String bookName) {
    final template = _getString('confirmDeleteExpenseBook');
    return template.replaceAll('{bookName}', bookName);
  }

  String deleteExpenseBookError(String error) {
    final template = _getString('deleteExpenseBookError');
    return template.replaceAll('{error}', error);
  }
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

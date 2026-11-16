// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Expense Tracker';

  @override
  String get onboardingTitle1 => 'Scan receipts\nin seconds';

  @override
  String get onboardingBody1 =>
      'Point your camera at a receipt and let OCR fill in the details.';

  @override
  String get onboardingTitle2 => 'Know where your\nmoney goes';

  @override
  String get onboardingBody2 =>
      'Smart categories and charts show your spending at a glance.';

  @override
  String get onboardingTitle3 => 'Stay under\nbudget';

  @override
  String get onboardingBody3 => 'Set a monthly budget and track it day by day.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get greetingSub => 'Let\'s keep your spending on track';

  @override
  String get spentThisMonth => 'Spent this month';

  @override
  String moreThanLastMonth(int percent) {
    return '$percent% more than last month';
  }

  @override
  String lessThanLastMonth(int percent) {
    return '$percent% less than last month';
  }

  @override
  String get sameAsLastMonth => 'Same as last month';

  @override
  String get noLastMonthData => 'No data for last month';

  @override
  String get quickScan => 'Scan';

  @override
  String get quickImport => 'Import';

  @override
  String get quickAdd => 'Add';

  @override
  String get quickDemo => 'Demo';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get seeAll => 'See all';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get navHome => 'Home';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navBills => 'Bills';

  @override
  String get navSettings => 'Settings';

  @override
  String get navScan => 'Scan receipt';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get tabSpending => 'Spending';

  @override
  String get tabTrends => 'Trends';

  @override
  String get yourSpending => 'Your Spending';

  @override
  String get totalSpent => 'Total Spent';

  @override
  String get noSpending => 'No spending recorded this month.';

  @override
  String budgetUnder(int percent) {
    return 'You\'re $percent% under budget!';
  }

  @override
  String budgetOver(int percent) {
    return 'You\'re $percent% over budget';
  }

  @override
  String get budgetUnderHint => 'Great job managing your spending this month.';

  @override
  String get budgetOverHint =>
      'Consider slowing down for the rest of the month.';

  @override
  String budgetLeft(String amount, String budget) {
    return '$amount left of $budget';
  }

  @override
  String get budgetSetTitle => 'Set a monthly budget';

  @override
  String get budgetSetHint => 'Track how much you can still spend.';

  @override
  String get trendLast7 => 'Last 7 days';

  @override
  String get trendLast6Months => 'Last 6 months';

  @override
  String weekTotal(String amount) {
    return 'Week total: $amount';
  }

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get transactionsTitle => 'All transactions';

  @override
  String get searchHint => 'Search merchant';

  @override
  String get filterAll => 'All';

  @override
  String get noReceipts => 'No receipts yet. Tap the scan button to add one.';

  @override
  String get noResults => 'Nothing matches your search.';

  @override
  String loadFailed(String error) {
    return 'Could not load data: $error';
  }

  @override
  String deletedItem(String name) {
    return 'Deleted $name';
  }

  @override
  String get undo => 'Undo';

  @override
  String get loadDemo => 'Load demo data';

  @override
  String demoLoaded(int count) {
    return 'Loaded $count demo receipts.';
  }

  @override
  String demoFailed(String error) {
    return 'Could not load demo data: $error';
  }

  @override
  String get scanTitle => 'Scan receipt';

  @override
  String get importImage => 'Import';

  @override
  String get samples => 'Samples';

  @override
  String get sampleReceiptsTitle => 'Sample receipts';

  @override
  String get sampleReceiptsSubtitle =>
      'Demo data for trying the OCR and parser';

  @override
  String get readingReceipt => 'Reading receipt…';

  @override
  String get firstScanWeb =>
      'The first scan downloads the OCR language data and can take a while.';

  @override
  String get noTextFound =>
      'No text found. Adjust the frame or try another image.';

  @override
  String scanFailed(String error) {
    return 'Scan failed: $error';
  }

  @override
  String cameraUnavailable(String code) {
    return 'Camera unavailable ($code). Allow camera access, or import an image instead.';
  }

  @override
  String get noCamera => 'No camera found on this device.';

  @override
  String captureFailed(String code) {
    return 'Capture failed ($code).';
  }

  @override
  String flashUnavailable(String code) {
    return 'Flash unavailable ($code).';
  }

  @override
  String get flashOn => 'Flash on';

  @override
  String get flashOff => 'Flash off';

  @override
  String get reviewTitle => 'Review receipt';

  @override
  String get editTitle => 'Edit receipt';

  @override
  String get addTitle => 'Add expense';

  @override
  String get fieldMerchant => 'Merchant';

  @override
  String get fieldTotal => 'Total';

  @override
  String get fieldDate => 'Date & time';

  @override
  String get fieldCategory => 'Category';

  @override
  String get fieldReceiptNo => 'Receipt number (optional)';

  @override
  String get items => 'Items';

  @override
  String get removeItem => 'Remove item';

  @override
  String get save => 'Save';

  @override
  String get enterMerchant => 'Enter the merchant name';

  @override
  String get enterTotal => 'Enter the total amount';

  @override
  String get notDetected => 'Not detected, please fill in';

  @override
  String savedItem(String name) {
    return 'Saved $name';
  }

  @override
  String saveFailed(String error) {
    return 'Could not save: $error';
  }

  @override
  String get catFood => 'Food';

  @override
  String get catStudy => 'Study';

  @override
  String get catTravel => 'Travel';

  @override
  String get catGear => 'Gear';

  @override
  String get catEntertainment => 'Entertainment';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get monthlyBudget => 'Monthly budget';

  @override
  String get budgetNotSet => 'Not set';

  @override
  String get budgetDialogTitle => 'Monthly budget (VND)';

  @override
  String get budgetClear => 'Remove budget';

  @override
  String get cancel => 'Cancel';

  @override
  String get demoSection => 'Demo';

  @override
  String get aboutSection => 'About';

  @override
  String get aboutBody =>
      'Receipts are read on your device: ML Kit on mobile, Tesseract.js in the browser. Nothing is uploaded.';

  @override
  String get billsTitle => 'Daily bills';

  @override
  String get noBills => 'No bills on this day.';

  @override
  String billsCount(int count, String amount) {
    return '$count bills · $amount';
  }

  @override
  String get dragHint => 'Drag the top bill away to see the next';

  @override
  String get previousDay => 'Previous day';

  @override
  String get nextDay => 'Next day';

  @override
  String get viewDesktop => 'Desktop';

  @override
  String get viewPhone => 'Phone';

  @override
  String get switchToPhone => 'Switch to phone view';

  @override
  String get switchToDesktop => 'Switch to desktop view';

  @override
  String get switchLanguage => 'Switch language';
}

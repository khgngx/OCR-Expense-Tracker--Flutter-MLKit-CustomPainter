import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense Tracker'**
  String get appTitle;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Scan receipts\nin seconds'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at a receipt and let OCR fill in the details.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Know where your\nmoney goes'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Smart categories and charts show your spending at a glance.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Stay under\nbudget'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly budget and track it day by day.'**
  String get onboardingBody3;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @greetingSub.
  ///
  /// In en, this message translates to:
  /// **'Let\'s keep your spending on track'**
  String get greetingSub;

  /// No description provided for @spentThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Spent this month'**
  String get spentThisMonth;

  /// No description provided for @moreThanLastMonth.
  ///
  /// In en, this message translates to:
  /// **'{percent}% more than last month'**
  String moreThanLastMonth(int percent);

  /// No description provided for @lessThanLastMonth.
  ///
  /// In en, this message translates to:
  /// **'{percent}% less than last month'**
  String lessThanLastMonth(int percent);

  /// No description provided for @sameAsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Same as last month'**
  String get sameAsLastMonth;

  /// No description provided for @noLastMonthData.
  ///
  /// In en, this message translates to:
  /// **'No data for last month'**
  String get noLastMonthData;

  /// No description provided for @quickScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get quickScan;

  /// No description provided for @quickImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get quickImport;

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get quickAdd;

  /// No description provided for @quickDemo.
  ///
  /// In en, this message translates to:
  /// **'Demo'**
  String get quickDemo;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @navBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get navBills;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan receipt'**
  String get navScan;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @tabSpending.
  ///
  /// In en, this message translates to:
  /// **'Spending'**
  String get tabSpending;

  /// No description provided for @tabTrends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get tabTrends;

  /// No description provided for @yourSpending.
  ///
  /// In en, this message translates to:
  /// **'Your Spending'**
  String get yourSpending;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @noSpending.
  ///
  /// In en, this message translates to:
  /// **'No spending recorded this month.'**
  String get noSpending;

  /// No description provided for @budgetUnder.
  ///
  /// In en, this message translates to:
  /// **'You\'re {percent}% under budget!'**
  String budgetUnder(int percent);

  /// No description provided for @budgetOver.
  ///
  /// In en, this message translates to:
  /// **'You\'re {percent}% over budget'**
  String budgetOver(int percent);

  /// No description provided for @budgetUnderHint.
  ///
  /// In en, this message translates to:
  /// **'Great job managing your spending this month.'**
  String get budgetUnderHint;

  /// No description provided for @budgetOverHint.
  ///
  /// In en, this message translates to:
  /// **'Consider slowing down for the rest of the month.'**
  String get budgetOverHint;

  /// No description provided for @budgetLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left of {budget}'**
  String budgetLeft(String amount, String budget);

  /// No description provided for @budgetSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly budget'**
  String get budgetSetTitle;

  /// No description provided for @budgetSetHint.
  ///
  /// In en, this message translates to:
  /// **'Track how much you can still spend.'**
  String get budgetSetHint;

  /// No description provided for @trendLast7.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get trendLast7;

  /// No description provided for @trendLast6Months.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get trendLast6Months;

  /// No description provided for @weekTotal.
  ///
  /// In en, this message translates to:
  /// **'Week total: {amount}'**
  String weekTotal(String amount);

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @transactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'All transactions'**
  String get transactionsTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search merchant'**
  String get searchHint;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @noReceipts.
  ///
  /// In en, this message translates to:
  /// **'No receipts yet. Tap the scan button to add one.'**
  String get noReceipts;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches your search.'**
  String get noResults;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load data: {error}'**
  String loadFailed(String error);

  /// No description provided for @deletedItem.
  ///
  /// In en, this message translates to:
  /// **'Deleted {name}'**
  String deletedItem(String name);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @loadDemo.
  ///
  /// In en, this message translates to:
  /// **'Load demo data'**
  String get loadDemo;

  /// No description provided for @demoLoaded.
  ///
  /// In en, this message translates to:
  /// **'Loaded {count} demo receipts.'**
  String demoLoaded(int count);

  /// No description provided for @demoFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load demo data: {error}'**
  String demoFailed(String error);

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan receipt'**
  String get scanTitle;

  /// No description provided for @importImage.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importImage;

  /// No description provided for @samples.
  ///
  /// In en, this message translates to:
  /// **'Samples'**
  String get samples;

  /// No description provided for @sampleReceiptsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sample receipts'**
  String get sampleReceiptsTitle;

  /// No description provided for @sampleReceiptsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Demo data for trying the OCR and parser'**
  String get sampleReceiptsSubtitle;

  /// No description provided for @readingReceipt.
  ///
  /// In en, this message translates to:
  /// **'Reading receipt…'**
  String get readingReceipt;

  /// No description provided for @firstScanWeb.
  ///
  /// In en, this message translates to:
  /// **'The first scan downloads the OCR language data and can take a while.'**
  String get firstScanWeb;

  /// No description provided for @noTextFound.
  ///
  /// In en, this message translates to:
  /// **'No text found. Adjust the frame or try another image.'**
  String get noTextFound;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'Scan failed: {error}'**
  String scanFailed(String error);

  /// No description provided for @cameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable ({code}). Allow camera access, or import an image instead.'**
  String cameraUnavailable(String code);

  /// No description provided for @noCamera.
  ///
  /// In en, this message translates to:
  /// **'No camera found on this device.'**
  String get noCamera;

  /// No description provided for @captureFailed.
  ///
  /// In en, this message translates to:
  /// **'Capture failed ({code}).'**
  String captureFailed(String code);

  /// No description provided for @flashUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Flash unavailable ({code}).'**
  String flashUnavailable(String code);

  /// No description provided for @flashOn.
  ///
  /// In en, this message translates to:
  /// **'Flash on'**
  String get flashOn;

  /// No description provided for @flashOff.
  ///
  /// In en, this message translates to:
  /// **'Flash off'**
  String get flashOff;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review receipt'**
  String get reviewTitle;

  /// No description provided for @editTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit receipt'**
  String get editTitle;

  /// No description provided for @addTitle.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addTitle;

  /// No description provided for @fieldMerchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get fieldMerchant;

  /// No description provided for @fieldTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get fieldTotal;

  /// No description provided for @fieldDate.
  ///
  /// In en, this message translates to:
  /// **'Date & time'**
  String get fieldDate;

  /// No description provided for @fieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get fieldCategory;

  /// No description provided for @fieldReceiptNo.
  ///
  /// In en, this message translates to:
  /// **'Receipt number (optional)'**
  String get fieldReceiptNo;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get removeItem;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @enterMerchant.
  ///
  /// In en, this message translates to:
  /// **'Enter the merchant name'**
  String get enterMerchant;

  /// No description provided for @enterTotal.
  ///
  /// In en, this message translates to:
  /// **'Enter the total amount'**
  String get enterTotal;

  /// No description provided for @notDetected.
  ///
  /// In en, this message translates to:
  /// **'Not detected, please fill in'**
  String get notDetected;

  /// No description provided for @savedItem.
  ///
  /// In en, this message translates to:
  /// **'Saved {name}'**
  String savedItem(String name);

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save: {error}'**
  String saveFailed(String error);

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get catFood;

  /// No description provided for @catStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get catStudy;

  /// No description provided for @catTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get catTravel;

  /// No description provided for @catGear.
  ///
  /// In en, this message translates to:
  /// **'Gear'**
  String get catGear;

  /// No description provided for @catEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get catEntertainment;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get monthlyBudget;

  /// No description provided for @budgetNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get budgetNotSet;

  /// No description provided for @budgetDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget (VND)'**
  String get budgetDialogTitle;

  /// No description provided for @budgetClear.
  ///
  /// In en, this message translates to:
  /// **'Remove budget'**
  String get budgetClear;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @demoSection.
  ///
  /// In en, this message translates to:
  /// **'Demo'**
  String get demoSection;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Receipts are read on your device: ML Kit on mobile, Tesseract.js in the browser. Nothing is uploaded.'**
  String get aboutBody;

  /// No description provided for @billsTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily bills'**
  String get billsTitle;

  /// No description provided for @noBills.
  ///
  /// In en, this message translates to:
  /// **'No bills on this day.'**
  String get noBills;

  /// No description provided for @billsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} bills · {amount}'**
  String billsCount(int count, String amount);

  /// No description provided for @dragHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the top bill away to see the next'**
  String get dragHint;

  /// No description provided for @previousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDay;

  /// No description provided for @nextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDay;

  /// No description provided for @viewDesktop.
  ///
  /// In en, this message translates to:
  /// **'Desktop'**
  String get viewDesktop;

  /// No description provided for @viewPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get viewPhone;

  /// No description provided for @switchToPhone.
  ///
  /// In en, this message translates to:
  /// **'Switch to phone view'**
  String get switchToPhone;

  /// No description provided for @switchToDesktop.
  ///
  /// In en, this message translates to:
  /// **'Switch to desktop view'**
  String get switchToDesktop;

  /// No description provided for @switchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Switch language'**
  String get switchLanguage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

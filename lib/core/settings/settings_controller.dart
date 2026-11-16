import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User preferences that survive restarts: UI language, monthly budget (VND,
/// 0 = not set) and whether onboarding was finished.
class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs, {Locale? systemLocale})
    : _locale = _readLocale(_prefs, systemLocale),
      _budget = _prefs.getDouble(_budgetKey) ?? 0,
      _onboardingDone = _prefs.getBool(_onboardingKey) ?? false;

  static const String _localeKey = 'locale';
  static const String _budgetKey = 'monthly_budget';
  static const String _onboardingKey = 'onboarding_done';

  static const List<Locale> supportedLocales = [Locale('en'), Locale('vi')];

  final SharedPreferences _prefs;
  Locale _locale;
  double _budget;
  bool _onboardingDone;

  Locale get locale => _locale;
  double get monthlyBudget => _budget;
  bool get hasBudget => _budget > 0;
  bool get onboardingDone => _onboardingDone;

  static Locale _readLocale(SharedPreferences prefs, Locale? system) {
    final saved = prefs.getString(_localeKey);
    final code = saved ?? system?.languageCode;
    return Locale(code == 'vi' ? 'vi' : 'en');
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode == _locale.languageCode) {
      return;
    }
    _locale = Locale(locale.languageCode);
    notifyListeners();
    await _prefs.setString(_localeKey, _locale.languageCode);
  }

  Future<void> toggleLocale() =>
      setLocale(Locale(_locale.languageCode == 'vi' ? 'en' : 'vi'));

  /// A non-positive [amount] clears the budget.
  Future<void> setMonthlyBudget(double amount) async {
    _budget = amount > 0 ? amount : 0;
    notifyListeners();
    if (_budget > 0) {
      await _prefs.setDouble(_budgetKey, _budget);
    } else {
      await _prefs.remove(_budgetKey);
    }
  }

  Future<void> completeOnboarding() async {
    if (_onboardingDone) {
      return;
    }
    _onboardingDone = true;
    notifyListeners();
    await _prefs.setBool(_onboardingKey, true);
  }
}

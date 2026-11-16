import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/core/settings/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SettingsController> _make(
  Map<String, Object> initial, {
  Locale? system,
}) async {
  SharedPreferences.setMockInitialValues(initial);
  return SettingsController(
    await SharedPreferences.getInstance(),
    systemLocale: system,
  );
}

void main() {
  test(
    'defaults to the system language when Vietnamese, else English',
    () async {
      expect(
        (await _make({}, system: const Locale('vi', 'VN'))).locale.languageCode,
        'vi',
      );
      expect(
        (await _make({}, system: const Locale('fr'))).locale.languageCode,
        'en',
      );
      expect((await _make({})).locale.languageCode, 'en');
    },
  );

  test('a saved language wins over the system language', () async {
    final s = await _make({'locale': 'en'}, system: const Locale('vi'));
    expect(s.locale.languageCode, 'en');
  });

  test('toggleLocale swaps and persists', () async {
    final s = await _make({});
    var notified = 0;
    s.addListener(() => notified++);
    await s.toggleLocale();
    expect(s.locale.languageCode, 'vi');
    expect(notified, 1);
    final reloaded = SettingsController(await SharedPreferences.getInstance());
    expect(reloaded.locale.languageCode, 'vi');
  });

  test('budget is stored, and a non-positive amount clears it', () async {
    final s = await _make({});
    expect(s.hasBudget, isFalse);
    await s.setMonthlyBudget(5000000);
    expect(s.monthlyBudget, 5000000);
    expect(
      SettingsController(await SharedPreferences.getInstance()).monthlyBudget,
      5000000,
    );
    await s.setMonthlyBudget(0);
    expect(s.hasBudget, isFalse);
    expect(
      SettingsController(await SharedPreferences.getInstance()).hasBudget,
      isFalse,
    );
  });

  test('onboarding flag persists', () async {
    final s = await _make({});
    expect(s.onboardingDone, isFalse);
    await s.completeOnboarding();
    expect(
      SettingsController(await SharedPreferences.getInstance()).onboardingDone,
      isTrue,
    );
  });

  test('English and Vietnamese ARB files define the same keys', () {
    Set<String> keys(String f) =>
        (jsonDecode(File(f).readAsStringSync()) as Map<String, dynamic>).keys
            .where((k) => !k.startsWith('@'))
            .toSet();
    expect(keys('lib/l10n/app_vi.arb'), keys('lib/l10n/app_en.arb'));
  });
}

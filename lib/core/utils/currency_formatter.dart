import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  /// Longest amount the UI accepts (99,999,999,999 VND), so a slip of the
  /// finger cannot produce a figure that breaks the layout.
  static const int maxDigits = 11;

  static final NumberFormat _format = NumberFormat.decimalPattern('en_US');

  /// 150000 -> "150,000 VND"
  static String format(double amount) =>
      '${_format.format(amount.round())} VND';

  /// "150,000", "150.000 VND" -> 150000. VND has no minor unit, so every
  /// non-digit is treated as a separator. Returns null when there are no digits.
  static double? parse(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? null : double.parse(digits);
  }

  /// Short form for chart axes: 1500 -> "1.5K", 2500000 -> "2.5M".
  static String compact(double value) {
    String trim(double v) =>
        v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);
    final abs = value.abs();
    if (abs >= 1e9) {
      return '${trim(value / 1e9)}B';
    }
    if (abs >= 1e6) {
      return '${trim(value / 1e6)}M';
    }
    if (abs >= 1e3) {
      return '${trim(value / 1e3)}K';
    }
    return value.round().toString();
  }
}

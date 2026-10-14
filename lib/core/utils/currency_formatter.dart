import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

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
}

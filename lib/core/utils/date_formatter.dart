import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  /// dd/MM/yyyy, the same in both supported languages.
  static String date(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  static String dateTime(DateTime d) =>
      DateFormat('dd/MM/yyyy HH:mm').format(d);

  static String time(DateTime d) => DateFormat('HH:mm').format(d);

  /// Short weekday ("Mon" / "T2"), localized.
  static String weekday(DateTime d, String locale) =>
      DateFormat('EEE', locale).format(d);

  /// "Nov 2026" / "thg 11 2026".
  static String monthYear(DateTime d, String locale) =>
      DateFormat('MMM yyyy', locale).format(d);

  static String monthShort(DateTime d, String locale) =>
      DateFormat('MMM', locale).format(d);

  /// "Mon, 16 Nov" for list section headers.
  static String dayHeader(DateTime d, String locale) =>
      DateFormat('EEE, d MMM', locale).format(d);

  /// "Aug 18, 2026" / "18 thg 8, 2026".
  static String mediumDate(DateTime d, String locale) =>
      DateFormat.yMMMd(locale).format(d);

  static DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month);
}

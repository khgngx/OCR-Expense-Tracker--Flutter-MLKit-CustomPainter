import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _date = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTime = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _weekday = DateFormat('EEE');

  static String date(DateTime d) => _date.format(d);
  static String dateTime(DateTime d) => _dateTime.format(d);
  static String weekday(DateTime d) => _weekday.format(d);

  static DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
}

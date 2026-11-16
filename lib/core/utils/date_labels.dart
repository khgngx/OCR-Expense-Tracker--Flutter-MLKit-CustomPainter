import '../../l10n/app_localizations.dart';
import 'date_formatter.dart';

/// "Today" / "Yesterday" / "Mon, 16 Nov" for list headers and tiles.
String relativeDayLabel(
  DateTime date,
  AppLocalizations l10n,
  String locale, {
  DateTime? now,
}) {
  final today = DateFormatter.startOfDay(now ?? DateTime.now());
  final day = DateFormatter.startOfDay(date);
  final diff = today.difference(day).inDays;
  if (diff == 0) {
    return l10n.today;
  }
  if (diff == 1) {
    return l10n.yesterday;
  }
  return DateFormatter.dayHeader(day, locale);
}

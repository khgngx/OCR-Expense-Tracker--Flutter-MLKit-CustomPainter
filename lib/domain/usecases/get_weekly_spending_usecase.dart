import '../../core/utils/date_formatter.dart';
import '../../data/repositories/receipt_repository.dart';

class DaySpending {
  const DaySpending(this.day, this.total);

  final DateTime day;
  final double total;
}

class GetWeeklySpendingUsecase {
  GetWeeklySpendingUsecase(this._repository);

  final ReceiptRepository _repository;

  /// Spending per day for the 7 days ending on [endDay] (inclusive), oldest first.
  Future<List<DaySpending>> call(DateTime endDay) async {
    final end = DateFormatter.startOfDay(endDay);
    final start = DateTime(end.year, end.month, end.day - 6);
    final receipts = await _repository.getBetween(
      start,
      DateTime(end.year, end.month, end.day + 1),
    );
    return List.generate(7, (i) {
      final day = DateTime(start.year, start.month, start.day + i);
      final total = receipts
          .where((r) => DateFormatter.startOfDay(r.dateTime) == day)
          .fold<double>(0, (sum, r) => sum + r.total);
      return DaySpending(day, total);
    });
  }
}

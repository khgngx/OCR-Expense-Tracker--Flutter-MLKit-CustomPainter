import '../../core/utils/date_formatter.dart';
import '../../data/repositories/receipt_repository.dart';

class MonthSpending {
  const MonthSpending(this.month, this.total);

  final DateTime month;
  final double total;
}

class GetMonthlyTrendUsecase {
  GetMonthlyTrendUsecase(this._repository);

  final ReceiptRepository _repository;

  /// Spending per month for the [months] months ending with the month of
  /// [endDay], oldest first, zero-filled.
  Future<List<MonthSpending>> call(DateTime endDay, {int months = 6}) async {
    final last = DateFormatter.startOfMonth(endDay);
    final first = DateTime(last.year, last.month - (months - 1));
    final receipts = await _repository.getBetween(
      first,
      DateTime(last.year, last.month + 1),
    );
    return List.generate(months, (i) {
      final month = DateTime(first.year, first.month + i);
      final total = receipts
          .where(
            (r) =>
                r.dateTime.year == month.year &&
                r.dateTime.month == month.month,
          )
          .fold<double>(0, (sum, r) => sum + r.total);
      return MonthSpending(month, total);
    });
  }
}

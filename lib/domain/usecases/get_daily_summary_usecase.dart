import '../../core/utils/date_formatter.dart';
import '../../data/repositories/receipt_repository.dart';
import '../models/category.dart';
import '../models/receipt.dart';

class DailySummary {
  const DailySummary({
    required this.day,
    required this.receipts,
    required this.totalsByCategory,
  });

  final DateTime day;
  final List<Receipt> receipts;
  final Map<Category, double> totalsByCategory;

  double get total => totalsByCategory.values.fold(0, (a, b) => a + b);
}

class GetDailySummaryUsecase {
  GetDailySummaryUsecase(this._repository);

  final ReceiptRepository _repository;

  Future<DailySummary> call(DateTime day) async {
    final start = DateFormatter.startOfDay(day);
    final receipts = await _repository.getBetween(
      start,
      DateTime(start.year, start.month, start.day + 1),
    );
    return DailySummary(
      day: start,
      receipts: receipts,
      totalsByCategory: totalsByCategory(receipts),
    );
  }
}

Map<Category, double> totalsByCategory(Iterable<Receipt> receipts) {
  final totals = <Category, double>{};
  for (final r in receipts) {
    totals[r.category] = (totals[r.category] ?? 0) + r.total;
  }
  return totals;
}

import '../../core/utils/date_formatter.dart';
import '../../data/repositories/receipt_repository.dart';
import '../models/category.dart';
import '../models/receipt.dart';
import 'get_daily_summary_usecase.dart' show totalsByCategory;

class MonthSummary {
  const MonthSummary({
    required this.month,
    required this.receipts,
    required this.totalsByCategory,
    required this.previousTotal,
  });

  /// First day of the month.
  final DateTime month;
  final List<Receipt> receipts;
  final Map<Category, double> totalsByCategory;
  final double previousTotal;

  double get total => totalsByCategory.values.fold(0, (a, b) => a + b);

  /// Change versus the previous month as a fraction (0.12 = +12%), or null
  /// when there is nothing to compare against.
  double? get changeVsPrevious =>
      previousTotal > 0 ? (total - previousTotal) / previousTotal : null;
}

class GetMonthSummaryUsecase {
  GetMonthSummaryUsecase(this._repository);

  final ReceiptRepository _repository;

  Future<MonthSummary> call(DateTime anyDayInMonth) async {
    final start = DateFormatter.startOfMonth(anyDayInMonth);
    final next = DateTime(start.year, start.month + 1);
    final previous = DateTime(start.year, start.month - 1);
    final receipts = await _repository.getBetween(start, next);
    final previousReceipts = await _repository.getBetween(previous, start);
    return MonthSummary(
      month: start,
      receipts: receipts,
      totalsByCategory: totalsByCategory(receipts),
      previousTotal: previousReceipts.fold<double>(0, (s, r) => s + r.total),
    );
  }
}

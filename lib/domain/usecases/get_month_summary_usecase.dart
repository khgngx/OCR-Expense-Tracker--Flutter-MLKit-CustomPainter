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

class MerchantTotal {
  const MerchantTotal({
    required this.name,
    required this.category,
    required this.count,
    required this.total,
  });

  final String name;

  /// Category of the merchant's most recent receipt.
  final Category category;
  final int count;
  final double total;
}

/// Receipts grouped by merchant (case-insensitive, trimmed), biggest spender
/// first. Ties keep a stable order by name.
List<MerchantTotal> topMerchants(Iterable<Receipt> receipts, {int limit = 8}) {
  final groups = <String, List<Receipt>>{};
  for (final r in receipts) {
    groups.putIfAbsent(r.merchantName.trim().toLowerCase(), () => []).add(r);
  }
  MerchantTotal summarize(List<Receipt> list) {
    // The newest receipt decides how the merchant is spelled and categorized.
    final sorted = [...list]..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return MerchantTotal(
      name: sorted.first.merchantName.trim(),
      category: sorted.first.category,
      count: sorted.length,
      total: sorted.fold<double>(0, (sum, r) => sum + r.total),
    );
  }

  final result = groups.values.map(summarize).toList()
    ..sort((a, b) {
      final byTotal = b.total.compareTo(a.total);
      return byTotal != 0 ? byTotal : a.name.compareTo(b.name);
    });
  return result.take(limit).toList();
}

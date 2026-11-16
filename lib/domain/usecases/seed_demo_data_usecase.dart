import '../../data/repositories/receipt_repository.dart';
import '../models/category.dart';
import '../models/receipt.dart';
import '../models/receipt_line_item.dart';

/// Fills the app with deterministic fake receipts dated around "now" so the
/// charts, the month-over-month comparison and the bill stack have something
/// to show in a live demo. Ids are fixed,
/// so running it twice overwrites instead of duplicating.
class SeedDemoDataUsecase {
  SeedDemoDataUsecase(this._repository, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final ReceiptRepository _repository;
  final DateTime Function() _now;

  static const int _recent = 21;
  static const int _monthsBack = 5;
  static const int _perOlderMonth = 18;

  static const int count = _recent + _monthsBack * _perOlderMonth;

  static const List<
    ({String name, Category category, List<(String, double)> items})
  >
  _shops = [
    (
      name: 'Highlands Coffee',
      category: Category.food,
      items: [('Cà phê sữa đá', 29000), ('Bánh mì que', 25000)],
    ),
    (
      name: 'WinMart',
      category: Category.food,
      items: [('Sữa tươi 1L', 32000), ('Trứng gà', 38000), ('Rau cải', 15000)],
    ),
    (
      name: 'Fahasa Bookstore',
      category: Category.study,
      items: [('Sách Lập trình Dart', 189000), ('Vở kẻ ngang', 45000)],
    ),
    (name: 'Grab', category: Category.travel, items: [('Chuyến xe', 68000)]),
    (
      name: 'Phong Vũ',
      category: Category.gear,
      items: [('Chuột không dây', 250000), ('Lót chuột', 60000)],
    ),
    (
      name: 'CGV Cinema',
      category: Category.entertainment,
      items: [('Vé phim x2', 180000), ('Bắp nước', 85000)],
    ),
    (
      name: 'Saigon Kitchen',
      category: Category.food,
      items: [('Phở bò', 75000), ('Gỏi cuốn x2', 60000), ('Trà đá', 10000)],
    ),
  ];

  Future<int> call() async {
    final now = _now();
    for (var i = 0; i < count; i++) {
      await _repository.save(_build(i, now));
    }
    return count;
  }

  /// Spending level of each older month relative to a base month, so the trend
  /// chart has some shape instead of identical bars.
  static const List<double> _olderMonthFactors = [1.0, 0.8, 1.1, 0.9, 0.7];

  Receipt _build(int i, DateTime now) {
    final older = i >= _recent;
    final k = older ? (i - _recent) % _perOlderMonth : i;
    final monthsBack = older ? 1 + (i - _recent) ~/ _perOlderMonth : 0;
    final shop = _shops[k % _shops.length];
    final scale =
        (1 + (k % 4) * 0.25) *
        (older ? _olderMonthFactors[monthsBack - 1] : 1.0);
    final items = [
      for (final (name, price) in shop.items)
        ReceiptLineItem(
          name: name,
          price: (price * scale / 1000).round() * 1000,
        ),
    ];
    final DateTime when;
    if (!older) {
      // Spread over the last ~20 days, a few per day for the recent week.
      final daysAgo = i < 14 ? i ~/ 2 : i - 7;
      when = DateTime(
        now.year,
        now.month,
        now.day - daysAgo,
        8 + (i * 3) % 12,
        (i * 17) % 60,
      );
    } else {
      // Evenly across days 1..28 of the older month.
      final day = 1 + k * 27 ~/ (_perOlderMonth - 1);
      when = DateTime(now.year, now.month - monthsBack, day, 9 + k % 10);
    }
    return Receipt(
      id: 'demo-$i',
      merchantName: shop.name,
      dateTime: when,
      total: items.fold<double>(0, (sum, it) => sum + it.price),
      category: shop.category,
      lineItems: items,
      receiptNumber: 'D${1000 + i}',
      createdAt: now,
    );
  }
}

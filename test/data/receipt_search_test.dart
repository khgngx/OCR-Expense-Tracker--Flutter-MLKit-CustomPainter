import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/data/database/app_database.dart';
import 'package:ocr_expense_tracker/data/database/receipt_dao.dart';
import 'package:ocr_expense_tracker/data/repositories/receipt_repository.dart';
import 'package:ocr_expense_tracker/domain/models/category.dart';
import 'package:ocr_expense_tracker/domain/models/receipt.dart';
import 'package:ocr_expense_tracker/domain/models/receipt_filter.dart';
import 'package:ocr_expense_tracker/domain/usecases/get_month_summary_usecase.dart';
import 'package:ocr_expense_tracker/domain/usecases/get_monthly_trend_usecase.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Receipt _r(
  String id,
  String merchant,
  DateTime when,
  double total,
  Category c,
) => Receipt(
  id: id,
  merchantName: merchant,
  dateTime: when,
  total: total,
  category: c,
  createdAt: DateTime(2025),
);

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late AppDatabase db;
  late SqliteReceiptRepository repo;

  setUp(() async {
    db = await AppDatabase.open(path: inMemoryDatabasePath);
    repo = SqliteReceiptRepository(ReceiptDao(db.db));
  });

  tearDown(() => db.close());

  group('search', () {
    setUp(() async {
      await repo.save(
        _r('1', 'Highlands Coffee', DateTime(2026, 11, 3), 50, Category.food),
      );
      await repo.save(
        _r('2', 'WinMart', DateTime(2026, 11, 5), 70, Category.food),
      );
      await repo.save(
        _r('3', 'Grab', DateTime(2026, 10, 30), 20, Category.travel),
      );
      await repo.save(
        _r('4', '100% Organic_Shop', DateTime(2026, 11, 7), 10, Category.gear),
      );
    });

    test('matches merchant case-insensitively', () async {
      final r = await repo.search(const ReceiptFilter(query: 'coFFee'));
      expect(r.map((e) => e.id), ['1']);
    });

    test('combines query, category and date range', () async {
      final r = await repo.search(
        ReceiptFilter(
          category: Category.food,
          from: DateTime(2026, 11, 4),
          to: DateTime(2026, 12),
        ),
      );
      expect(r.map((e) => e.id), ['2']);
    });

    test('treats % and _ in the query literally', () async {
      expect(
        (await repo.search(const ReceiptFilter(query: '100%')))
            .map((e) => e.id),
        ['4'],
      );
      expect((await repo.search(const ReceiptFilter(query: 'o_g'))), isEmpty);
      expect(
        (await repo.search(const ReceiptFilter(query: '%'))).map((e) => e.id),
        ['4'],
      );
    });

    test('is not injectable through the query text', () async {
      final r = await repo.search(const ReceiptFilter(query: "x' OR '1'='1"));
      expect(r, isEmpty);
      expect((await repo.getAll()).length, 4);
    });

    test('empty filter returns everything newest first, paginated', () async {
      expect((await repo.search(const ReceiptFilter())).map((e) => e.id), [
        '4',
        '2',
        '1',
        '3',
      ]);
      expect(
        (await repo.search(
          const ReceiptFilter(),
          limit: 2,
          offset: 2,
        )).map((e) => e.id),
        ['1', '3'],
      );
    });
  });

  group('month usecases', () {
    test('month summary totals and change vs previous month', () async {
      await repo.save(_r('a', 'A', DateTime(2026, 11, 3), 120, Category.food));
      await repo.save(
        _r('b', 'B', DateTime(2026, 11, 30, 23), 30, Category.travel),
      );
      await repo.save(
        _r('c', 'C', DateTime(2026, 10, 31, 23), 100, Category.food),
      );
      await repo.save(_r('d', 'D', DateTime(2026, 12, 1), 999, Category.food));
      final s = await GetMonthSummaryUsecase(repo)(DateTime(2026, 11, 16));
      expect(s.total, 150);
      expect(s.previousTotal, 100);
      expect(s.changeVsPrevious, closeTo(0.5, 1e-9));
      expect(s.receipts.length, 2);
    });

    test('change is null without a previous month', () async {
      await repo.save(_r('a', 'A', DateTime(2026, 11, 3), 10, Category.food));
      final s = await GetMonthSummaryUsecase(repo)(DateTime(2026, 11));
      expect(s.changeVsPrevious, isNull);
    });

    test(
      'monthly trend is zero-filled, oldest first, across a year boundary',
      () async {
        await repo.save(_r('a', 'A', DateTime(2026, 1, 10), 40, Category.food));
        await repo.save(
          _r('b', 'B', DateTime(2025, 12, 31), 25, Category.food),
        );
        final t = await GetMonthlyTrendUsecase(repo)(
          DateTime(2026, 2, 5),
          months: 4,
        );
        expect(t.map((m) => m.month), [
          DateTime(2025, 11),
          DateTime(2025, 12),
          DateTime(2026, 1),
          DateTime(2026, 2),
        ]);
        expect(t.map((m) => m.total), [0, 25, 40, 0]);
      },
    );
  });
}

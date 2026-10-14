import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/data/database/app_database.dart';
import 'package:ocr_expense_tracker/data/database/receipt_dao.dart';
import 'package:ocr_expense_tracker/data/repositories/receipt_repository.dart';
import 'package:ocr_expense_tracker/domain/models/category.dart';
import 'package:ocr_expense_tracker/domain/models/receipt.dart';
import 'package:ocr_expense_tracker/domain/models/receipt_line_item.dart';
import 'package:ocr_expense_tracker/domain/usecases/get_daily_summary_usecase.dart';
import 'package:ocr_expense_tracker/domain/usecases/get_weekly_spending_usecase.dart';
import 'package:ocr_expense_tracker/domain/usecases/save_receipt_usecase.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Receipt _receipt(
  String id,
  DateTime when,
  double total, [
  Category c = Category.food,
]) => Receipt(
  id: id,
  merchantName: 'Shop $id',
  dateTime: when,
  total: total,
  category: c,
  createdAt: DateTime(2025, 1, 1),
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

  test('round-trips all fields including line items', () async {
    final r = _receipt('a', DateTime(2025, 3, 12, 9), 50000).copyWith(
      receiptNumber: 'N1',
      thumbnailPath: '/t.jpg',
      lineItems: const [
        ReceiptLineItem(name: 'Coffee', price: 25000, quantity: 2),
      ],
    );
    await repo.save(r);
    final got = (await repo.getById('a'))!;
    expect(got.merchantName, 'Shop a');
    expect(got.dateTime, r.dateTime);
    expect(got.receiptNumber, 'N1');
    expect(got.lineItems!.single.quantity, 2);
    expect(got.category, Category.food);
  });

  test('getAll is newest first and paginates', () async {
    await repo.save(_receipt('old', DateTime(2025, 1, 1), 1));
    await repo.save(_receipt('new', DateTime(2025, 2, 1), 1));
    expect((await repo.getAll()).map((r) => r.id), ['new', 'old']);
    expect((await repo.getAll(limit: 1, offset: 1)).single.id, 'old');
  });

  test('delete removes and emits a change', () async {
    await repo.save(_receipt('a', DateTime(2025, 1, 1), 1));
    final emitted = expectLater(repo.changes, emits(anything));
    await repo.delete('a');
    await emitted;
    expect(await repo.getById('a'), isNull);
  });

  test(
    'save usecase assigns id for new receipts and rejects negative totals',
    () async {
      final saver = SaveReceiptUsecase(repo);
      final saved = await saver(_receipt('', DateTime(2025, 1, 1), 10));
      expect(saved.id, isNotEmpty);
      expect(await repo.getById(saved.id), isNotNull);
      expect(
        () => saver(_receipt('', DateTime(2025, 1, 1), -1)),
        throwsArgumentError,
      );
    },
  );

  test('daily summary totals by category within the day only', () async {
    await repo.save(
      _receipt('a', DateTime(2025, 3, 12, 8), 100, Category.food),
    );
    await repo.save(
      _receipt('b', DateTime(2025, 3, 12, 23, 59), 50, Category.travel),
    );
    await repo.save(_receipt('c', DateTime(2025, 3, 13, 0, 0), 999));
    final s = await GetDailySummaryUsecase(repo)(DateTime(2025, 3, 12, 15));
    expect(s.total, 150);
    expect(s.totalsByCategory[Category.travel], 50);
    expect(s.receipts.length, 2);
  });

  test('weekly spending returns 7 zero-filled days oldest first', () async {
    await repo.save(_receipt('a', DateTime(2025, 3, 12, 8), 100));
    await repo.save(_receipt('b', DateTime(2025, 3, 6, 8), 70));
    final week = await GetWeeklySpendingUsecase(repo)(DateTime(2025, 3, 12));
    expect(week.length, 7);
    expect(week.first.day, DateTime(2025, 3, 6));
    expect(week.first.total, 70);
    expect(week.last.total, 100);
    expect(week[3].total, 0);
  });
}

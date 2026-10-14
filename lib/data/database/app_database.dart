import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'migrations/migrations.dart';

class AppDatabase {
  AppDatabase._(this.db);

  final Database db;

  static const String receiptsTable = 'receipts';

  /// [path] is injectable so tests can use an in-memory database.
  static Future<AppDatabase> open({String? path}) async {
    final dbPath =
        path ?? p.join(await getDatabasesPath(), 'expense_tracker.db');
    final db = await openDatabase(
      dbPath,
      version: latestSchemaVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return AppDatabase._(db);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $receiptsTable (
        id TEXT PRIMARY KEY,
        merchant_name TEXT NOT NULL,
        date_time INTEGER NOT NULL,
        total REAL NOT NULL,
        category TEXT NOT NULL,
        line_items TEXT,
        thumbnail_path TEXT,
        receipt_number TEXT,
        created_at INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_receipts_date ON $receiptsTable(date_time)',
    );
  }

  static Future<void> _onUpgrade(Database db, int from, int to) async {
    for (var v = from; v < to; v++) {
      await migrations[v - 1](db);
    }
  }

  Future<void> close() => db.close();
}

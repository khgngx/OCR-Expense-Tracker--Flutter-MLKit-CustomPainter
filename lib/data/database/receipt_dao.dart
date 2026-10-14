import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../domain/models/category.dart';
import '../../domain/models/receipt.dart';
import '../../domain/models/receipt_line_item.dart';
import 'app_database.dart';

class ReceiptDao {
  ReceiptDao(this._db);

  final Database _db;

  static const String _table = AppDatabase.receiptsTable;

  Future<void> upsert(Receipt r) => _db
      .insert(_table, _toRow(r), conflictAlgorithm: ConflictAlgorithm.replace)
      .then((_) {});

  Future<void> delete(String id) =>
      _db.delete(_table, where: 'id = ?', whereArgs: [id]).then((_) {});

  Future<Receipt?> getById(String id) async {
    final rows = await _db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  /// Newest first. [limit]/[offset] keep the list paginated.
  Future<List<Receipt>> getAll({int limit = 50, int offset = 0}) async {
    final rows = await _db.query(
      _table,
      orderBy: 'date_time DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(_fromRow).toList();
  }

  /// Receipts with `from <= dateTime < to`, newest first.
  Future<List<Receipt>> getBetween(DateTime from, DateTime to) async {
    final rows = await _db.query(
      _table,
      where: 'date_time >= ? AND date_time < ?',
      whereArgs: [from.millisecondsSinceEpoch, to.millisecondsSinceEpoch],
      orderBy: 'date_time DESC',
    );
    return rows.map(_fromRow).toList();
  }

  Map<String, Object?> _toRow(Receipt r) => {
    'id': r.id,
    'merchant_name': r.merchantName,
    'date_time': r.dateTime.millisecondsSinceEpoch,
    'total': r.total,
    'category': r.category.name,
    'line_items': r.lineItems == null
        ? null
        : jsonEncode(r.lineItems!.map((i) => i.toJson()).toList()),
    'thumbnail_path': r.thumbnailPath,
    'receipt_number': r.receiptNumber,
    'created_at': r.createdAt.millisecondsSinceEpoch,
  };

  Receipt _fromRow(Map<String, Object?> row) {
    final rawItems = row['line_items'] as String?;
    return Receipt(
      id: row['id']! as String,
      merchantName: row['merchant_name']! as String,
      dateTime: DateTime.fromMillisecondsSinceEpoch(row['date_time']! as int),
      total: (row['total']! as num).toDouble(),
      category: Category.fromName(row['category'] as String?),
      lineItems: rawItems == null
          ? null
          : (jsonDecode(rawItems) as List<dynamic>)
                .map(
                  (e) => ReceiptLineItem.fromJson(
                    Map<String, Object?>.from(e as Map),
                  ),
                )
                .toList(),
      thumbnailPath: row['thumbnail_path'] as String?,
      receiptNumber: row['receipt_number'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at']! as int),
    );
  }
}

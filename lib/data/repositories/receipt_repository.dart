import 'dart:async';

import '../../domain/models/receipt.dart';
import '../database/receipt_dao.dart';

/// The only door features use to read/write receipts. Swapping sqflite for
/// another store (or adding sync) means changing this file only.
abstract class ReceiptRepository {
  /// Emits after every write so screens can refresh.
  Stream<void> get changes;

  Future<void> save(Receipt receipt);
  Future<void> delete(String id);
  Future<Receipt?> getById(String id);
  Future<List<Receipt>> getAll({int limit, int offset});
  Future<List<Receipt>> getBetween(DateTime from, DateTime to);
}

class SqliteReceiptRepository implements ReceiptRepository {
  SqliteReceiptRepository(this._dao);

  final ReceiptDao _dao;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<void> save(Receipt receipt) async {
    await _dao.upsert(receipt);
    _changes.add(null);
  }

  @override
  Future<void> delete(String id) async {
    await _dao.delete(id);
    _changes.add(null);
  }

  @override
  Future<Receipt?> getById(String id) => _dao.getById(id);

  @override
  Future<List<Receipt>> getAll({int limit = 50, int offset = 0}) =>
      _dao.getAll(limit: limit, offset: offset);

  @override
  Future<List<Receipt>> getBetween(DateTime from, DateTime to) =>
      _dao.getBetween(from, to);
}

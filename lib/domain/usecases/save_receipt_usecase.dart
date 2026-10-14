import 'package:uuid/uuid.dart';

import '../../data/repositories/receipt_repository.dart';
import '../models/receipt.dart';

class SaveReceiptUsecase {
  SaveReceiptUsecase(this._repository, {Uuid? uuid, DateTime Function()? now})
    : _uuid = uuid ?? const Uuid(),
      _now = now ?? DateTime.now;

  final ReceiptRepository _repository;
  final Uuid _uuid;
  final DateTime Function() _now;

  /// Assigns an id and createdAt when [receipt] is new (empty id).
  Future<Receipt> call(Receipt receipt) async {
    if (receipt.total < 0) {
      throw ArgumentError.value(receipt.total, 'total', 'must not be negative');
    }
    final toSave = receipt.id.isEmpty
        ? receipt.copyWith(id: _uuid.v4(), createdAt: _now())
        : receipt;
    await _repository.save(toSave);
    return toSave;
  }
}

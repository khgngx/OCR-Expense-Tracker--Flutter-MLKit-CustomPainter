import 'dart:convert';
import 'dart:typed_data';

import 'image_storage_service.dart';

/// Keeps the thumbnail inside the receipt row as a `data:` URI. Used on web,
/// where there is no filesystem; also handy for tests.
class DataUriImageStorageService implements ImageStorageService {
  static const String _prefix = 'data:image/jpeg;base64,';

  @override
  Future<String> saveThumbnail(String receiptId, Uint8List imageBytes) async =>
      '$_prefix${base64Encode(makeThumbnailBytes(imageBytes))}';

  @override
  Future<Uint8List?> load(String? reference) async {
    if (reference == null || !reference.startsWith(_prefix)) {
      return null;
    }
    try {
      return base64Decode(reference.substring(_prefix.length));
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> delete(String? reference) async {}
}

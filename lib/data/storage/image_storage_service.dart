import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Stores receipt thumbnails. The returned reference is opaque to callers: a
/// file path on mobile, a data URI on web (no filesystem there).
abstract class ImageStorageService {
  Future<String> saveThumbnail(String receiptId, Uint8List imageBytes);

  /// Bytes behind [reference], or null when missing/unreadable.
  Future<Uint8List?> load(String? reference);

  Future<void> delete(String? reference);
}

const int thumbnailWidth = 480;

/// Downscales [imageBytes] to a JPEG no wider than [thumbnailWidth].
Uint8List makeThumbnailBytes(Uint8List imageBytes) {
  final decoded = img.decodeImage(imageBytes);
  if (decoded == null) {
    throw const FormatException('Cannot decode the image for a thumbnail.');
  }
  final resized = decoded.width > thumbnailWidth
      ? img.copyResize(decoded, width: thumbnailWidth)
      : decoded;
  return img.encodeJpg(resized, quality: 80);
}

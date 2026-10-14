import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageStorageService {
  ImageStorageService({this.baseDir});

  static const int _thumbnailWidth = 480;

  final Directory? baseDir;

  Future<Directory> _dir() async {
    final root = baseDir ?? await getApplicationDocumentsDirectory();
    return Directory(p.join(root.path, 'thumbnails')).create(recursive: true);
  }

  /// Downscales [source] to a JPEG thumbnail named after [receiptId] and
  /// returns its path.
  Future<String> saveThumbnail(String receiptId, File source) async {
    final decoded = img.decodeImage(await source.readAsBytes());
    if (decoded == null) {
      throw FormatException('Cannot decode image at ${source.path}');
    }
    final resized = decoded.width > _thumbnailWidth
        ? img.copyResize(decoded, width: _thumbnailWidth)
        : decoded;
    final file = File(p.join((await _dir()).path, '$receiptId.jpg'));
    await file.writeAsBytes(img.encodeJpg(resized, quality: 80));
    return file.path;
  }

  Future<void> delete(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}

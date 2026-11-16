import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'image_storage_service.dart';

/// Mobile/desktop implementation: thumbnails are JPEG files in app documents.
class FileImageStorageService implements ImageStorageService {
  FileImageStorageService({this.baseDir});

  final Directory? baseDir;

  Future<Directory> _dir() async {
    final root = baseDir ?? await getApplicationDocumentsDirectory();
    return Directory(p.join(root.path, 'thumbnails')).create(recursive: true);
  }

  @override
  Future<String> saveThumbnail(String receiptId, Uint8List imageBytes) async {
    final file = File(p.join((await _dir()).path, '$receiptId.jpg'));
    await file.writeAsBytes(makeThumbnailBytes(imageBytes));
    return file.path;
  }

  @override
  Future<Uint8List?> load(String? reference) async {
    if (reference == null) {
      return null;
    }
    final file = File(reference);
    return await file.exists() ? file.readAsBytes() : null;
  }

  @override
  Future<void> delete(String? reference) async {
    if (reference == null) {
      return;
    }
    final file = File(reference);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

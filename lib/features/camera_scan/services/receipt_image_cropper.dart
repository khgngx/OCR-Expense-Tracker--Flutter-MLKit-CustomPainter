import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class _CropRequest {
  const _CropRequest(
    this.sourcePath,
    this.targetPath,
    this.left,
    this.top,
    this.width,
    this.height,
  );

  final String sourcePath;
  final String targetPath;
  final double left, top, width, height;
}

/// Crops [source] to [normalizedRect] (fractions 0..1 of the upright image)
/// into [targetPath]. Runs in a background isolate.
Future<File> cropReceiptImage(
  File source,
  Rect normalizedRect,
  String targetPath,
) async {
  final path = await compute(
    _crop,
    _CropRequest(
      source.path,
      targetPath,
      normalizedRect.left,
      normalizedRect.top,
      normalizedRect.width,
      normalizedRect.height,
    ),
  );
  return File(path);
}

String _crop(_CropRequest r) {
  final decoded = img.decodeImage(File(r.sourcePath).readAsBytesSync());
  if (decoded == null) {
    throw FormatException('Cannot decode image at ${r.sourcePath}');
  }
  final upright = img.bakeOrientation(decoded);
  final x = (r.left * upright.width).round().clamp(0, upright.width - 1);
  final y = (r.top * upright.height).round().clamp(0, upright.height - 1);
  final w = (r.width * upright.width).round().clamp(1, upright.width - x);
  final h = (r.height * upright.height).round().clamp(1, upright.height - y);
  File(r.targetPath).writeAsBytesSync(
    img.encodeJpg(
      img.copyCrop(upright, x: x, y: y, width: w, height: h),
      quality: 92,
    ),
  );
  return r.targetPath;
}

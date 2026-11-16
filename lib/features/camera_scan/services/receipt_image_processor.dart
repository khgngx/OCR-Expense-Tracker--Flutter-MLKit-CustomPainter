import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class _PrepareRequest {
  const _PrepareRequest(
    this.bytes,
    this.left,
    this.top,
    this.width,
    this.height,
    this.maxSide,
  );

  final Uint8List bytes;
  final double left, top, width, height;
  final int maxSide;
}

/// Normalizes a captured/imported image for OCR: applies EXIF rotation, crops to
/// [cropRect] (fractions 0..1 of the upright image; whole image when null) and
/// caps the longest side at [maxSide] px so OCR stays fast. Returns JPEG bytes.
/// Works on bytes only, so it runs on mobile and web alike.
Future<Uint8List> prepareReceiptImage(
  Uint8List bytes, {
  Rect? cropRect,
  int maxSide = 1600,
}) {
  final r = cropRect ?? const Rect.fromLTWH(0, 0, 1, 1);
  return compute(
    _prepare,
    _PrepareRequest(bytes, r.left, r.top, r.width, r.height, maxSide),
  );
}

Uint8List _prepare(_PrepareRequest r) {
  final decoded = img.decodeImage(r.bytes);
  if (decoded == null) {
    throw const FormatException(
      'Cannot decode the image; unsupported or corrupt file.',
    );
  }
  final upright = img.bakeOrientation(decoded);
  final x = (r.left * upright.width).round().clamp(0, upright.width - 1);
  final y = (r.top * upright.height).round().clamp(0, upright.height - 1);
  final w = (r.width * upright.width).round().clamp(1, upright.width - x);
  final h = (r.height * upright.height).round().clamp(1, upright.height - y);
  var out = img.copyCrop(upright, x: x, y: y, width: w, height: h);
  final longest = out.width > out.height ? out.width : out.height;
  if (longest > r.maxSide) {
    out = out.width >= out.height
        ? img.copyResize(out, width: r.maxSide)
        : img.copyResize(out, height: r.maxSide);
  }
  return img.encodeJpg(out, quality: 92);
}

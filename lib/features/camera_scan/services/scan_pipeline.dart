import 'dart:typed_data';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';

import '../../../app_scope.dart';
import '../../../domain/models/parsed_receipt.dart';
import 'receipt_image_processor.dart';

class ScanResult {
  const ScanResult({required this.image, required this.parsed});

  /// The normalized (rotated, cropped, downscaled) JPEG that was read.
  final Uint8List image;
  final ParsedReceipt parsed;
}

/// Lets the user pick a receipt photo from the device; null if cancelled.
Future<Uint8List?> pickReceiptImage() async {
  final file = await FilePicker.pickFile(type: FileType.image);
  return file?.readAsBytes();
}

/// Normalizes [raw], runs OCR and parses the text. Returns null when OCR found
/// no text at all, so callers can tell "nothing readable" from a failure.
Future<ScanResult?> scanReceipt(
  AppDependencies deps,
  Uint8List raw, {
  Rect? crop,
}) async {
  final prepared = await prepareReceiptImage(raw, cropRect: crop);
  final text = await deps.ocrService.recognize(prepared);
  if (text.trim().isEmpty) {
    return null;
  }
  return ScanResult(image: prepared, parsed: deps.parseReceiptText(text));
}

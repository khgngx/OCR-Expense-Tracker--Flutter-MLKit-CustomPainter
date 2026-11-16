import 'dart:typed_data';

abstract class OcrService {
  /// Raw recognized text of the JPEG/PNG [imageBytes]; empty when nothing is found.
  Future<String> recognize(Uint8List imageBytes);

  Future<void> dispose();
}

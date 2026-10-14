import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

abstract class OcrService {
  /// Returns the raw recognized text of [image]; empty when nothing is found.
  Future<String> recognize(File image);
  Future<void> dispose();
}

/// On-device ML Kit recognizer (Latin script covers Vietnamese). No network.
class MlKitOcrService implements OcrService {
  final TextRecognizer _recognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  @override
  Future<String> recognize(File image) async {
    final result = await _recognizer.processImage(InputImage.fromFile(image));
    return result.text;
  }

  @override
  Future<void> dispose() => _recognizer.close();
}

import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'ocr_service.dart';

/// On-device ML Kit recognizer (Latin script covers Vietnamese). No network.
/// Mobile only: ML Kit has no web build.
class MlKitOcrService implements OcrService {
  final TextRecognizer _recognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  @override
  Future<String> recognize(Uint8List imageBytes) async {
    // ML Kit reads from a file path, so spool the bytes to a temp file.
    final dir = await getTemporaryDirectory();
    final file = File(
      p.join(dir.path, 'ocr_${DateTime.now().microsecondsSinceEpoch}.jpg'),
    );
    await file.writeAsBytes(imageBytes, flush: true);
    try {
      final result = await _recognizer.processImage(InputImage.fromFile(file));
      return result.text;
    } finally {
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  @override
  Future<void> dispose() => _recognizer.close();
}

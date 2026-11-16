import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'ocr_service.dart';

extension type _OcrData(JSObject _) implements JSObject {
  external JSString get text;
}

extension type _OcrResult(JSObject _) implements JSObject {
  external _OcrData get data;
}

@JS('Tesseract.recognize')
external JSPromise<_OcrResult> _recognize(JSString image, JSString languages);

/// Web OCR using Tesseract.js (WebAssembly) loaded by web/index.html. The image
/// never leaves the browser; only the library and language data are fetched
/// from a CDN on first use.
class TesseractOcrService implements OcrService {
  static const String _languages = 'vie+eng';

  @override
  Future<String> recognize(Uint8List imageBytes) async {
    if (!globalContext.has('Tesseract')) {
      throw StateError(
        'Tesseract.js is not loaded. Check your connection and reload the page.',
      );
    }
    final dataUrl = 'data:image/jpeg;base64,${base64Encode(imageBytes)}';
    final result = await _recognize(dataUrl.toJS, _languages.toJS).toDart;
    return result.data.text.toDart;
  }

  @override
  Future<void> dispose() async {}
}

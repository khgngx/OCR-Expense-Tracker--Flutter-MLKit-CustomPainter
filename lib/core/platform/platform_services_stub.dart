import '../../data/storage/image_storage_service.dart';
import '../../features/camera_scan/services/ocr_service.dart';

Never _unsupported() => throw UnsupportedError('Unsupported platform');

Future<void> initPlatform() async => _unsupported();
OcrService createOcrService() => _unsupported();
ImageStorageService createImageStorage() => _unsupported();

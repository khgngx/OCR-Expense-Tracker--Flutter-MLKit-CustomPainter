import '../../data/storage/file_image_storage_service.dart';
import '../../data/storage/image_storage_service.dart';
import '../../features/camera_scan/services/ml_kit_ocr_service.dart';
import '../../features/camera_scan/services/ocr_service.dart';

Future<void> initPlatform() async {}

OcrService createOcrService() => MlKitOcrService();

ImageStorageService createImageStorage() => FileImageStorageService();

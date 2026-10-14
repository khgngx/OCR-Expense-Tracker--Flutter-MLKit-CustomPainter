import 'package:flutter/material.dart';

import 'app.dart';
import 'app_scope.dart';
import 'data/database/app_database.dart';
import 'data/database/receipt_dao.dart';
import 'data/repositories/receipt_repository.dart';
import 'data/storage/image_storage_service.dart';
import 'features/camera_scan/services/ml_kit_ocr_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await AppDatabase.open();
  runApp(
    App(
      dependencies: AppDependencies(
        receiptRepository: SqliteReceiptRepository(ReceiptDao(database.db)),
        imageStorage: ImageStorageService(),
        ocrService: MlKitOcrService(),
      ),
    ),
  );
}

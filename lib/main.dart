import 'package:flutter/material.dart';

import 'app.dart';
import 'app_scope.dart';
import 'core/platform/platform_services.dart';
import 'data/database/app_database.dart';
import 'data/database/receipt_dao.dart';
import 'data/repositories/receipt_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPlatform();
  final database = await AppDatabase.open();
  runApp(
    App(
      dependencies: AppDependencies(
        receiptRepository: SqliteReceiptRepository(ReceiptDao(database.db)),
        imageStorage: createImageStorage(),
        ocrService: createOcrService(),
      ),
    ),
  );
}

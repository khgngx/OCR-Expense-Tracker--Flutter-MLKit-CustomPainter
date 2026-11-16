import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'app_scope.dart';
import 'core/platform/platform_services.dart';
import 'core/settings/settings_controller.dart';
import 'data/database/app_database.dart';
import 'data/database/receipt_dao.dart';
import 'data/repositories/receipt_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPlatform();
  final database = await AppDatabase.open();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    App(
      dependencies: AppDependencies(
        receiptRepository: SqliteReceiptRepository(ReceiptDao(database.db)),
        imageStorage: createImageStorage(),
        ocrService: createOcrService(),
        settings: SettingsController(
          prefs,
          systemLocale: PlatformDispatcher.instance.locale,
        ),
      ),
    ),
  );
}

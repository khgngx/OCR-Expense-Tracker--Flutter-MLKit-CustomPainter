import 'package:flutter/widgets.dart';

import 'data/repositories/receipt_repository.dart';
import 'data/storage/image_storage_service.dart';
import 'domain/usecases/get_daily_summary_usecase.dart';
import 'domain/usecases/get_weekly_spending_usecase.dart';
import 'domain/usecases/parse_receipt_text_usecase.dart';
import 'domain/usecases/save_receipt_usecase.dart';
import 'features/camera_scan/services/ml_kit_ocr_service.dart';

/// Hand-wired dependencies; features read them through [AppScope].
class AppDependencies {
  AppDependencies({
    required this.receiptRepository,
    required this.imageStorage,
    required this.ocrService,
  }) : saveReceipt = SaveReceiptUsecase(receiptRepository),
       getDailySummary = GetDailySummaryUsecase(receiptRepository),
       getWeeklySpending = GetWeeklySpendingUsecase(receiptRepository);

  final ReceiptRepository receiptRepository;
  final ImageStorageService imageStorage;
  final OcrService ocrService;
  final ParseReceiptTextUsecase parseReceiptText =
      const ParseReceiptTextUsecase();
  final SaveReceiptUsecase saveReceipt;
  final GetDailySummaryUsecase getDailySummary;
  final GetWeeklySpendingUsecase getWeeklySpending;
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.dependencies, required super.child});

  final AppDependencies dependencies;

  static AppDependencies of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope missing above this context');
    return scope!.dependencies;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      dependencies != oldWidget.dependencies;
}

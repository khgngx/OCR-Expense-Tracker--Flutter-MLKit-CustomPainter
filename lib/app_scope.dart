import 'package:flutter/widgets.dart';

import 'data/repositories/receipt_repository.dart';
import 'data/storage/image_storage_service.dart';
import 'core/settings/settings_controller.dart';
import 'domain/usecases/get_daily_summary_usecase.dart';
import 'domain/usecases/get_month_summary_usecase.dart';
import 'domain/usecases/get_monthly_trend_usecase.dart';
import 'domain/usecases/get_weekly_spending_usecase.dart';
import 'domain/usecases/parse_receipt_text_usecase.dart';
import 'domain/usecases/save_receipt_usecase.dart';
import 'domain/usecases/seed_demo_data_usecase.dart';
import 'features/camera_scan/services/ocr_service.dart';

/// Hand-wired dependencies; features read them through [AppScope].
class AppDependencies {
  AppDependencies({
    required this.receiptRepository,
    required this.imageStorage,
    required this.ocrService,
    required this.settings,
  }) : saveReceipt = SaveReceiptUsecase(receiptRepository),
       getDailySummary = GetDailySummaryUsecase(receiptRepository),
       getWeeklySpending = GetWeeklySpendingUsecase(receiptRepository),
       getMonthSummary = GetMonthSummaryUsecase(receiptRepository),
       getMonthlyTrend = GetMonthlyTrendUsecase(receiptRepository),
       seedDemoData = SeedDemoDataUsecase(receiptRepository);

  final ReceiptRepository receiptRepository;
  final ImageStorageService imageStorage;
  final OcrService ocrService;
  final SettingsController settings;
  final ParseReceiptTextUsecase parseReceiptText =
      const ParseReceiptTextUsecase();
  final SaveReceiptUsecase saveReceipt;
  final GetDailySummaryUsecase getDailySummary;
  final GetWeeklySpendingUsecase getWeeklySpending;
  final GetMonthSummaryUsecase getMonthSummary;
  final GetMonthlyTrendUsecase getMonthlyTrend;
  final SeedDemoDataUsecase seedDemoData;
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

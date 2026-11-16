// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Quản lý chi tiêu';

  @override
  String get onboardingBody1 =>
      'Quét, lưu và theo dõi mọi khoản chi — tất cả trong một nơi đơn giản.';

  @override
  String get onboardingBody2 =>
      'Danh mục và biểu đồ giúp bạn nắm chi tiêu trong một cái nhìn.';

  @override
  String get onboardingBody3 => 'Đặt ngân sách tháng và theo dõi mỗi ngày.';

  @override
  String get skip => 'Bỏ qua';

  @override
  String get next => 'Tiếp';

  @override
  String get getStarted => 'Bắt đầu';

  @override
  String get greetingMorning => 'Chào buổi sáng';

  @override
  String get greetingAfternoon => 'Chào buổi chiều';

  @override
  String get greetingEvening => 'Chào buổi tối';

  @override
  String get greetingSub => 'Cùng giữ chi tiêu trong tầm kiểm soát';

  @override
  String get spentThisMonth => 'Đã chi tháng này';

  @override
  String moreThanLastMonth(int percent) {
    return 'Nhiều hơn tháng trước $percent%';
  }

  @override
  String lessThanLastMonth(int percent) {
    return 'Ít hơn tháng trước $percent%';
  }

  @override
  String get sameAsLastMonth => 'Bằng tháng trước';

  @override
  String get noLastMonthData => 'Chưa có dữ liệu tháng trước';

  @override
  String get quickScan => 'Quét';

  @override
  String get quickImport => 'Nhập ảnh';

  @override
  String get quickAdd => 'Thêm tay';

  @override
  String get quickDemo => 'Dữ liệu mẫu';

  @override
  String get recentTransactions => 'Giao dịch gần đây';

  @override
  String get seeAll => 'Xem tất cả';

  @override
  String get today => 'Hôm nay';

  @override
  String get yesterday => 'Hôm qua';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navAnalytics => 'Phân tích';

  @override
  String get navBills => 'Hóa đơn';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get navScan => 'Quét hóa đơn';

  @override
  String get analyticsTitle => 'Phân tích';

  @override
  String get tabSpending => 'Chi tiêu';

  @override
  String get tabTrends => 'Xu hướng';

  @override
  String get yourSpending => 'Chi tiêu của bạn';

  @override
  String get totalSpent => 'Tổng chi';

  @override
  String get noSpending => 'Tháng này chưa có chi tiêu.';

  @override
  String budgetUnder(int percent) {
    return 'Bạn đang dưới ngân sách $percent%!';
  }

  @override
  String budgetOver(int percent) {
    return 'Bạn đã vượt ngân sách $percent%';
  }

  @override
  String get budgetUnderHint => 'Bạn quản lý chi tiêu rất tốt tháng này.';

  @override
  String get budgetOverHint =>
      'Hãy chi tiêu chậm lại trong phần còn lại của tháng.';

  @override
  String budgetLeft(String amount, String budget) {
    return 'Còn $amount trên $budget';
  }

  @override
  String get budgetSetTitle => 'Đặt ngân sách tháng';

  @override
  String get budgetSetHint => 'Theo dõi số tiền bạn còn có thể chi.';

  @override
  String get trendLast7 => '7 ngày qua';

  @override
  String get trendLast6Months => '6 tháng qua';

  @override
  String weekTotal(String amount) {
    return 'Tổng tuần: $amount';
  }

  @override
  String get previousMonth => 'Tháng trước';

  @override
  String get nextMonth => 'Tháng sau';

  @override
  String get transactionsTitle => 'Tất cả giao dịch';

  @override
  String get searchHint => 'Tìm cửa hàng';

  @override
  String get filterAll => 'Tất cả';

  @override
  String get noReceipts => 'Chưa có hóa đơn. Bấm nút quét để thêm.';

  @override
  String get noResults => 'Không có kết quả phù hợp.';

  @override
  String loadFailed(String error) {
    return 'Không tải được dữ liệu: $error';
  }

  @override
  String deletedItem(String name) {
    return 'Đã xoá $name';
  }

  @override
  String get undo => 'Hoàn tác';

  @override
  String get loadDemo => 'Tải dữ liệu mẫu';

  @override
  String demoLoaded(int count) {
    return 'Đã tải $count hóa đơn mẫu.';
  }

  @override
  String demoFailed(String error) {
    return 'Không tải được dữ liệu mẫu: $error';
  }

  @override
  String get scanTitle => 'Quét hóa đơn';

  @override
  String get importImage => 'Nhập ảnh';

  @override
  String get samples => 'Mẫu';

  @override
  String get sampleReceiptsTitle => 'Hóa đơn mẫu';

  @override
  String get sampleReceiptsSubtitle => 'Dữ liệu mẫu để thử OCR và bộ phân tích';

  @override
  String get readingReceipt => 'Đang đọc hóa đơn…';

  @override
  String get firstScanWeb =>
      'Lần quét đầu sẽ tải dữ liệu ngôn ngữ OCR nên có thể hơi lâu.';

  @override
  String get noTextFound =>
      'Không tìm thấy chữ. Hãy chỉnh khung hoặc thử ảnh khác.';

  @override
  String scanFailed(String error) {
    return 'Quét thất bại: $error';
  }

  @override
  String cameraUnavailable(String code) {
    return 'Không dùng được camera ($code). Hãy cho phép truy cập camera hoặc nhập ảnh.';
  }

  @override
  String get noCamera => 'Thiết bị không có camera.';

  @override
  String captureFailed(String code) {
    return 'Chụp thất bại ($code).';
  }

  @override
  String flashUnavailable(String code) {
    return 'Không bật được đèn flash ($code).';
  }

  @override
  String get flashOn => 'Đèn flash bật';

  @override
  String get flashOff => 'Đèn flash tắt';

  @override
  String get reviewTitle => 'Kiểm tra hóa đơn';

  @override
  String get editTitle => 'Sửa hóa đơn';

  @override
  String get addTitle => 'Thêm chi tiêu';

  @override
  String get fieldMerchant => 'Cửa hàng';

  @override
  String get fieldTotal => 'Tổng tiền';

  @override
  String get fieldDate => 'Ngày giờ';

  @override
  String get fieldCategory => 'Danh mục';

  @override
  String get fieldReceiptNo => 'Số hóa đơn (không bắt buộc)';

  @override
  String get items => 'Các món';

  @override
  String get removeItem => 'Xoá món';

  @override
  String get save => 'Lưu';

  @override
  String get enterMerchant => 'Nhập tên cửa hàng';

  @override
  String get enterTotal => 'Nhập tổng tiền';

  @override
  String get notDetected => 'Chưa nhận diện được, hãy nhập';

  @override
  String savedItem(String name) {
    return 'Đã lưu $name';
  }

  @override
  String saveFailed(String error) {
    return 'Không lưu được: $error';
  }

  @override
  String get catFood => 'Ăn uống';

  @override
  String get catStudy => 'Học tập';

  @override
  String get catTravel => 'Di chuyển';

  @override
  String get catGear => 'Thiết bị';

  @override
  String get catEntertainment => 'Giải trí';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get monthlyBudget => 'Ngân sách tháng';

  @override
  String get budgetNotSet => 'Chưa đặt';

  @override
  String get budgetDialogTitle => 'Ngân sách tháng (VND)';

  @override
  String get budgetClear => 'Bỏ ngân sách';

  @override
  String get cancel => 'Huỷ';

  @override
  String get demoSection => 'Dùng thử';

  @override
  String get aboutSection => 'Giới thiệu';

  @override
  String get aboutBody =>
      'Hóa đơn được đọc ngay trên thiết bị: ML Kit trên điện thoại, Tesseract.js trên trình duyệt. Không có dữ liệu nào bị tải lên.';

  @override
  String get billsTitle => 'Hóa đơn theo ngày';

  @override
  String get noBills => 'Không có hóa đơn trong ngày.';

  @override
  String billsCount(int count, String amount) {
    return '$count hóa đơn · $amount';
  }

  @override
  String get dragHint => 'Kéo hóa đơn trên cùng đi để xem tờ tiếp theo';

  @override
  String get previousDay => 'Ngày trước';

  @override
  String get nextDay => 'Ngày sau';

  @override
  String get viewDesktop => 'Máy tính';

  @override
  String get viewPhone => 'Điện thoại';

  @override
  String get switchToPhone => 'Chuyển sang giao diện điện thoại';

  @override
  String get switchToDesktop => 'Chuyển sang giao diện máy tính';

  @override
  String get switchLanguage => 'Đổi ngôn ngữ';

  @override
  String get onboardingTitle1a => 'Hóa đơn của bạn';

  @override
  String get onboardingTitle1b => 'Gọn gàng hơn';

  @override
  String get onboardingTitle2a => 'Biết tiền';

  @override
  String get onboardingTitle2b => 'đi đâu';

  @override
  String get onboardingTitle3a => 'Chi tiêu trong';

  @override
  String get onboardingTitle3b => 'ngân sách';

  @override
  String get navProfile => 'Hồ sơ';

  @override
  String get profileTitle => 'Hồ sơ';

  @override
  String get totalSpentLabel => 'Tổng chi';

  @override
  String get vsLastMonth => 'so với tháng trước';

  @override
  String get hideAmount => 'Ẩn số tiền';

  @override
  String get showAmount => 'Hiện số tiền';

  @override
  String get quickMore => 'Thêm';

  @override
  String get moreTitle => 'Thêm';

  @override
  String get tabBudget => 'Ngân sách';

  @override
  String get tabMerchants => 'Cửa hàng';

  @override
  String get spendingTrend => 'Xu hướng chi tiêu';

  @override
  String get selectMonth => 'Chọn tháng';

  @override
  String get back => 'Quay lại';

  @override
  String get alertsTitle => 'Thông báo';

  @override
  String get alertsEmpty => 'Bạn đã xem hết thông báo.';

  @override
  String alertBudgetUsed(int percent) {
    return 'Bạn đã dùng $percent% ngân sách tháng';
  }

  @override
  String get alertNoBudget => 'Đặt ngân sách tháng để nhận cảnh báo chi tiêu';

  @override
  String alertTopCategory(String category) {
    return '$category là khoản chi lớn nhất tháng này';
  }

  @override
  String get alertNoSpending => 'Tháng này chưa có chi tiêu';

  @override
  String budgetTabSpent(String amount, String budget) {
    return 'Đã chi $amount trên $budget';
  }

  @override
  String budgetTabPerDay(String amount, int days) {
    return 'Bạn có thể chi khoảng $amount mỗi ngày trong $days ngày còn lại.';
  }

  @override
  String get budgetTabOver => 'Bạn đã vượt ngân sách tháng này.';

  @override
  String get budgetTabEdit => 'Sửa ngân sách';

  @override
  String get topMerchants => 'Cửa hàng chi nhiều nhất';

  @override
  String receiptCount(int count) {
    return '$count hóa đơn';
  }

  @override
  String get noMerchants => 'Tháng này chưa có cửa hàng nào.';
}

import '../../../domain/models/receipt.dart';

/// One day's receipts, shown as a stack of paper bills.
class DailyBillRoll {
  const DailyBillRoll({required this.day, required this.receipts});

  final DateTime day;
  final List<Receipt> receipts;

  double get total => receipts.fold(0, (sum, r) => sum + r.total);
}

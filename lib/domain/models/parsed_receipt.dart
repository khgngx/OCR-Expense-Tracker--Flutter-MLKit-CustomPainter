import 'category.dart';
import 'receipt_line_item.dart';

/// Best-effort result of parsing OCR text. Every field may be missing; the
/// review screen lets the user fill the gaps before saving.
class ParsedReceipt {
  const ParsedReceipt({
    this.merchantName,
    this.dateTime,
    this.total,
    this.receiptNumber,
    this.category = Category.food,
    this.lineItems = const [],
  });

  final String? merchantName;
  final DateTime? dateTime;
  final double? total;
  final String? receiptNumber;
  final Category category;
  final List<ReceiptLineItem> lineItems;
}

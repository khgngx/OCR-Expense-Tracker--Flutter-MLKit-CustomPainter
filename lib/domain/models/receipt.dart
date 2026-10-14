import 'category.dart';
import 'receipt_line_item.dart';

class Receipt {
  const Receipt({
    required this.id,
    required this.merchantName,
    required this.dateTime,
    required this.total,
    required this.category,
    required this.createdAt,
    this.lineItems,
    this.thumbnailPath,
    this.receiptNumber,
  });

  final String id;
  final String merchantName;
  final DateTime dateTime;
  final double total;
  final Category category;
  final List<ReceiptLineItem>? lineItems;
  final String? thumbnailPath;
  final String? receiptNumber;
  final DateTime createdAt;

  Receipt copyWith({
    String? id,
    String? merchantName,
    DateTime? dateTime,
    double? total,
    Category? category,
    List<ReceiptLineItem>? lineItems,
    String? thumbnailPath,
    String? receiptNumber,
    DateTime? createdAt,
  }) => Receipt(
    id: id ?? this.id,
    merchantName: merchantName ?? this.merchantName,
    dateTime: dateTime ?? this.dateTime,
    total: total ?? this.total,
    category: category ?? this.category,
    lineItems: lineItems ?? this.lineItems,
    thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    receiptNumber: receiptNumber ?? this.receiptNumber,
    createdAt: createdAt ?? this.createdAt,
  );
}

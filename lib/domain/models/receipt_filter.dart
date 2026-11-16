import 'category.dart';

/// Criteria for listing receipts. Null fields are not applied.
class ReceiptFilter {
  const ReceiptFilter({this.query, this.category, this.from, this.to});

  /// Case-insensitive substring of the merchant name.
  final String? query;
  final Category? category;

  /// Inclusive lower and exclusive upper bound on the receipt date.
  final DateTime? from;
  final DateTime? to;

  bool get isEmpty =>
      (query == null || query!.trim().isEmpty) &&
      category == null &&
      from == null &&
      to == null;

  ReceiptFilter copyWith({
    String? query,
    Category? category,
    bool clearCategory = false,
    DateTime? from,
    DateTime? to,
  }) => ReceiptFilter(
    query: query ?? this.query,
    category: clearCategory ? null : (category ?? this.category),
    from: from ?? this.from,
    to: to ?? this.to,
  );
}

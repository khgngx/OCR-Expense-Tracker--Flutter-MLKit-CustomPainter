class ReceiptLineItem {
  const ReceiptLineItem({
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  final String name;
  final double price;
  final int quantity;

  Map<String, Object?> toJson() => {
    'name': name,
    'price': price,
    'quantity': quantity,
  };

  factory ReceiptLineItem.fromJson(Map<String, Object?> json) =>
      ReceiptLineItem(
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      );
}

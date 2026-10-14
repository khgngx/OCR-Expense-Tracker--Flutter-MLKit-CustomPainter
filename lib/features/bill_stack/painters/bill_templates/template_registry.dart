import 'bill_template.dart';
import 'cafe_receipt_template.dart';
import 'restaurant_template.dart';
import 'supermarket_template.dart';

class TemplateRegistry {
  TemplateRegistry._();

  static const List<BillTemplate> templates = [
    SupermarketTemplate(),
    CafeReceiptTemplate(),
    RestaurantTemplate(),
  ];

  /// Pseudo-random but stable: the same [seed] (a receipt id) always gets the
  /// same look, so a bill doesn't change style on rebuild or restart.
  /// Uses FNV-1a because String.hashCode is not guaranteed stable across runs.
  static BillTemplate pick(String seed) {
    var hash = 0x811c9dc5;
    for (final unit in seed.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0xFFFFFFFF;
    }
    return templates[hash % templates.length];
  }
}

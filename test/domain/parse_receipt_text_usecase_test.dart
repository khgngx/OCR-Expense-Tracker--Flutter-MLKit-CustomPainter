import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/core/utils/currency_formatter.dart';
import 'package:ocr_expense_tracker/domain/models/category.dart';
import 'package:ocr_expense_tracker/domain/usecases/parse_receipt_text_usecase.dart';

void main() {
  const parser = ParseReceiptTextUsecase();

  group('ParseReceiptTextUsecase', () {
    test('parses a typical Vietnamese cafe receipt', () {
      const text = '''
HIGHLANDS COFFEE
123 Nguyen Hue, Q1
Số HĐ: 00012345
Ngày: 12/03/2025 14:35
Cà phê sữa đá  2 x 29.000  58.000
Bánh mì  1  25.000
Tạm tính 83.000
VAT 8% 6.640
Tổng cộng 89.640
''';
      final r = parser(text);
      expect(r.merchantName, 'HIGHLANDS COFFEE');
      expect(r.dateTime, DateTime(2025, 3, 12, 14, 35));
      expect(r.total, 89640);
      expect(r.receiptNumber, '00012345');
      expect(r.category, Category.food);
      expect(r.lineItems.map((i) => i.name), contains('Cà phê sữa đá'));
    });

    test(
      'takes the total from the next line when the keyword line has no amount',
      () {
        final r = parser('Shop\nTOTAL\n150,000');
        expect(r.total, 150000);
      },
    );

    test('falls back to the largest amount without a total keyword', () {
      final r = parser('Shop\nItem 20,000\nItem 35,000');
      expect(r.total, 35000);
    });

    test('rejects impossible dates', () {
      expect(parser('Shop\n45/13/2025').dateTime, isNull);
    });

    test('parses ISO dates', () {
      expect(
        parser('Shop\n2025-03-12 08:05').dateTime,
        DateTime(2025, 3, 12, 8, 5),
      );
    });

    test('empty input yields an empty result', () {
      final r = parser('   \n ');
      expect(r.merchantName, isNull);
      expect(r.total, isNull);
    });
  });

  group('CurrencyFormatter', () {
    test('parse strips separators and unit', () {
      expect(CurrencyFormatter.parse('150.000 VND'), 150000);
      expect(CurrencyFormatter.parse('1,234,567'), 1234567);
      expect(CurrencyFormatter.parse('abc'), isNull);
    });

    test('format groups thousands', () {
      expect(CurrencyFormatter.format(150000), '150,000 VND');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ocr_expense_tracker/core/utils/currency_formatter.dart';
import 'package:ocr_expense_tracker/domain/models/category.dart';
import 'package:ocr_expense_tracker/domain/models/receipt.dart';
import 'package:ocr_expense_tracker/domain/usecases/get_month_summary_usecase.dart';
import 'package:ocr_expense_tracker/features/charts/painters/pie_chart_painter.dart';
import 'package:ocr_expense_tracker/features/charts/widgets/interactive_bar_chart.dart';

import 'dart:ui' as ui;

Receipt _r(String merchant, double total, DateTime when, Category c) => Receipt(
  id: '$merchant$when',
  merchantName: merchant,
  dateTime: when,
  total: total,
  category: c,
  createdAt: DateTime(2026),
);

void main() {
  group('topMerchants', () {
    test(
      'groups case-insensitively, sorts by total, keeps latest category',
      () {
        final list = topMerchants([
          _r('Grab', 50, DateTime(2026, 11, 1), Category.travel),
          _r(' grab ', 30, DateTime(2026, 11, 9), Category.gear),
          _r('WinMart', 100, DateTime(2026, 11, 3), Category.food),
          _r('Cafe', 100, DateTime(2026, 11, 4), Category.food),
        ]);
        expect(list.map((m) => m.name), ['Cafe', 'WinMart', 'grab']);
        final grab = list.last;
        expect(grab.count, 2);
        expect(grab.total, 80);
        expect(
          grab.category,
          Category.gear,
          reason: 'category of the latest receipt',
        );
      },
    );

    test('respects the limit and handles empty input', () {
      expect(topMerchants(const []), isEmpty);
      final many = [
        for (var i = 0; i < 20; i++)
          _r('M$i', i + 1.0, DateTime(2026, 11, 1), Category.food),
      ];
      expect(topMerchants(many, limit: 5).length, 5);
    });
  });

  group('niceAxisMax', () {
    test(
      'rounds up to 3 equal steps of 1, 2, 2.5 or 5 times a power of ten',
      () {
        expect(
          niceAxisMax(754),
          1500,
          reason: 'matches the reference: 754 -> 0..1.5K',
        );
        expect(niceAxisMax(1400), 1500);
        expect(niceAxisMax(1500), 1500);
        expect(niceAxisMax(1501), 3000);
        expect(niceAxisMax(0), 3);
        expect(niceAxisMax(-5), 3);
      },
    );

    test('always covers the maximum', () {
      for (final v in [1.0, 7.0, 99.0, 12345.0, 4679000.0, 8.667e6, 1e10]) {
        expect(niceAxisMax(v), greaterThanOrEqualTo(v), reason: '$v');
      }
    });
  });

  test('CurrencyFormatter.compact', () {
    expect(CurrencyFormatter.compact(0), '0');
    expect(CurrencyFormatter.compact(500), '500');
    expect(CurrencyFormatter.compact(1500), '1.5K');
    expect(CurrencyFormatter.compact(1000), '1K');
    expect(CurrencyFormatter.compact(2500000), '2.5M');
    expect(CurrencyFormatter.compact(3e9), '3B');
  });

  test('rounded-cap donut paints single, many and tiny slices', () {
    final canvas = Canvas(ui.PictureRecorder());
    for (final slices in [
      [const PieSlice(value: 1, color: Colors.green)],
      [
        const PieSlice(value: 0.001, color: Colors.green),
        const PieSlice(value: 99, color: Colors.red),
      ],
      [
        for (var i = 0; i < 5; i++)
          PieSlice(value: 1.0 + i, color: Colors.primaries[i]),
      ],
    ]) {
      expect(
        () => PieChartPainter(
          slices: slices,
          emptyColor: Colors.grey,
          roundedCaps: true,
          holeFraction: 0.68,
        ).paint(canvas, const Size(172, 172)),
        returnsNormally,
      );
    }
  });
}

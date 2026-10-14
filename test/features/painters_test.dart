import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/domain/models/category.dart';
import 'package:ocr_expense_tracker/domain/models/receipt.dart';
import 'package:ocr_expense_tracker/domain/models/receipt_line_item.dart';
import 'package:ocr_expense_tracker/features/bill_stack/painters/bill_templates/template_registry.dart';
import 'package:ocr_expense_tracker/features/charts/painters/bar_chart_painter.dart';
import 'package:ocr_expense_tracker/features/charts/painters/pie_chart_painter.dart';

Receipt _receipt(String id, {bool items = true}) => Receipt(
  id: id,
  merchantName: 'A very long merchant name that must be ellipsized properly',
  dateTime: DateTime(2025, 3, 12, 9, 30),
  total: 123000,
  category: Category.food,
  createdAt: DateTime(2025, 3, 12),
  lineItems: items
      ? [
          for (var i = 0; i < 30; i++)
            ReceiptLineItem(
              name: 'Item $i',
              price: 1000.0 * i,
              quantity: i % 3 + 1,
            ),
        ]
      : null,
);

void main() {
  test(
    'every bill template paints without throwing, with and without items',
    () {
      for (final t in TemplateRegistry.templates) {
        for (final items in [true, false]) {
          final recorder = PictureRecorder();
          expect(
            () => t.paint(
              Canvas(recorder),
              const Size(280, 430),
              _receipt('abcdef123', items: items),
            ),
            returnsNormally,
            reason: t.name,
          );
          recorder.endRecording();
        }
      }
    },
  );

  test('template registry is stable per seed and covers all templates', () {
    expect(TemplateRegistry.pick('same'), TemplateRegistry.pick('same'));
    final picked = {
      for (var i = 0; i < 200; i++) TemplateRegistry.pick('id-$i').name,
    };
    expect(picked.length, TemplateRegistry.templates.length);
  });

  test('chart painters handle empty and zero data', () {
    final canvas = Canvas(PictureRecorder());
    const PieChartPainter(
      slices: [],
      emptyColor: Colors.grey,
    ).paint(canvas, const Size(200, 200));
    const PieChartPainter(
      slices: [PieSlice(value: 0, color: Colors.red)],
      emptyColor: Colors.grey,
    ).paint(canvas, const Size(200, 200));
    BarChartPainter(
      bars: const [],
      barColor: Colors.red,
      gridColor: Colors.grey,
      labelStyle: const TextStyle(),
    ).paint(canvas, const Size(200, 200));
    BarChartPainter(
      bars: const [BarDatum(label: 'Mon', value: 0)],
      barColor: Colors.red,
      gridColor: Colors.grey,
      labelStyle: const TextStyle(),
    ).paint(canvas, const Size(200, 200));
  });

  test('pie shouldRepaint only when data changes', () {
    const a = PieChartPainter(
      slices: [PieSlice(value: 1, color: Colors.red)],
      emptyColor: Colors.grey,
    );
    const same = PieChartPainter(
      slices: [PieSlice(value: 1, color: Colors.red)],
      emptyColor: Colors.grey,
    );
    const other = PieChartPainter(
      slices: [PieSlice(value: 2, color: Colors.red)],
      emptyColor: Colors.grey,
    );
    expect(a.shouldRepaint(same), isFalse);
    expect(a.shouldRepaint(other), isTrue);
  });
}

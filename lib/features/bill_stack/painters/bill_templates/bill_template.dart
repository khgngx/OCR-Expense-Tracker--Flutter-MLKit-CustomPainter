import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../domain/models/receipt.dart';

/// A paper-bill look. Add a new style by extending this and registering it in
/// `TemplateRegistry`; nothing else needs to change.
abstract class BillTemplate {
  const BillTemplate();

  String get name;

  /// Paints [receipt] filling [size] (the paper's full bounds).
  void paint(Canvas canvas, Size size, Receipt receipt);

  // ---- shared drawing helpers ----

  static const List<String> monoFallback = [
    'Courier',
    'Courier New',
    'monospace',
  ];

  /// Paper outline with an optional zig-zag (torn) top and/or bottom edge.
  static Path paperPath(
    Size size, {
    bool zigTop = false,
    bool zigBottom = true,
    double tooth = 8,
  }) {
    final path = Path()..moveTo(0, zigTop ? tooth : 0);
    if (zigTop) {
      for (double x = 0; x < size.width; x += tooth * 2) {
        path.lineTo(x + tooth, 0);
        path.lineTo(x + tooth * 2, tooth);
      }
    }
    path.lineTo(size.width, zigTop ? tooth : 0);
    path.lineTo(size.width, size.height - (zigBottom ? tooth : 0));
    if (zigBottom) {
      for (double x = size.width; x > 0; x -= tooth * 2) {
        path.lineTo(x - tooth, size.height);
        path.lineTo(x - tooth * 2, size.height - tooth);
      }
    }
    path.lineTo(0, size.height - (zigBottom ? tooth : 0));
    return path..close();
  }

  static void fillPaper(Canvas canvas, Path path, Color color) {
    canvas.drawShadow(path, Colors.black, 3, true);
    canvas.drawPath(path, Paint()..color = color);
  }

  /// Draws one line of text inside [width]; returns its height.
  static double text(
    Canvas canvas,
    String value,
    Offset offset,
    TextStyle style, {
    required double width,
    TextAlign align = TextAlign.left,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: value, style: style),
      textAlign: align,
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(minWidth: width, maxWidth: width);
    painter.paint(canvas, offset);
    return painter.height;
  }

  static void dashedLine(
    Canvas canvas,
    Offset a,
    Offset b,
    Paint paint, {
    double dash = 5,
    double gap = 3,
  }) {
    final length = (b - a).distance;
    final dir = (b - a) / length;
    for (double d = 0; d < length; d += dash + gap) {
      canvas.drawLine(
        a + dir * d,
        a + dir * (d + dash).clamp(0, length),
        paint,
      );
    }
  }

  /// "Name ........ price" rows until [maxY]; returns the y after the last row.
  static double items(
    Canvas canvas,
    Receipt receipt, {
    required double left,
    required double right,
    required double top,
    required double maxY,
    required TextStyle style,
    double rowGap = 4,
  }) {
    var y = top;
    final width = right - left;
    final list = receipt.lineItems;
    if (list == null || list.isEmpty) return y;
    final rowHeight = style.fontSize! * 1.3 + rowGap;
    for (var i = 0; i < list.length; i++) {
      if (y + rowHeight > maxY) {
        if (i < list.length) {
          text(
            canvas,
            '+ ${list.length - i} more…',
            Offset(left, y),
            style,
            width: width,
          );
          y += rowHeight;
        }
        break;
      }
      final item = list[i];
      final label = item.quantity > 1
          ? '${item.quantity}x ${item.name}'
          : item.name;
      text(canvas, label, Offset(left, y), style, width: width * 0.62);
      text(
        canvas,
        CurrencyFormatter.format(item.price),
        Offset(left + width * 0.62, y),
        style,
        width: width * 0.38,
        align: TextAlign.right,
      );
      y += rowHeight;
    }
    return y;
  }

  static String dateLine(Receipt r) => DateFormatter.dateTime(r.dateTime);

  static String numberLine(Receipt r) => r.receiptNumber != null
      ? '#${r.receiptNumber}'
      : '#${r.id.substring(0, r.id.length < 6 ? r.id.length : 6).toUpperCase()}';
}

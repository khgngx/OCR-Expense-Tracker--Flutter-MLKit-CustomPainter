import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/models/receipt.dart';
import 'bill_template.dart';

class RestaurantTemplate extends BillTemplate {
  const RestaurantTemplate();

  @override
  String get name => 'restaurant';

  @override
  void paint(Canvas canvas, Size size, Receipt receipt) {
    BillTemplate.fillPaper(
      canvas,
      BillTemplate.paperPath(size, zigTop: true, zigBottom: true, tooth: 7),
      const Color(0xFFF4F1E8),
    );

    const ink = Color(0xFF1F2A44);
    final pad = size.width * 0.09;
    final w = size.width - pad * 2;
    final base = TextStyle(
      color: ink,
      fontSize: 11.5,
      fontFamilyFallback: BillTemplate.monoFallback,
    );

    final border = Paint()
      ..color = ink.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final frame = Rect.fromLTWH(pad - 6, 18, w + 12, size.height - 36);
    canvas.drawRect(frame, border);
    canvas.drawRect(frame.deflate(3), border);

    final inner = pad + 4;
    final iw = w - 8;
    var y = 34.0;
    y +=
        BillTemplate.text(
          canvas,
          receipt.merchantName.toUpperCase(),
          Offset(inner, y),
          base.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
          width: iw,
          align: TextAlign.center,
        ) +
        2;
    y +=
        BillTemplate.text(
          canvas,
          '— RESTAURANT —',
          Offset(inner, y),
          base.copyWith(fontSize: 9, letterSpacing: 2),
          width: iw,
          align: TextAlign.center,
        ) +
        10;
    y +=
        BillTemplate.text(
          canvas,
          'Date: ${BillTemplate.dateLine(receipt)}',
          Offset(inner, y),
          base,
          width: iw,
        ) +
        2;
    y +=
        BillTemplate.text(
          canvas,
          'Check: ${BillTemplate.numberLine(receipt)}',
          Offset(inner, y),
          base,
          width: iw,
        ) +
        8;
    BillTemplate.dashedLine(
      canvas,
      Offset(inner, y),
      Offset(inner + iw, y),
      border,
    );
    y += 8;

    final footerTop = size.height - 92;
    BillTemplate.items(
      canvas,
      receipt,
      left: inner,
      right: inner + iw,
      top: y,
      maxY: footerTop - 8,
      style: base,
    );

    BillTemplate.dashedLine(
      canvas,
      Offset(inner, footerTop),
      Offset(inner + iw, footerTop),
      border,
    );
    final amount = receipt.total;
    _row(
      canvas,
      'Subtotal',
      CurrencyFormatter.format(amount),
      inner,
      footerTop + 8,
      iw,
      base,
    );
    _row(
      canvas,
      'TOTAL DUE',
      CurrencyFormatter.format(amount),
      inner,
      footerTop + 28,
      iw,
      base.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
    );
    BillTemplate.text(
      canvas,
      'Bon appétit!',
      Offset(inner, footerTop + 56),
      base.copyWith(fontStyle: FontStyle.italic),
      width: iw,
      align: TextAlign.center,
    );
  }

  void _row(
    Canvas canvas,
    String label,
    String value,
    double x,
    double y,
    double w,
    TextStyle style,
  ) {
    BillTemplate.text(canvas, label, Offset(x, y), style, width: w * 0.45);
    BillTemplate.text(
      canvas,
      value,
      Offset(x + w * 0.45, y),
      style,
      width: w * 0.55,
      align: TextAlign.right,
    );
  }
}

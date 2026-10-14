import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/models/receipt.dart';
import 'bill_template.dart';

class SupermarketTemplate extends BillTemplate {
  const SupermarketTemplate();

  @override
  String get name => 'supermarket';

  @override
  void paint(Canvas canvas, Size size, Receipt receipt) {
    BillTemplate.fillPaper(
      canvas,
      BillTemplate.paperPath(size, zigTop: true),
      const Color(0xFFFDFDFB),
    );

    const ink = Color(0xFF2B2B2B);
    final pad = size.width * 0.08;
    final w = size.width - pad * 2;
    final base = TextStyle(
      color: ink,
      fontSize: 11,
      fontFamilyFallback: BillTemplate.monoFallback,
    );
    final line = Paint()
      ..color = ink.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    var y = 22.0;
    y +=
        BillTemplate.text(
          canvas,
          receipt.merchantName.toUpperCase(),
          Offset(pad, y),
          base.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
          width: w,
          align: TextAlign.center,
        ) +
        4;
    y +=
        BillTemplate.text(
          canvas,
          'SUPERMARKET RECEIPT',
          Offset(pad, y),
          base,
          width: w,
          align: TextAlign.center,
        ) +
        6;
    BillTemplate.dashedLine(
      canvas,
      Offset(pad, y),
      Offset(size.width - pad, y),
      line,
    );
    y += 8;
    y +=
        BillTemplate.text(
          canvas,
          BillTemplate.dateLine(receipt),
          Offset(pad, y),
          base,
          width: w,
        ) +
        2;
    y +=
        BillTemplate.text(
          canvas,
          'BILL ${BillTemplate.numberLine(receipt)}',
          Offset(pad, y),
          base,
          width: w,
        ) +
        6;
    BillTemplate.dashedLine(
      canvas,
      Offset(pad, y),
      Offset(size.width - pad, y),
      line,
    );
    y += 8;

    final footerTop = size.height - 96;
    y = BillTemplate.items(
      canvas,
      receipt,
      left: pad,
      right: size.width - pad,
      top: y,
      maxY: footerTop - 10,
      style: base,
    );

    BillTemplate.dashedLine(
      canvas,
      Offset(pad, footerTop),
      Offset(size.width - pad, footerTop),
      line,
    );
    BillTemplate.text(
      canvas,
      'TOTAL',
      Offset(pad, footerTop + 8),
      base.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
      width: w * 0.4,
    );
    BillTemplate.text(
      canvas,
      CurrencyFormatter.format(receipt.total),
      Offset(pad + w * 0.4, footerTop + 8),
      base.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
      width: w * 0.6,
      align: TextAlign.right,
    );

    _barcode(
      canvas,
      Rect.fromLTWH(pad, footerTop + 34, w, 28),
      receipt.id,
      ink,
    );
    BillTemplate.text(
      canvas,
      'THANK YOU',
      Offset(pad, footerTop + 66),
      base.copyWith(fontSize: 10),
      width: w,
      align: TextAlign.center,
    );
  }

  /// Decorative barcode whose bars are derived from [seed], so it is stable per bill.
  void _barcode(Canvas canvas, Rect rect, String seed, Color color) {
    final paint = Paint()..color = color;
    var x = rect.left;
    var i = 0;
    while (x < rect.right) {
      final unit = seed.codeUnitAt(i % seed.length);
      final barWidth = 1.0 + (unit % 3);
      if (i.isEven) {
        canvas.drawRect(
          Rect.fromLTWH(
            x,
            rect.top,
            barWidth.clamp(0, rect.right - x),
            rect.height,
          ),
          paint,
        );
      }
      x += barWidth + 1;
      i++;
    }
  }
}

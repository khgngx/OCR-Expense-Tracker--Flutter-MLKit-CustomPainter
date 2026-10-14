import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/models/receipt.dart';
import 'bill_template.dart';

class CafeReceiptTemplate extends BillTemplate {
  const CafeReceiptTemplate();

  @override
  String get name => 'cafe';

  @override
  void paint(Canvas canvas, Size size, Receipt receipt) {
    BillTemplate.fillPaper(
      canvas,
      BillTemplate.paperPath(size, zigBottom: true, tooth: 6),
      const Color(0xFFFFF6E5),
    );

    const ink = Color(0xFF5A3E2B);
    final pad = size.width * 0.1;
    final w = size.width - pad * 2;
    final base = TextStyle(
      color: ink,
      fontSize: 12,
      fontFamilyFallback: BillTemplate.monoFallback,
    );

    _cup(canvas, Offset(size.width / 2, 40), ink);

    var y = 72.0;
    y +=
        BillTemplate.text(
          canvas,
          receipt.merchantName,
          Offset(pad, y),
          base.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
          width: w,
          align: TextAlign.center,
        ) +
        2;
    y +=
        BillTemplate.text(
          canvas,
          'fresh · warm · yours',
          Offset(pad, y),
          base.copyWith(fontSize: 10, fontStyle: FontStyle.italic),
          width: w,
          align: TextAlign.center,
        ) +
        10;

    final rule = Paint()
      ..color = ink.withValues(alpha: 0.35)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(pad, y), Offset(size.width - pad, y), rule);
    y += 8;
    y +=
        BillTemplate.text(
          canvas,
          BillTemplate.dateLine(receipt),
          Offset(pad, y),
          base,
          width: w,
          align: TextAlign.center,
        ) +
        2;
    y +=
        BillTemplate.text(
          canvas,
          'Order ${BillTemplate.numberLine(receipt)}',
          Offset(pad, y),
          base,
          width: w,
          align: TextAlign.center,
        ) +
        8;
    canvas.drawLine(Offset(pad, y), Offset(size.width - pad, y), rule);
    y += 8;

    final footerTop = size.height - 70;
    BillTemplate.items(
      canvas,
      receipt,
      left: pad,
      right: size.width - pad,
      top: y,
      maxY: footerTop - 8,
      style: base,
    );

    canvas.drawLine(
      Offset(pad, footerTop),
      Offset(size.width - pad, footerTop),
      rule,
    );
    BillTemplate.text(
      canvas,
      'Total',
      Offset(pad, footerTop + 10),
      base.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
      width: w * 0.4,
    );
    BillTemplate.text(
      canvas,
      CurrencyFormatter.format(receipt.total),
      Offset(pad + w * 0.4, footerTop + 10),
      base.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
      width: w * 0.6,
      align: TextAlign.right,
    );
    BillTemplate.text(
      canvas,
      'See you again ♥',
      Offset(pad, footerTop + 38),
      base.copyWith(fontSize: 10),
      width: w,
      align: TextAlign.center,
    );
  }

  void _cup(Canvas canvas, Offset c, Color color) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final body = Path()
      ..moveTo(c.dx - 16, c.dy - 6)
      ..lineTo(c.dx + 16, c.dy - 6)
      ..quadraticBezierTo(c.dx + 14, c.dy + 16, c.dx, c.dy + 16)
      ..quadraticBezierTo(c.dx - 14, c.dy + 16, c.dx - 16, c.dy - 6);
    canvas.drawPath(body, stroke);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(c.dx + 19, c.dy + 2), radius: 6),
      -1.2,
      2.4,
      false,
      stroke,
    );
    for (final dx in [-7.0, 0.0, 7.0]) {
      final steam = Path()
        ..moveTo(c.dx + dx, c.dy - 12)
        ..quadraticBezierTo(c.dx + dx + 3, c.dy - 17, c.dx + dx, c.dy - 22);
      canvas.drawPath(steam, stroke..strokeWidth = 1.6);
    }
  }
}

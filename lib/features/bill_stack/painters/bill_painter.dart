import 'package:flutter/widgets.dart';

import '../../../domain/models/receipt.dart';
import 'bill_templates/bill_template.dart';

class BillPainter extends CustomPainter {
  const BillPainter({required this.template, required this.receipt});

  final BillTemplate template;
  final Receipt receipt;

  @override
  void paint(Canvas canvas, Size size) => template.paint(canvas, size, receipt);

  @override
  bool shouldRepaint(BillPainter old) =>
      old.template != template || old.receipt != receipt;
}

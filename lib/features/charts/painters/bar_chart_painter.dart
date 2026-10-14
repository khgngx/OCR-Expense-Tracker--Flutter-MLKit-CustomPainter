import 'dart:math' as math;

import 'package:flutter/material.dart';

class BarDatum {
  const BarDatum({required this.label, required this.value});

  final String label;
  final double value;
}

/// Vertical bar chart with light grid lines and labels under each bar.
class BarChartPainter extends CustomPainter {
  const BarChartPainter({
    required this.bars,
    required this.barColor,
    required this.gridColor,
    required this.labelStyle,
    this.progress = 1,
  });

  final List<BarDatum> bars;
  final Color barColor;
  final Color gridColor;
  final TextStyle labelStyle;
  final double progress;

  static const double _labelHeight = 22;
  static const int _gridLines = 4;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;
    final chartHeight = size.height - _labelHeight;
    if (chartHeight <= 0) return;

    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= _gridLines; i++) {
      final y = chartHeight * i / _gridLines;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final maxValue = bars.map((b) => b.value).fold<double>(0, math.max);
    final slot = size.width / bars.length;
    final barWidth = slot * 0.5;
    final paint = Paint()..color = barColor;

    for (var i = 0; i < bars.length; i++) {
      final bar = bars[i];
      final x = slot * i + (slot - barWidth) / 2;
      final fraction = maxValue <= 0 ? 0.0 : bar.value / maxValue;
      final height = chartHeight * fraction * progress.clamp(0.0, 1.0);
      if (height > 0) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(x, chartHeight - height, barWidth, height),
            topLeft: const Radius.circular(6),
            topRight: const Radius.circular(6),
          ),
          paint,
        );
      }
      final label = TextPainter(
        text: TextSpan(text: bar.label, style: labelStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: slot);
      label.paint(
        canvas,
        Offset(slot * i + (slot - label.width) / 2, chartHeight + 6),
      );
    }
  }

  @override
  bool shouldRepaint(BarChartPainter old) =>
      old.progress != progress ||
      old.barColor != barColor ||
      old.gridColor != gridColor ||
      old.labelStyle != labelStyle ||
      !_sameBars(old.bars, bars);

  static bool _sameBars(List<BarDatum> a, List<BarDatum> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].label != b[i].label || a[i].value != b[i].value) return false;
    }
    return true;
  }
}

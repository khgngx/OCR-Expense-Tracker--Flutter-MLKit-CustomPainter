import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class BarDatum {
  const BarDatum({required this.label, required this.value});

  final String label;
  final double value;
}

/// Vertical bar chart with light grid lines and labels under each bar. One bar
/// can be highlighted ([selectedIndex]) and carry a tooltip bubble.
class BarChartPainter extends CustomPainter {
  const BarChartPainter({
    required this.bars,
    required this.barColor,
    required this.gridColor,
    required this.labelStyle,
    this.progress = 1,
    this.selectedIndex,
    this.selectedColor,
    this.tooltipText,
    this.tooltipColor = const Color(0xFF14392C),
  });

  final List<BarDatum> bars;

  /// Color of unselected bars (and of all bars when nothing is selected).
  final Color barColor;
  final Color gridColor;
  final TextStyle labelStyle;
  final double progress;
  final int? selectedIndex;
  final Color? selectedColor;

  /// Text of the bubble above the selected bar; no bubble when null.
  final String? tooltipText;
  final Color tooltipColor;

  static const double _labelHeight = 22;
  static const double _tooltipSpace = 36;
  static const int _gridLines = 4;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) {
      return;
    }
    final top = tooltipText != null ? _tooltipSpace : 0.0;
    final chartHeight = size.height - _labelHeight - top;
    if (chartHeight <= 0) {
      return;
    }

    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= _gridLines; i++) {
      final y = top + chartHeight * i / _gridLines;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final maxValue = bars.map((b) => b.value).fold<double>(0, math.max);
    final slot = size.width / bars.length;
    final barWidth = math.min(slot * 0.5, 36.0);

    for (var i = 0; i < bars.length; i++) {
      final bar = bars[i];
      final x = slot * i + (slot - barWidth) / 2;
      final fraction = maxValue <= 0 ? 0.0 : bar.value / maxValue;
      final height = chartHeight * fraction * progress.clamp(0.0, 1.0);
      final selected = i == selectedIndex;
      final paint = Paint()
        ..color = selected ? (selectedColor ?? barColor) : barColor;
      final rect = Rect.fromLTWH(
        x,
        top + chartHeight - height,
        barWidth,
        height,
      );
      if (height > 0) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            rect,
            topLeft: const Radius.circular(8),
            topRight: const Radius.circular(8),
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
        Offset(slot * i + (slot - label.width) / 2, top + chartHeight + 6),
      );

      if (selected && tooltipText != null) {
        _paintTooltip(canvas, size, Offset(x + barWidth / 2, rect.top));
      }
    }
  }

  void _paintTooltip(Canvas canvas, Size size, Offset anchor) {
    final painter = TextPainter(
      text: TextSpan(
        text: tooltipText,
        style: labelStyle.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    const padH = 10.0, padV = 6.0, gap = 6.0;
    final w = painter.width + padH * 2;
    final h = painter.height + padV * 2;
    final left = (anchor.dx - w / 2)
        .clamp(0.0, math.max(0.0, size.width - w))
        .toDouble();
    final bubble = Rect.fromLTWH(left, anchor.dy - h - gap, w, h);
    final fill = Paint()..color = tooltipColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bubble, const Radius.circular(10)),
      fill,
    );
    canvas.drawPath(
      Path()
        ..moveTo(anchor.dx - 5, bubble.bottom)
        ..lineTo(anchor.dx + 5, bubble.bottom)
        ..lineTo(anchor.dx, bubble.bottom + 5)
        ..close(),
      fill,
    );
    painter.paint(canvas, Offset(bubble.left + padH, bubble.top + padV));
  }

  @override
  bool shouldRepaint(BarChartPainter old) =>
      old.progress != progress ||
      old.barColor != barColor ||
      old.gridColor != gridColor ||
      old.labelStyle != labelStyle ||
      old.selectedIndex != selectedIndex ||
      old.selectedColor != selectedColor ||
      old.tooltipText != tooltipText ||
      old.tooltipColor != tooltipColor ||
      !_sameBars(old.bars, bars);

  static bool _sameBars(List<BarDatum> a, List<BarDatum> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i].label != b[i].label || a[i].value != b[i].value) {
        return false;
      }
    }
    return true;
  }
}

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class PieSlice {
  const PieSlice({required this.value, required this.color});

  final double value;
  final Color color;
}

/// Donut chart. [progress] (0..1) sweeps the slices in for the intro animation.
class PieChartPainter extends CustomPainter {
  const PieChartPainter({
    required this.slices,
    required this.emptyColor,
    this.progress = 1,
    this.holeFraction = 0.58,
    this.roundedCaps = false,
  });

  final List<PieSlice> slices;
  final Color emptyColor;
  final double progress;
  final double holeFraction;

  /// Round segment ends with a visible gap between them, like the reference.
  final bool roundedCaps;

  @override
  void paint(Canvas canvas, Size size) {
    final diameter = math.min(size.width, size.height);
    final outer = diameter / 2;
    final stroke = outer * (1 - holeFraction);
    final center = size.center(Offset.zero);
    final rect = Rect.fromCircle(center: center, radius: outer - stroke / 2);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = roundedCaps ? StrokeCap.round : StrokeCap.butt;

    final total = slices.fold<double>(0, (sum, s) => sum + s.value);
    if (total <= 0) {
      canvas.drawArc(rect, 0, math.pi * 2, false, ring..color = emptyColor);
      return;
    }

    final midRadius = outer - stroke / 2;
    // With round caps each end sticks out by half the stroke, so the arc is
    // shortened by that much (plus a hairline gap) to keep neighbors apart.
    final capPad = roundedCaps ? (stroke / 2) / midRadius : 0.0;
    final gap = roundedCaps ? 0.05 : 0.02;
    var start = -math.pi / 2;
    final fullSweep = math.pi * 2 * progress.clamp(0.0, 1.0);
    var drawn = 0.0;
    for (final s in slices.where((s) => s.value > 0)) {
      final sweep = s.value / total * math.pi * 2;
      final visible = math.min(sweep, math.max(0.0, fullSweep - drawn));
      if (visible > 0) {
        final pad = slices.length > 1 ? capPad + gap / 2 : 0.0;
        final length = math.max(visible - 2 * pad, roundedCaps ? 0.001 : 0.0);
        canvas.drawArc(
          rect,
          start + (visible - length) / 2,
          length,
          false,
          ring..color = s.color,
        );
      }
      start += sweep;
      drawn += sweep;
    }
  }

  @override
  bool shouldRepaint(PieChartPainter old) =>
      old.progress != progress ||
      old.emptyColor != emptyColor ||
      old.holeFraction != holeFraction ||
      old.roundedCaps != roundedCaps ||
      !_sameSlices(old.slices, slices);

  static bool _sameSlices(List<PieSlice> a, List<PieSlice> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].value != b[i].value || a[i].color != b[i].color) return false;
    }
    return true;
  }
}

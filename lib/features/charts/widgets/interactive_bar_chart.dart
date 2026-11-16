import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../painters/bar_chart_painter.dart';

/// "Nice" top of a 3-row axis for [maxValue]: 0, s, 2s, 3s with s in {1, 2, 2.5, 5}·10^k.
/// A zero or negative [maxValue] gives a small default so the axis never collapses.
double niceAxisMax(double maxValue) {
  if (maxValue <= 0) {
    return 3;
  }
  final raw = maxValue / 3;
  final magnitude = math
      .pow(10, (math.log(raw) / math.ln10).floor())
      .toDouble();
  for (final m in const [1.0, 2.0, 2.5, 5.0, 10.0]) {
    if (m * magnitude * 3 >= maxValue) {
      return m * magnitude * 3;
    }
  }
  return 10 * magnitude * 3;
}

/// [BarChartPainter] plus tap-to-select and a value axis on the right. The last
/// bar starts selected, as in the reference's "Spending Trend".
class InteractiveBarChart extends StatefulWidget {
  const InteractiveBarChart({
    super.key,
    required this.bars,
    required this.formatValue,
    this.height = 190,
  });

  final List<BarDatum> bars;
  final String Function(double value) formatValue;
  final double height;

  @override
  State<InteractiveBarChart> createState() => _InteractiveBarChartState();
}

class _InteractiveBarChartState extends State<InteractiveBarChart> {
  static const double _axisWidth = 40;

  int? _selected;

  int? get _effectiveSelected {
    if (widget.bars.isEmpty) {
      return null;
    }
    return (_selected ?? widget.bars.length - 1).clamp(
      0,
      widget.bars.length - 1,
    );
  }

  void _select(Offset local, double width) {
    if (widget.bars.isEmpty) {
      return;
    }
    final chartWidth = width - _axisWidth;
    final index = (local.dx / (chartWidth / widget.bars.length)).floor();
    setState(() => _selected = index.clamp(0, widget.bars.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = _effectiveSelected;
    final maxValue = widget.bars.map((b) => b.value).fold<double>(0, math.max);
    final axisMax = niceAxisMax(maxValue);
    final labels = [
      for (var i = 3; i >= 0; i--) CurrencyFormatter.compact(axisMax * i / 3),
    ];
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) => _select(d.localPosition, constraints.maxWidth),
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, t, _) => CustomPaint(
              painter: BarChartPainter(
                bars: widget.bars,
                barColor: const Color(0xFFC3D1C6),
                selectedColor: AppColors.forest,
                gridColor: theme.colorScheme.outlineVariant,
                labelStyle: theme.textTheme.labelSmall!.copyWith(
                  color: AppColors.muted,
                ),
                progress: t,
                selectedIndex: selected,
                showGrid: false,
                axisLabels: labels,
                axisMax: axisMax,
                maxBarWidth: 28,
                tooltipText: selected == null
                    ? null
                    : widget.formatValue(widget.bars[selected].value),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

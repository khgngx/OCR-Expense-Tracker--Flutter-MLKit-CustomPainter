import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_colors.dart';
import '../painters/bar_chart_painter.dart';

/// [BarChartPainter] plus tap-to-select. The last bar starts selected.
class InteractiveBarChart extends StatefulWidget {
  const InteractiveBarChart({
    super.key,
    required this.bars,
    required this.formatValue,
    this.height = 200,
  });

  final List<BarDatum> bars;
  final String Function(double value) formatValue;
  final double height;

  @override
  State<InteractiveBarChart> createState() => _InteractiveBarChartState();
}

class _InteractiveBarChartState extends State<InteractiveBarChart> {
  int? _selected;

  int? get _effectiveSelected {
    if (widget.bars.isEmpty) {
      return null;
    }
    final s = _selected ?? widget.bars.length - 1;
    return s.clamp(0, widget.bars.length - 1);
  }

  void _select(Offset local, double width) {
    if (widget.bars.isEmpty) {
      return;
    }
    final index = (local.dx / (width / widget.bars.length)).floor();
    setState(() => _selected = index.clamp(0, widget.bars.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = _effectiveSelected;
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
                barColor: const Color(0xFFC5D3C8),
                selectedColor: AppColors.forest,
                gridColor: theme.colorScheme.outlineVariant,
                labelStyle: theme.textTheme.labelSmall!.copyWith(
                  color: AppColors.muted,
                ),
                progress: t,
                selectedIndex: selected,
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

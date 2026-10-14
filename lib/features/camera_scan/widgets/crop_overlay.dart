import 'package:flutter/material.dart';

import '../painters/crop_overlay_painter.dart';

/// Draggable/resizable crop frame laid over a camera preview.
/// [rect] and [onChanged] use fractions (0..1) of the widget's size.
class CropOverlay extends StatefulWidget {
  const CropOverlay({super.key, required this.rect, required this.onChanged});

  final Rect rect;
  final ValueChanged<Rect> onChanged;

  @override
  State<CropOverlay> createState() => _CropOverlayState();
}

enum _Drag { none, move, topLeft, topRight, bottomLeft, bottomRight }

class _CropOverlayState extends State<CropOverlay> {
  static const double _grab = 32;
  static const double _minFraction = 0.15;

  _Drag _mode = _Drag.none;

  _Drag _hitTest(Offset p, Rect r) {
    if ((p - r.topLeft).distance < _grab) return _Drag.topLeft;
    if ((p - r.topRight).distance < _grab) return _Drag.topRight;
    if ((p - r.bottomLeft).distance < _grab) return _Drag.bottomLeft;
    if ((p - r.bottomRight).distance < _grab) return _Drag.bottomRight;
    return r.contains(p) ? _Drag.move : _Drag.none;
  }

  Rect _apply(Rect r, Offset delta, Size size) {
    final dx = delta.dx / size.width;
    final dy = delta.dy / size.height;
    double l = r.left, t = r.top, rt = r.right, b = r.bottom;
    switch (_mode) {
      case _Drag.move:
        final mx = (l + dx).clamp(0.0, 1.0 - r.width);
        final my = (t + dy).clamp(0.0, 1.0 - r.height);
        return Rect.fromLTWH(mx, my, r.width, r.height);
      case _Drag.topLeft:
        l += dx;
        t += dy;
      case _Drag.topRight:
        rt += dx;
        t += dy;
      case _Drag.bottomLeft:
        l += dx;
        b += dy;
      case _Drag.bottomRight:
        rt += dx;
        b += dy;
      case _Drag.none:
        return r;
    }
    l = l.clamp(0.0, rt - _minFraction);
    t = t.clamp(0.0, b - _minFraction);
    rt = rt.clamp(l + _minFraction, 1.0);
    b = b.clamp(t + _minFraction, 1.0);
    return Rect.fromLTRB(l, t, rt, b);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = constraints.biggest;
      final pixelRect = Rect.fromLTRB(
        widget.rect.left * size.width,
        widget.rect.top * size.height,
        widget.rect.right * size.width,
        widget.rect.bottom * size.height,
      );
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (d) => _mode = _hitTest(d.localPosition, pixelRect),
        onPanUpdate: (d) =>
            widget.onChanged(_apply(widget.rect, d.delta, size)),
        onPanEnd: (_) => _mode = _Drag.none,
        child: CustomPaint(
          size: size,
          painter: CropOverlayPainter(
            rect: pixelRect,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    },
  );
}

import 'package:flutter/material.dart';

class CropOverlayPainter extends CustomPainter {
  const CropOverlayPainter({required this.rect, required this.color});

  /// Crop rectangle in pixels of the painted area.
  final Rect rect;
  final Color color;

  static const double handleLength = 22;

  @override
  void paint(Canvas canvas, Size size) {
    final dim = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addRect(rect),
    );
    canvas.drawPath(dim, Paint()..color = Colors.black54);

    canvas.drawRect(
      rect,
      Paint()
        ..color = color.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final handle = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (final corner in [
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ]) {
      final dx = corner.dx == rect.left ? handleLength : -handleLength;
      final dy = corner.dy == rect.top ? handleLength : -handleLength;
      canvas.drawLine(corner, corner.translate(dx, 0), handle);
      canvas.drawLine(corner, corner.translate(0, dy), handle);
    }
  }

  @override
  bool shouldRepaint(CropOverlayPainter old) =>
      old.rect != rect || old.color != color;
}

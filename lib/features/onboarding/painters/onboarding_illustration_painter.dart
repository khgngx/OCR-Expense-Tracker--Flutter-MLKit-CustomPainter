import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_colors.dart';

enum IllustrationKind { wallet, receipt, chart }

/// Vector stand-ins for the reference's 3D art: an object floating over a round
/// podium on the dark green background.
class OnboardingIllustrationPainter extends CustomPainter {
  const OnboardingIllustrationPainter(this.kind);

  final IllustrationKind kind;

  static const Color _gold = Color(0xFFD9B66B);

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    canvas.save();
    // Bottom-aligned so the podium sits just above the button, like the reference.
    canvas.translate((size.width - side) / 2, size.height - side);
    final s = Size.square(side);
    _podium(canvas, s);
    switch (kind) {
      case IllustrationKind.wallet:
        _wallet(canvas, s);
      case IllustrationKind.receipt:
        _receipt(canvas, s);
      case IllustrationKind.chart:
        _chart(canvas, s);
    }
    canvas.restore();
  }

  void _podium(Canvas canvas, Size s) {
    final cx = s.width / 2;
    // Soft shadow under the floating object.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, s.height * 0.80),
        width: s.width * 0.5,
        height: s.height * 0.06,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    final top = s.height * 0.86;
    final body = Rect.fromLTRB(
      cx - s.width * 0.36,
      top,
      cx + s.width * 0.36,
      s.height * 1.02,
    );
    canvas.drawRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF173D2E), Color(0xFF265A45), Color(0xFF173D2E)],
        ).createShader(body),
    );
    final cap = Rect.fromCenter(
      center: Offset(cx, top),
      width: s.width * 0.72,
      height: s.height * 0.12,
    );
    canvas.drawOval(cap, Paint()..color = const Color(0xFF2B5F49));
    canvas.drawOval(
      cap.deflate(s.width * 0.05),
      Paint()
        ..color = const Color(0xFF1E4A38)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _wallet(Canvas canvas, Size s) {
    canvas.save();
    canvas.translate(s.width / 2, s.height * 0.54);
    canvas.rotate(-0.14);

    final w = s.width * 0.66;
    final h = s.height * 0.46;
    final r = Radius.circular(s.width * 0.05);

    // Card sliding out of the wallet.
    canvas.save();
    canvas.translate(-w * 0.02, -h * 0.55);
    canvas.rotate(0.12);
    final card = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w * 0.78, height: h * 0.62),
      Radius.circular(s.width * 0.035),
    );
    canvas.drawRRect(
      card,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8FA39A), Color(0xFF4F625A)],
        ).createShader(card.outerRect),
    );
    final chip = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        card.left + w * 0.08,
        card.top + h * 0.12,
        w * 0.12,
        h * 0.1,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(chip, Paint()..color = _gold);
    canvas.drawCircle(
      Offset(card.right - w * 0.12, card.bottom - h * 0.12),
      h * 0.07,
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
    canvas.restore();

    // Back panel, front panel and flap.
    final back = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(-w * 0.03, -h * 0.03),
        width: w,
        height: h,
      ),
      r,
    );
    canvas.drawRRect(back, Paint()..color = const Color(0xFF0E2A1F));
    final front = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.02, h * 0.04),
        width: w,
        height: h * 0.9,
      ),
      r,
    );
    canvas.drawRRect(
      front,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A5E48), Color(0xFF133428)],
        ).createShader(front.outerRect),
    );
    // Stitching.
    final stitch = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final inner = front.deflate(s.width * 0.02);
    final path = Path()..addRRect(inner);
    for (final m in path.computeMetrics()) {
      for (double d = 0; d < m.length; d += 9) {
        canvas.drawPath(m.extractPath(d, math.min(d + 5, m.length)), stitch);
      }
    }
    final flap = RRect.fromRectAndCorners(
      Rect.fromLTRB(w * 0.14, -h * 0.30, w * 0.52, h * 0.34),
      topLeft: Radius.circular(s.width * 0.03),
      bottomLeft: Radius.circular(s.width * 0.03),
      topRight: r,
      bottomRight: r,
    );
    canvas.drawRRect(flap, Paint()..color = const Color(0xFF1B4535));
    canvas.drawCircle(
      Offset(w * 0.2, h * 0.02),
      s.width * 0.032,
      Paint()
        ..shader =
            const RadialGradient(colors: [Color(0xFFF1D9A0), Color(0xFFB88A3A)])
                .createShader(
                  Rect.fromCircle(
                    center: Offset(w * 0.2, h * 0.02),
                    radius: s.width * 0.032,
                  ),
                ),
    );
    canvas.restore();
  }

  void _receipt(Canvas canvas, Size s) {
    canvas.save();
    canvas.translate(s.width / 2, s.height * 0.52);
    canvas.rotate(-0.1);
    final w = s.width * 0.40;
    final h = s.height * 0.52;
    final top = -h / 2;
    final path = Path()
      ..moveTo(-w / 2, top)
      ..lineTo(w / 2, top)
      ..lineTo(w / 2, h / 2);
    const teeth = 8;
    for (var i = 0; i < teeth; i++) {
      final x = w / 2 - w * (i + 0.5) / teeth;
      path
        ..lineTo(x, h / 2 + s.height * 0.025)
        ..lineTo(w / 2 - w * (i + 1) / teeth, h / 2);
    }
    path
      ..lineTo(-w / 2, top)
      ..close();
    canvas.drawShadow(path, Colors.black, 8, true);
    canvas.drawPath(path, Paint()..color = const Color(0xFFF7F3E6));
    final bar = Paint()..color = AppColors.forest.withValues(alpha: 0.75);
    final head = RRect.fromRectAndRadius(
      Rect.fromLTWH(-w * 0.3, top + h * 0.08, w * 0.6, h * 0.045),
      const Radius.circular(3),
    );
    canvas.drawRRect(head, Paint()..color = AppColors.forest);
    for (var i = 0; i < 5; i++) {
      final y = top + h * (0.22 + i * 0.09);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-w * 0.34, y, w * (i.isEven ? 0.46 : 0.38), h * 0.025),
          const Radius.circular(2),
        ),
        bar,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.14, y, w * 0.2, h * 0.025),
          const Radius.circular(2),
        ),
        bar,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-w * 0.34, top + h * 0.74, w * 0.68, h * 0.07),
        const Radius.circular(4),
      ),
      Paint()..color = AppColors.lime,
    );
    canvas.restore();
  }

  void _chart(Canvas canvas, Size s) {
    final center = Offset(s.width / 2, s.height * 0.52);
    final radius = s.width * 0.2;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.1
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s.width * 0.1
        ..color = Colors.white.withValues(alpha: 0.08),
    );
    var start = -math.pi / 2;
    for (final (fraction, color) in [
      (0.38, AppColors.lime),
      (0.27, const Color(0xFF5FAE82)),
      (0.2, const Color(0xFFA7B0A9)),
    ]) {
      final sweep = math.pi * 2 * fraction;
      canvas.drawArc(
        rect,
        start + 0.12,
        sweep - 0.24,
        false,
        ring..color = color,
      );
      start += sweep;
    }
    canvas.drawCircle(
      center,
      s.width * 0.085,
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );
  }

  @override
  bool shouldRepaint(OnboardingIllustrationPainter old) => old.kind != kind;
}

import 'package:flutter/material.dart';

import '../../../domain/models/receipt.dart';
import '../painters/bill_painter.dart';
import '../painters/bill_templates/template_registry.dart';

/// A bill that can be dragged away. Past the threshold (or on a fast fling) it
/// flies off and [onDismissed] fires; otherwise it springs back.
class DraggableBillCard extends StatefulWidget {
  const DraggableBillCard({
    super.key,
    required this.receipt,
    required this.onDismissed,
  });

  final Receipt receipt;
  final VoidCallback onDismissed;

  @override
  State<DraggableBillCard> createState() => _DraggableBillCardState();
}

class _DraggableBillCardState extends State<DraggableBillCard>
    with SingleTickerProviderStateMixin {
  static const double _dismissDistance = 110;
  static const double _flingVelocity = 700;

  late final AnimationController _controller = AnimationController(vsync: this);
  Animation<Offset>? _animation;
  Offset _offset = Offset.zero;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(
    Offset target,
    Duration duration,
    Curve curve, {
    VoidCallback? onDone,
  }) {
    _animation = Tween(begin: _offset, end: target).animate(
      CurvedAnimation(parent: _controller, curve: curve),
    )..addListener(() => setState(() => _offset = _animation!.value));
    _controller
      ..duration = duration
      ..forward(from: 0).whenComplete(() {
        if (mounted) onDone?.call();
      });
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    final shouldDismiss =
        _offset.distance > _dismissDistance ||
        velocity.distance > _flingVelocity;
    if (shouldDismiss && _offset.distance > 8) {
      final direction = _offset / _offset.distance;
      _animateTo(
        direction * 600,
        const Duration(milliseconds: 220),
        Curves.easeIn,
        onDone: () {
          setState(() => _offset = Offset.zero);
          widget.onDismissed();
        },
      );
    } else {
      _animateTo(
        Offset.zero,
        const Duration(milliseconds: 300),
        Curves.elasticOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onPanStart: (_) => _controller.stop(),
    onPanUpdate: (d) => setState(() => _offset += d.delta),
    onPanEnd: _onDragEnd,
    child: Transform.translate(
      offset: _offset,
      child: Transform.rotate(
        angle: (_offset.dx / 1200).clamp(-0.5, 0.5),
        child: CustomPaint(
          painter: BillPainter(
            template: TemplateRegistry.pick(widget.receipt.id),
            receipt: widget.receipt,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    ),
  );
}

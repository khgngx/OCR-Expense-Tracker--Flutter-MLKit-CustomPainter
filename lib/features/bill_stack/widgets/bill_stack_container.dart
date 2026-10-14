import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/models/receipt.dart';
import '../painters/bill_painter.dart';
import '../painters/bill_templates/template_registry.dart';
import 'draggable_bill_card.dart';

/// Layered pile of bills. The top bill can be dragged off; it then goes to the
/// bottom of the pile so every bill stays reachable.
class BillStackContainer extends StatefulWidget {
  const BillStackContainer({super.key, required this.receipts});

  final List<Receipt> receipts;

  @override
  State<BillStackContainer> createState() => _BillStackContainerState();
}

class _BillStackContainerState extends State<BillStackContainer> {
  static const int _visibleCount = 4;
  static const double _aspect = 0.64; // width / height

  late List<Receipt> _order = List.of(widget.receipts);

  @override
  void didUpdateWidget(BillStackContainer old) {
    super.didUpdateWidget(old);
    if (old.receipts != widget.receipts) _order = List.of(widget.receipts);
  }

  void _sendTopToBottom() =>
      setState(() => _order = [..._order.skip(1), _order.first]);

  /// Small stable tilt per bill so the pile looks hand-stacked.
  double _tilt(String id) =>
      ((id.codeUnits.fold<int>(0, (a, b) => a + b) % 13) - 6) / 180;

  @override
  Widget build(BuildContext context) {
    if (_order.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final height =
            math.min(constraints.maxHeight, constraints.maxWidth / _aspect) *
            0.92;
        final width = height * _aspect;
        final shown = _order.take(_visibleCount).toList();
        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Paint back-to-front so index 0 ends up on top.
                for (var i = shown.length - 1; i >= 0; i--)
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(0, i * -6.0),
                      child: Transform.rotate(
                        angle: i == 0 ? 0 : _tilt(shown[i].id),
                        child: i == 0
                            ? DraggableBillCard(
                                key: ValueKey(shown[i].id),
                                receipt: shown[i],
                                onDismissed: _sendTopToBottom,
                              )
                            : CustomPaint(
                                painter: BillPainter(
                                  template: TemplateRegistry.pick(shown[i].id),
                                  receipt: shown[i],
                                ),
                                child: const SizedBox.expand(),
                              ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

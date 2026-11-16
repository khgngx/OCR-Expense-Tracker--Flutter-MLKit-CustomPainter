import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'breakpoints.dart';
import 'view_mode.dart';
import 'view_mode_toggle.dart';

/// Wraps the whole app (including every pushed route and dialog). In phone
/// view on a wide window the app is drawn inside a phone-shaped frame whose
/// MediaQuery matches the frame, so inner layouts pick their mobile variants.
class ResponsiveFrame extends StatelessWidget {
  const ResponsiveFrame({super.key, required this.child});

  final Widget child;

  static const Size phoneSize = Size(390, 844);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final canToggle = media.size.width >= Breakpoints.toggleAvailable;
    if (!canToggle || ViewModeScope.of(context).mode == ViewMode.desktop) {
      return child;
    }

    final height = math.min(phoneSize.height, media.size.height - 64);
    final inner = Size(phoneSize.width, height);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      child: Stack(
        children: [
          Center(
            child: Container(
              width: inner.width + 24,
              height: inner.height + 24,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(48),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 32,
                    color: Colors.black38,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: MediaQuery(
                  data: media.copyWith(
                    size: inner,
                    padding: EdgeInsets.zero,
                    viewPadding: EdgeInsets.zero,
                    viewInsets: EdgeInsets.zero,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
          const Positioned(top: 16, right: 16, child: ViewModeToggle()),
        ],
      ),
    );
  }
}

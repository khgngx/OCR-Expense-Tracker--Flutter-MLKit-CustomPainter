import 'package:flutter/material.dart';

import 'view_mode.dart';

/// Switches between the desktop layout and the simulated phone view.
class ViewModeToggle extends StatelessWidget {
  const ViewModeToggle({super.key, this.compact = false});

  /// Single icon button (for the narrow side rail) instead of a segmented control.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final controller = ViewModeScope.of(context);
    if (compact) {
      final isDesktop = controller.mode == ViewMode.desktop;
      return IconButton(
        tooltip: isDesktop ? 'Switch to phone view' : 'Switch to desktop view',
        icon: Icon(
          isDesktop ? Icons.smartphone : Icons.desktop_windows_outlined,
        ),
        onPressed: controller.toggle,
      );
    }
    return SegmentedButton<ViewMode>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
          value: ViewMode.desktop,
          icon: Icon(Icons.desktop_windows_outlined),
          label: Text('Desktop'),
        ),
        ButtonSegment(
          value: ViewMode.phone,
          icon: Icon(Icons.smartphone),
          label: Text('Phone'),
        ),
      ],
      selected: {controller.mode},
      onSelectionChanged: (s) => controller.mode = s.first,
    );
  }
}

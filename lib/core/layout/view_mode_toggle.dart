import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import 'view_mode.dart';

/// Switches between the desktop layout and the simulated phone view.
class ViewModeToggle extends StatelessWidget {
  const ViewModeToggle({super.key, this.compact = false});

  /// Single icon button (for the narrow side rail) instead of a segmented control.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final controller = ViewModeScope.of(context);
    final l10n = AppLocalizations.of(context);
    if (compact) {
      final isDesktop = controller.mode == ViewMode.desktop;
      return IconButton(
        tooltip: isDesktop ? l10n.switchToPhone : l10n.switchToDesktop,
        icon: Icon(
          isDesktop ? Icons.smartphone : Icons.desktop_windows_outlined,
        ),
        onPressed: controller.toggle,
      );
    }
    return SegmentedButton<ViewMode>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(
          value: ViewMode.desktop,
          icon: const Icon(Icons.desktop_windows_outlined),
          label: Text(l10n.viewDesktop),
        ),
        ButtonSegment(
          value: ViewMode.phone,
          icon: const Icon(Icons.smartphone),
          label: Text(l10n.viewPhone),
        ),
      ],
      selected: {controller.mode},
      onSelectionChanged: (s) => controller.mode = s.first,
    );
  }
}

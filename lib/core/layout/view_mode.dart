import 'package:material_ui/material_ui.dart';

enum ViewMode { desktop, phone }

/// Which presentation the user picked on a wide screen: the full desktop layout
/// or the app shown inside a simulated phone frame.
class ViewModeController extends ChangeNotifier {
  ViewMode _mode = ViewMode.desktop;

  ViewMode get mode => _mode;

  set mode(ViewMode value) {
    if (value == _mode) {
      return;
    }
    _mode = value;
    notifyListeners();
  }

  void toggle() =>
      mode = _mode == ViewMode.desktop ? ViewMode.phone : ViewMode.desktop;
}

class ViewModeScope extends InheritedNotifier<ViewModeController> {
  const ViewModeScope({
    super.key,
    required ViewModeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ViewModeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ViewModeScope>();
    assert(scope != null, 'ViewModeScope missing above this context');
    return scope!.notifier!;
  }
}

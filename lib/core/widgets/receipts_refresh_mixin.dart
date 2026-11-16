import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../app_scope.dart';

/// Reloads a screen's data once on first build and again after every
/// repository write, so lists and charts stay current without manual refresh.
mixin ReceiptsRefreshMixin<T extends StatefulWidget> on State<T> {
  StreamSubscription<void>? _changesSub;

  Future<void> reload();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_changesSub != null) {
      return;
    }
    _changesSub = AppScope.of(context).receiptRepository.changes
        .listen((_) => reload());
    reload();
  }

  @override
  void dispose() {
    _changesSub?.cancel();
    super.dispose();
  }
}

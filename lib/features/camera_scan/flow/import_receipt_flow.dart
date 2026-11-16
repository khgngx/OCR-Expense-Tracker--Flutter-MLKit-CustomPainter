import 'package:material_ui/material_ui.dart';

import '../../../app_scope.dart';
import '../../../l10n/app_localizations.dart';
import '../../receipt_review/screens/review_screen.dart';
import '../services/scan_pipeline.dart';

/// Pick a photo, read it with OCR (blocking progress dialog) and open the
/// review screen. Used by the Home quick action; the camera screen has its own
/// in-place version of the same pipeline.
Future<void> importReceiptFlow(BuildContext context) async {
  final deps = AppScope.of(context);
  final l10n = AppLocalizations.of(context);
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);

  final raw = await pickReceiptImage();
  if (raw == null || !context.mounted) {
    return;
  }

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(width: 16),
            Flexible(child: Text(l10n.readingReceipt)),
          ],
        ),
      ),
    ),
  );

  ScanResult? result;
  Object? failure;
  try {
    result = await scanReceipt(deps, raw);
  } on Exception catch (e) {
    failure = e;
  }
  navigator.pop(); // close the progress dialog
  if (failure != null) {
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.scanFailed('$failure'))),
    );
  } else if (result == null) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.noTextFound)));
  } else {
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => ReviewScreen.fromScan(
          parsed: result!.parsed,
          imageBytes: result.image,
        ),
      ),
    );
  }
}

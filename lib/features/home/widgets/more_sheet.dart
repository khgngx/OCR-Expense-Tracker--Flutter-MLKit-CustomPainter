import 'package:material_ui/material_ui.dart';

import '../../../app_scope.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/widgets/budget_dialog.dart';

/// Bottom sheet behind the "More" quick action.
Future<void> showMoreSheet(BuildContext context) {
  final deps = AppScope.of(context);
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.savings_outlined),
            title: Text(l10n.monthlyBudget),
            onTap: () {
              Navigator.pop(sheetContext);
              showBudgetDialog(context);
            },
          ),
          ListenableBuilder(
            listenable: deps.settings,
            builder: (_, _) => ListTile(
              leading: const Icon(Icons.translate),
              title: Text(l10n.language),
              trailing: Text(
                deps.settings.locale.languageCode == 'vi'
                    ? 'Tiếng Việt'
                    : 'English',
              ),
              onTap: deps.settings.toggleLocale,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome_outlined),
            title: Text(l10n.loadDemo),
            onTap: () async {
              Navigator.pop(sheetContext);
              try {
                final n = await deps.seedDemoData();
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.demoLoaded(n))),
                );
              } on Exception catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.demoFailed('$e'))),
                );
              }
            },
          ),
        ],
      ),
    ),
  );
}

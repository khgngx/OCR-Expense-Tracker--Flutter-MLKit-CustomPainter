import 'package:material_ui/material_ui.dart';

import '../../../app_scope.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/budget_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final deps = AppScope.of(context);
    final settings = deps.settings;
    final text = Theme.of(context).textTheme;

    Widget section(String title, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: text.labelLarge?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Card(child: child),
        ],
      ),
    );

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListenableBuilder(
            listenable: settings,
            builder: (context, _) => ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      l10n.settingsTitle,
                      style: text.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                section(
                  l10n.language,
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(value: 'en', label: Text('English')),
                          ButtonSegment(value: 'vi', label: Text('Tiếng Việt')),
                        ],
                        selected: {settings.locale.languageCode},
                        onSelectionChanged: (s) =>
                            settings.setLocale(Locale(s.first)),
                      ),
                    ),
                  ),
                ),
                section(
                  l10n.monthlyBudget,
                  ListTile(
                    leading: const Icon(
                      Icons.savings_outlined,
                      color: AppColors.forest,
                    ),
                    title: Text(
                      settings.hasBudget
                          ? CurrencyFormatter.format(settings.monthlyBudget)
                          : l10n.budgetNotSet,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showBudgetDialog(context),
                  ),
                ),
                section(
                  l10n.demoSection,
                  ListTile(
                    leading: const Icon(
                      Icons.auto_awesome_outlined,
                      color: AppColors.forest,
                    ),
                    title: Text(l10n.loadDemo),
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
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
                ),
                section(
                  l10n.aboutSection,
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.aboutBody, style: text.bodyMedium),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

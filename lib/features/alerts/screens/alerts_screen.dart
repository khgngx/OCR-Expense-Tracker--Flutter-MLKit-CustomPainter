import 'package:material_ui/material_ui.dart';

import '../../../app_scope.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_style.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../domain/models/category.dart';
import '../../../domain/usecases/get_month_summary_usecase.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/widgets/budget_dialog.dart';

/// Behind the header bell: a few insights derived from this month's spending.
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  Future<MonthSummary>? _summary;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _summary ??= AppScope.of(context).getMonthSummary(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = AppScope.of(context).settings;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.alertsTitle)),
      body: FutureBuilder<MonthSummary>(
        future: _summary,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return EmptyState(
              icon: Icons.error_outline,
              message: l10n.loadFailed('${snapshot.error}'),
            );
          }
          final summary = snapshot.data;
          if (summary == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListenableBuilder(
            listenable: settings,
            builder: (context, _) {
              final tiles = <Widget>[];
              final total = summary.total;
              if (settings.hasBudget) {
                final percent = (total / settings.monthlyBudget * 100).round();
                tiles.add(
                  _AlertTile(
                    icon: Icons.savings_outlined,
                    color: percent >= 100 ? AppColors.danger : AppColors.forest,
                    text: l10n.alertBudgetUsed(percent),
                    onTap: () => showBudgetDialog(context),
                  ),
                );
              } else {
                tiles.add(
                  _AlertTile(
                    icon: Icons.savings_outlined,
                    color: AppColors.forest,
                    text: l10n.alertNoBudget,
                    onTap: () => showBudgetDialog(context),
                  ),
                );
              }
              if (total > 0) {
                final top = Category.values.reduce(
                  (a, b) =>
                      (summary.totalsByCategory[a] ?? 0) >=
                          (summary.totalsByCategory[b] ?? 0)
                      ? a
                      : b,
                );
                tiles.add(
                  _AlertTile(
                    icon: top.icon,
                    color: AppColors.forest,
                    text: l10n.alertTopCategory(top.localizedLabel(l10n)),
                  ),
                );
              } else {
                tiles.add(
                  _AlertTile(
                    icon: Icons.receipt_long_outlined,
                    color: AppColors.muted,
                    text: l10n.alertNoSpending,
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: tiles.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => tiles[i],
              );
            },
          );
        },
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.icon,
    required this.color,
    required this.text,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
    ),
  );
}

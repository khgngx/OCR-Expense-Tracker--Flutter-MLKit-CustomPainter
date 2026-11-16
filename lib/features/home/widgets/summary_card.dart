import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/usecases/get_month_summary_usecase.dart';
import '../../../l10n/app_localizations.dart';

/// Dark green hero card: month total, change vs last month, budget progress.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.summary,
    required this.budget,
    required this.onSetBudget,
  });

  final MonthSummary summary;

  /// Monthly budget in VND; 0 when not set.
  final double budget;
  final VoidCallback onSetBudget;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final total = summary.total;
    final amount = CurrencyFormatter.format(total).replaceAll(' VND', '');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.forest, AppColors.forestDeep],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  size: 16,
                  color: AppColors.lime,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.spentThisMonth,
                style: text.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const Spacer(),
              const Icon(Icons.bar_chart_rounded, color: AppColors.lime),
            ],
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: amount,
                  style: text.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: '  VND',
                  style: text.titleMedium?.copyWith(color: AppColors.lime),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _ChangeChip(change: summary.changeVsPrevious),
          const SizedBox(height: 16),
          if (budget > 0)
            _BudgetProgress(spent: total, budget: budget)
          else
            GestureDetector(
              onTap: onSetBudget,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  const Icon(
                    Icons.savings_outlined,
                    size: 18,
                    color: AppColors.lime,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.budgetSetTitle,
                      style: text.bodyMedium?.copyWith(color: Colors.white),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white70),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ChangeChip extends StatelessWidget {
  const _ChangeChip({required this.change});

  final double? change;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final String label;
    IconData? icon;
    final c = change;
    if (c == null) {
      label = l10n.noLastMonthData;
    } else {
      final percent = (c.abs() * 100).round();
      if (percent == 0) {
        label = l10n.sameAsLastMonth;
      } else if (c > 0) {
        label = l10n.moreThanLastMonth(percent);
        icon = Icons.arrow_drop_up;
      } else {
        label = l10n.lessThanLastMonth(percent);
        icon = Icons.arrow_drop_down;
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 20, color: AppColors.lime),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _BudgetProgress extends StatelessWidget {
  const _BudgetProgress({required this.spent, required this.budget});

  final double spent;
  final double budget;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final over = spent > budget;
    final fraction = math.min(spent / budget, 1.0);
    final left = CurrencyFormatter.format(math.max(budget - spent, 0));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            backgroundColor: Colors.white24,
            color: over ? const Color(0xFFFFB4A2) : AppColors.lime,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          over
              ? l10n.budgetOver(((spent - budget) / budget * 100).round())
              : l10n.budgetLeft(left, CurrencyFormatter.format(budget)),
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/usecases/get_month_summary_usecase.dart';
import '../../../l10n/app_localizations.dart';

/// Dark green hero card, laid out like the reference's "Total Balance" card:
/// label with an eye toggle and a bars icon, the amount on the left and a
/// two-line "change vs last month" chip on the right.
class SummaryCard extends StatefulWidget {
  const SummaryCard({super.key, required this.summary, required this.budget});

  final MonthSummary summary;

  /// Monthly budget in VND; 0 when not set.
  final double budget;

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final total = widget.summary.total;
    final amount = _hidden
        ? '••••••'
        : CurrencyFormatter.format(total).replaceAll(' VND', '');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F4F3D), AppColors.forestDeep],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF3E7A62),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.priority_high,
                  size: 13,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.totalSpentLabel,
                style: text.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(width: 2),
              IconButton(
                tooltip: _hidden ? l10n.showAmount : l10n.hideAmount,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () => setState(() => _hidden = !_hidden),
                icon: Icon(
                  _hidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.signal_cellular_alt_rounded,
                color: AppColors.lime,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: amount,
                          style: text.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        TextSpan(
                          text: ' VND',
                          style: text.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _ChangeChip(change: widget.summary.changeVsPrevious),
            ],
          ),
          if (widget.budget > 0) ...[
            const SizedBox(height: 14),
            _BudgetProgress(spent: total, budget: widget.budget),
          ],
        ],
      ),
    );
  }
}

/// "▲ 12.6%" pill with "vs last month" underneath, bottom-right of the card.
class _ChangeChip extends StatelessWidget {
  const _ChangeChip({required this.change});

  final double? change;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = change;
    final percent = c == null
        ? null
        : (c.abs() * 100).toStringAsFixed(c.abs() * 100 < 10 ? 1 : 0);
    final up = (c ?? 0) >= 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (percent != null)
                Icon(
                  up ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  size: 18,
                  color: AppColors.lime,
                ),
              Text(
                percent == null ? '—' : '$percent%',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.vsLastMonth,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
        ),
      ],
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
    final left = CurrencyFormatter.format(math.max(budget - spent, 0));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: math.min(spent / budget, 1.0),
            minHeight: 5,
            backgroundColor: Colors.white24,
            color: over ? const Color(0xFFFFB4A2) : AppColors.lime,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          over
              ? l10n.budgetOver(((spent - budget) / budget * 100).round())
              : l10n.budgetLeft(left, CurrencyFormatter.format(budget)),
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}

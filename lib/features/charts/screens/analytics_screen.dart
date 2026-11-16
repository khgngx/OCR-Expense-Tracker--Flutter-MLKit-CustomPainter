import 'package:material_ui/material_ui.dart';

import '../../../app_scope.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_style.dart';
import '../../../core/layout/breakpoints.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/receipts_refresh_mixin.dart';
import '../../../core/widgets/soft_card.dart';
import '../../../domain/models/category.dart';
import '../../../domain/usecases/get_month_summary_usecase.dart';
import '../../../domain/usecases/get_monthly_trend_usecase.dart';
import '../../../domain/usecases/get_weekly_spending_usecase.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/widgets/budget_dialog.dart';
import '../painters/bar_chart_painter.dart';
import '../painters/pie_chart_painter.dart';
import '../widgets/interactive_bar_chart.dart';

/// Analytics, laid out like the reference: back + title + calendar buttons, a
/// pill tab bar, then cards. Tabs: Spending, Trends, Budget, Merchants.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key, this.onBack});

  /// Called by the round back button (the shell returns to Home).
  final VoidCallback? onBack;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with ReceiptsRefreshMixin {
  DateTime _month = DateFormatter.startOfMonth(DateTime.now());
  int _tab = 0;
  MonthSummary? _summary;
  List<DaySpending> _week = const [];
  List<MonthSpending> _trend = const [];
  Object? _error;

  bool get _isCurrentMonth =>
      _month == DateFormatter.startOfMonth(DateTime.now());

  @override
  Future<void> reload() async {
    final deps = AppScope.of(context);
    final month = _month;
    // The 7-day chart ends today for the current month, else on the month's last day.
    final weekEnd = _isCurrentMonth
        ? DateTime.now()
        : DateTime(month.year, month.month + 1, 0);
    try {
      final summary = await deps.getMonthSummary(month);
      final week = await deps.getWeeklySpending(weekEnd);
      final trend = await deps.getMonthlyTrend(month);
      if (!mounted || month != _month) {
        return; // user moved to another month while loading
      }
      setState(() {
        _summary = summary;
        _week = week;
        _trend = trend;
        _error = null;
      });
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _error = e);
      }
    }
  }

  void _setMonth(DateTime day) {
    final month = DateFormatter.startOfMonth(day);
    if (month == _month) {
      return;
    }
    setState(() {
      _month = month;
      _summary = null;
    });
    reload();
  }

  Future<void> _pickFromCalendar() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _month,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _setMonth(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final summary = _summary;
    final text = Theme.of(context).textTheme;

    final Widget body;
    if (_error != null && summary == null) {
      body = Center(child: Text(l10n.loadFailed('$_error')));
    } else if (summary == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      final monthMenu = _MonthMenu(
        month: _month,
        onSelected: _setMonth,
        locale: locale,
      );
      final trendBars = [
        for (final m in _trend)
          BarDatum(
            label: DateFormatter.monthShort(m.month, locale),
            value: m.total,
          ),
      ];
      body = switch (_tab) {
        0 => _SpendingTab(
          summary: summary,
          monthMenu: monthMenu,
          trendBars: trendBars,
        ),
        1 => _TrendsTab(week: _week, trend: trendBars, locale: locale),
        2 => _BudgetTab(summary: summary, isCurrentMonth: _isCurrentMonth),
        _ => _MerchantsTab(summary: summary),
      };
    }

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                child: Row(
                  children: [
                    _RoundButton(
                      icon: Icons.chevron_left,
                      tooltip: l10n.back,
                      filled: true,
                      onPressed: widget.onBack,
                    ),
                    Expanded(
                      child: Text(
                        l10n.analyticsTitle,
                        textAlign: TextAlign.center,
                        style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _RoundButton(
                      icon: Icons.calendar_today_outlined,
                      tooltip: l10n.selectMonth,
                      onPressed: _pickFromCalendar,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _Tabs(
                  labels: [
                    l10n.tabSpending,
                    l10n.tabTrends,
                    l10n.tabBudget,
                    l10n.tabMerchants,
                  ],
                  selected: _tab,
                  onSelected: (i) => setState(() => _tab = i),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  /// Beige fill (back button) versus white with a hairline (calendar).
  final bool filled;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: filled ? AppColors.tile : AppColors.surface,
      shape: CircleBorder(
        side: filled
            ? BorderSide.none
            : const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(width: 40, height: 40, child: Icon(icon, size: 21)),
      ),
    ),
  );
}

/// Pill tab bar: tabs are as wide as their labels and spread across the bar.
class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFE9ECE4),
      borderRadius: BorderRadius.circular(24),
    ),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 320),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < labels.length; i++)
              GestureDetector(
                onTap: () => onSelected(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: i == selected ? 18 : 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: i == selected
                        ? AppColors.forest
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      color: i == selected ? Colors.white : AppColors.ink,
                      fontWeight: i == selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

/// "Aug 2026 ▾" dropdown listing the last 12 months.
class _MonthMenu extends StatelessWidget {
  const _MonthMenu({
    required this.month,
    required this.onSelected,
    required this.locale,
  });

  final DateTime month;
  final ValueChanged<DateTime> onSelected;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final now = DateFormatter.startOfMonth(DateTime.now());
    final options = [
      for (var i = 0; i < 12; i++) DateTime(now.year, now.month - i),
    ];
    return PopupMenuButton<DateTime>(
      tooltip: AppLocalizations.of(context).selectMonth,
      initialValue: month,
      onSelected: onSelected,
      itemBuilder: (_) => [
        for (final m in options)
          PopupMenuItem(
            value: m,
            child: Text(DateFormatter.monthYear(m, locale)),
          ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormatter.monthYear(month, locale),
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: AppColors.muted),
          ),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }
}

class _SpendingTab extends StatelessWidget {
  const _SpendingTab({
    required this.summary,
    required this.monthMenu,
    required this.trendBars,
  });

  final MonthSummary summary;
  final Widget monthMenu;
  final List<BarDatum> trendBars;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final total = summary.total;
    final slices = [
      for (final c in Category.values)
        if ((summary.totalsByCategory[c] ?? 0) > 0)
          PieSlice(value: summary.totalsByCategory[c]!, color: c.color),
    ];

    final spendingCard = SoftCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.yourSpending,
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              monthMenu,
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: SizedBox(
              width: 172,
              height: 172,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, t, _) => CustomPaint(
                  painter: PieChartPainter(
                    slices: slices,
                    emptyColor: AppColors.mint,
                    progress: t,
                    holeFraction: 0.68,
                    roundedCaps: true,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 104,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              CurrencyFormatter.format(total)
                                  .replaceAll(' VND', ''),
                              style: text.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          l10n.totalSpent,
                          style: text.labelSmall?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (total <= 0)
            Center(
              child: Text(
                l10n.noSpending,
                style: text.bodyMedium?.copyWith(color: AppColors.muted),
              ),
            )
          else
            _Legend(totals: summary.totalsByCategory, total: total),
        ],
      ),
    );

    final trend = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.spendingTrend,
          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        InteractiveBarChart(
          key: ValueKey('trend-${trendBars.map((b) => b.value).join(',')}'),
          bars: trendBars,
          formatValue: CurrencyFormatter.format,
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= Breakpoints.dashboardTwoColumn;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        spendingCard,
                        const SizedBox(height: 14),
                        _InsightCard(total: total),
                      ],
                    ),
                  ),
                  const SizedBox(width: 28),
                  Expanded(child: trend),
                ],
              )
            else ...[
              spendingCard,
              const SizedBox(height: 14),
              _InsightCard(total: total),
              const SizedBox(height: 22),
              trend,
            ],
          ],
        );
      },
    );
  }
}

/// Two columns filled top to bottom (first half left, rest right): dot,
/// category, share of the month.
class _Legend extends StatelessWidget {
  const _Legend({required this.totals, required this.total});

  final Map<Category, double> totals;
  final double total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = [
      for (final c in Category.values)
        if ((totals[c] ?? 0) > 0) c,
    ];
    final rows = (entries.length + 1) ~/ 2;

    Widget cell(Category c) => Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: c.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            c.localizedLabel(l10n),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        Text(
          '${(totals[c]! / total * 100).round()}%',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
      ],
    );

    return Column(
      children: [
        for (var row = 0; row < rows; row++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Expanded(child: cell(entries[row])),
                const SizedBox(width: 22),
                Expanded(
                  child: row + rows < entries.length
                      ? cell(entries[row + rows])
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = AppScope.of(context).settings;
    final text = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final String title;
        final String hint;
        if (settings.hasBudget) {
          final budget = settings.monthlyBudget;
          final over = total > budget;
          final percent =
              ((over ? total - budget : budget - total) / budget * 100).round();
          title = over ? l10n.budgetOver(percent) : l10n.budgetUnder(percent);
          hint = over ? l10n.budgetOverHint : l10n.budgetUnderHint;
        } else {
          title = l10n.budgetSetTitle;
          hint = l10n.budgetSetHint;
        }
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => showBudgetDialog(context),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0E3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco, color: Color(0xFF4C9A6C), size: 34),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: text.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hint,
                        style: text.labelSmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TrendsTab extends StatelessWidget {
  const _TrendsTab({
    required this.week,
    required this.trend,
    required this.locale,
  });

  final List<DaySpending> week;
  final List<BarDatum> trend;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final weekBars = [
      for (final d in week)
        BarDatum(label: DateFormatter.weekday(d.day, locale), value: d.total),
    ];
    final weekTotal = week.fold<double>(0, (a, b) => a + b.total);

    Widget section(String title, Widget chart, {String? footer}) => SoftCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          chart,
          if (footer != null) ...[
            const SizedBox(height: 8),
            Text(
              footer,
              style: text.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ],
        ],
      ),
    );

    final weekCard = section(
      l10n.trendLast7,
      InteractiveBarChart(
        key: ValueKey('week-${weekBars.map((b) => b.value).join(',')}'),
        bars: weekBars,
        formatValue: CurrencyFormatter.format,
      ),
      footer: l10n.weekTotal(CurrencyFormatter.format(weekTotal)),
    );
    final monthCard = section(
      l10n.trendLast6Months,
      InteractiveBarChart(
        key: ValueKey('months-${trend.map((b) => b.value).join(',')}'),
        bars: trend,
        formatValue: CurrencyFormatter.format,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= Breakpoints.dashboardTwoColumn;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: monthCard),
                  const SizedBox(width: 24),
                  Expanded(child: weekCard),
                ],
              )
            else ...[
              monthCard,
              const SizedBox(height: 14),
              weekCard,
            ],
          ],
        );
      },
    );
  }
}

class _BudgetTab extends StatelessWidget {
  const _BudgetTab({required this.summary, required this.isCurrentMonth});

  final MonthSummary summary;
  final bool isCurrentMonth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = AppScope.of(context).settings;
    final text = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final spent = summary.total;
        final budget = settings.monthlyBudget;
        final Widget content;
        if (!settings.hasBudget) {
          content = Column(
            children: [
              const Icon(
                Icons.savings_outlined,
                size: 48,
                color: AppColors.forest,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.budgetSetTitle,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.budgetSetHint,
                style: text.bodyMedium?.copyWith(color: AppColors.muted),
              ),
            ],
          );
        } else {
          final used = (spent / budget).clamp(0.0, 1.0);
          final over = spent > budget;
          final now = DateTime.now();
          final daysLeft =
              DateTime(now.year, now.month + 1, 0).day - now.day + 1;
          final perDay = (budget - spent) / daysLeft;
          content = Column(
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CustomPaint(
                  painter: PieChartPainter(
                    slices: [
                      PieSlice(
                        value: used,
                        color: over ? AppColors.danger : AppColors.forest,
                      ),
                      PieSlice(value: 1 - used, color: AppColors.mint),
                    ],
                    emptyColor: AppColors.mint,
                    holeFraction: 0.72,
                    roundedCaps: used > 0 && used < 1,
                  ),
                  child: Center(
                    child: Text(
                      '${(spent / budget * 100).round()}%',
                      style: text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.budgetTabSpent(
                  CurrencyFormatter.format(spent),
                  CurrencyFormatter.format(budget),
                ),
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                over
                    ? l10n.budgetTabOver
                    : isCurrentMonth
                    ? l10n.budgetTabPerDay(
                        CurrencyFormatter.format(perDay),
                        daysLeft,
                      )
                    : l10n.budgetUnderHint,
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            SoftCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  content,
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => showBudgetDialog(context),
                    child: Text(
                      settings.hasBudget
                          ? l10n.budgetTabEdit
                          : l10n.budgetSetTitle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MerchantsTab extends StatelessWidget {
  const _MerchantsTab({required this.summary});

  final MonthSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final merchants = topMerchants(summary.receipts);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            l10n.topMerchants,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        if (merchants.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                l10n.noMerchants,
                style: text.bodyMedium?.copyWith(color: AppColors.muted),
              ),
            ),
          )
        else
          SoftCard(
            child: Column(
              children: [
                for (var i = 0; i < merchants.length; i++) ...[
                  if (i > 0) const Divider(indent: 68, endIndent: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: merchants[i].category.tileColor,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(
                            merchants[i].category.icon,
                            color: merchants[i].category.tileIconColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                merchants[i].name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                l10n.receiptCount(merchants[i].count),
                                style: text.bodySmall?.copyWith(
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(merchants[i].total),
                          style: text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

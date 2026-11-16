import 'package:material_ui/material_ui.dart';

import '../../../app_scope.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_style.dart';
import '../../../core/layout/breakpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/receipts_refresh_mixin.dart';
import '../../../domain/models/category.dart';
import '../../../domain/usecases/get_month_summary_usecase.dart';
import '../../../domain/usecases/get_monthly_trend_usecase.dart';
import '../../../domain/usecases/get_weekly_spending_usecase.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/widgets/budget_dialog.dart';
import '../painters/bar_chart_painter.dart';
import '../painters/pie_chart_painter.dart';
import '../widgets/interactive_bar_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

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
    final now = DateTime.now();
    // The 7-day chart ends today for the current month, else on the month's last day.
    final weekEnd = _isCurrentMonth
        ? now
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

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
      _summary = null;
    });
    reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final summary = _summary;
    final text = Theme.of(context).textTheme;

    Widget body;
    if (_error != null && summary == null) {
      body = Center(child: Text(l10n.loadFailed('$_error')));
    } else if (summary == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = _tab == 0
          ? _SpendingTab(summary: summary)
          : _TrendsTab(week: _week, trend: _trend, locale: locale);
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
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  l10n.analyticsTitle,
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _Tabs(
                      labels: [l10n.tabSpending, l10n.tabTrends],
                      selected: _tab,
                      onSelected: (i) => setState(() => _tab = i),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          tooltip: l10n.previousMonth,
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => _shiftMonth(-1),
                        ),
                        SizedBox(
                          width: 120,
                          child: Text(
                            DateFormatter.monthYear(_month, locale),
                            textAlign: TextAlign.center,
                            style: text.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.nextMonth,
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _isCurrentMonth
                              ? null
                              : () => _shiftMonth(1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pill-style segmented control from the reference's "Spending / Income / ..." row.
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
      color: AppColors.mint,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => onSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: i == selected ? AppColors.forest : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: i == selected ? Colors.white : AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _SpendingTab extends StatelessWidget {
  const _SpendingTab({required this.summary});

  final MonthSummary summary;

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

    final spendingCard = Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.yourSpending,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, t, _) => CustomPaint(
                    painter: PieChartPainter(
                      slices: slices,
                      emptyColor: AppColors.mint,
                      progress: t,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            CurrencyFormatter.format(total)
                                .replaceAll(' VND', ''),
                            style: text.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${l10n.totalSpent} · VND',
                            style: text.bodySmall?.copyWith(
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
            const SizedBox(height: 20),
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
      ),
    );

    final insight = _InsightCard(total: total);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= Breakpoints.dashboardTwoColumn;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: spendingCard),
                  const SizedBox(width: 24),
                  Expanded(flex: 2, child: insight),
                ],
              )
            else ...[
              spendingCard,
              const SizedBox(height: 16),
              insight,
            ],
          ],
        );
      },
    );
  }
}

/// Two-column legend: dot, category, share of the month.
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
    ]..sort((a, b) => totals[b]!.compareTo(totals[a]!));

    Widget cell(Category c) => Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: c.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            c.localizedLabel(l10n),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '${(totals[c]! / total * 100).round()}%',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );

    return Column(
      children: [
        for (var i = 0; i < entries.length; i += 2)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(child: cell(entries[i])),
                const SizedBox(width: 24),
                Expanded(
                  child: i + 1 < entries.length
                      ? cell(entries[i + 1])
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
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          onTap: () => showBudgetDialog(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco, color: AppColors.forest, size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hint,
                        style: text.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
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
  final List<MonthSpending> trend;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final weekBars = [
      for (final d in week)
        BarDatum(label: DateFormatter.weekday(d.day, locale), value: d.total),
    ];
    final monthBars = [
      for (final m in trend)
        BarDatum(
          label: DateFormatter.monthShort(m.month, locale),
          value: m.total,
        ),
    ];
    final weekTotal = week.fold<double>(0, (a, b) => a + b.total);

    Widget section(String title, Widget chart, {String? footer}) => Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
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
      ),
    );

    final weekCard = section(
      l10n.trendLast7,
      InteractiveBarChart(
        key: ValueKey(
          'week-${week.isEmpty ? 0 : week.last.day.millisecondsSinceEpoch}',
        ),
        bars: weekBars,
        formatValue: CurrencyFormatter.format,
      ),
      footer: l10n.weekTotal(CurrencyFormatter.format(weekTotal)),
    );
    final monthCard = section(
      l10n.trendLast6Months,
      InteractiveBarChart(
        key: ValueKey(
          'months-${trend.isEmpty ? 0 : trend.last.month.millisecondsSinceEpoch}',
        ),
        bars: monthBars,
        formatValue: CurrencyFormatter.format,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= Breakpoints.dashboardTwoColumn;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
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
              const SizedBox(height: 16),
              weekCard,
            ],
          ],
        );
      },
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app_scope.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/models/category.dart';
import '../../../domain/usecases/get_daily_summary_usecase.dart'
    show totalsByCategory;
import '../../../domain/usecases/get_weekly_spending_usecase.dart';
import '../painters/bar_chart_painter.dart';
import '../painters/pie_chart_painter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  StreamSubscription<void>? _sub;
  Map<Category, double> _monthTotals = const {};
  List<DaySpending> _week = const [];
  bool _loading = true;
  Object? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sub != null) return;
    _sub = AppScope.of(context).receiptRepository.changes
        .listen((_) => _load());
    _load();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final deps = AppScope.of(context);
    final now = DateTime.now();
    try {
      final month = await deps.receiptRepository.getBetween(
        DateTime(now.year, now.month),
        DateTime(now.year, now.month + 1),
      );
      final week = await deps.getWeeklySpending(now);
      if (!mounted) return;
      setState(() {
        _monthTotals = totalsByCategory(month);
        _week = week;
        _error = null;
        _loading = false;
      });
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Could not load data: $_error'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                Text('This month', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                _MonthPie(totals: _monthTotals),
                const SizedBox(height: 28),
                Text('Last 7 days', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                _WeekBars(week: _week),
              ],
            ),
    );
  }
}

class _MonthPie extends StatelessWidget {
  const _MonthPie({required this.totals});

  final Map<Category, double> totals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sum = totals.values.fold<double>(0, (a, b) => a + b);
    final slices = [
      for (final c in Category.values)
        if ((totals[c] ?? 0) > 0)
          PieSlice(value: totals[c]!, color: AppColors.of(c)),
    ];
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, t, _) => CustomPaint(
              painter: PieChartPainter(
                slices: slices,
                emptyColor: theme.colorScheme.surfaceContainerHighest,
                progress: t,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Total', style: theme.textTheme.labelMedium),
                    Text(
                      CurrencyFormatter.format(sum),
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final c in Category.values)
          if ((totals[c] ?? 0) > 0)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 6,
                backgroundColor: AppColors.of(c),
              ),
              title: Text(c.label),
              trailing: Text(
                '${CurrencyFormatter.format(totals[c]!)} · ${(totals[c]! / sum * 100).round()}%',
              ),
            ),
        if (sum == 0)
          Text(
            'No spending recorded this month.',
            style: TextStyle(color: theme.colorScheme.outline),
          ),
      ],
    );
  }
}

class _WeekBars extends StatelessWidget {
  const _WeekBars({required this.week});

  final List<DaySpending> week;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bars = [
      for (final d in week)
        BarDatum(label: DateFormatter.weekday(d.day), value: d.total),
    ];
    final total = week.fold<double>(0, (a, b) => a + b.total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, t, _) => CustomPaint(
              size: Size.infinite,
              painter: BarChartPainter(
                bars: bars,
                barColor: theme.colorScheme.primary,
                gridColor: theme.colorScheme.outlineVariant,
                labelStyle: theme.textTheme.labelSmall!.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                progress: t,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Week total: ${CurrencyFormatter.format(total)}',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

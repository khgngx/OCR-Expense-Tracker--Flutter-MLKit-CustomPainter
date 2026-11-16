import 'package:material_ui/material_ui.dart';

import '../../../app_scope.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/date_labels.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/receipts_refresh_mixin.dart';
import '../../../l10n/app_localizations.dart';
import '../models/daily_bill_roll.dart';
import '../widgets/bill_stack_container.dart';

class DailyBillStackScreen extends StatefulWidget {
  const DailyBillStackScreen({super.key});

  @override
  State<DailyBillStackScreen> createState() => _DailyBillStackScreenState();
}

class _DailyBillStackScreenState extends State<DailyBillStackScreen>
    with ReceiptsRefreshMixin {
  DateTime _day = DateFormatter.startOfDay(DateTime.now());
  DailyBillRoll? _roll;
  Object? _error;

  @override
  Future<void> reload() async {
    final day = _day;
    try {
      final summary = await AppScope.of(context).getDailySummary(day);
      if (!mounted || day != _day) {
        return; // user changed day while loading
      }
      setState(() {
        _roll = DailyBillRoll(day: summary.day, receipts: summary.receipts);
        _error = null;
      });
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _error = e);
      }
    }
  }

  void _goTo(DateTime day) {
    setState(() {
      _day = DateFormatter.startOfDay(day);
      _roll = null;
    });
    reload();
  }

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _goTo(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final text = Theme.of(context).textTheme;
    final roll = _roll;
    final today = DateFormatter.startOfDay(DateTime.now());

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              l10n.billsTitle,
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: l10n.previousDay,
                icon: const Icon(Icons.chevron_left),
                onPressed: () =>
                    _goTo(DateTime(_day.year, _day.month, _day.day - 1)),
              ),
              TextButton(
                onPressed: _pickDay,
                child: Text(
                  '${relativeDayLabel(_day, l10n, locale)} · ${DateFormatter.date(_day)}',
                ),
              ),
              IconButton(
                tooltip: l10n.nextDay,
                icon: const Icon(Icons.chevron_right),
                onPressed: _day.isBefore(today)
                    ? () => _goTo(DateTime(_day.year, _day.month, _day.day + 1))
                    : null,
              ),
            ],
          ),
          Expanded(
            child: _error != null
                ? Center(child: Text(l10n.loadFailed('$_error')))
                : roll == null
                ? const Center(child: CircularProgressIndicator())
                : roll.receipts.isEmpty
                ? EmptyState(icon: Icons.layers_outlined, message: l10n.noBills)
                : BillStackContainer(receipts: roll.receipts),
          ),
          if (roll != null && roll.receipts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  Text(
                    l10n.billsCount(
                      roll.receipts.length,
                      CurrencyFormatter.format(roll.total),
                    ),
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.dragHint,
                    style: text.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

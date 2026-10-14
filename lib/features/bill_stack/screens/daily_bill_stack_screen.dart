import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app_scope.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../models/daily_bill_roll.dart';
import '../widgets/bill_stack_container.dart';

class DailyBillStackScreen extends StatefulWidget {
  const DailyBillStackScreen({super.key});

  @override
  State<DailyBillStackScreen> createState() => _DailyBillStackScreenState();
}

class _DailyBillStackScreenState extends State<DailyBillStackScreen> {
  StreamSubscription<void>? _sub;
  DateTime _day = DateFormatter.startOfDay(DateTime.now());
  DailyBillRoll? _roll;
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
    final day = _day;
    try {
      final summary = await AppScope.of(context).getDailySummary(day);
      if (!mounted || day != _day) return; // user changed day while loading
      setState(() {
        _roll = DailyBillRoll(day: summary.day, receipts: summary.receipts);
        _error = null;
      });
    } on Exception catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _shift(int days) {
    setState(() {
      _day = DateTime(_day.year, _day.month, _day.day + days);
      _roll = null;
    });
    _load();
  }

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      _day = DateFormatter.startOfDay(picked);
      _roll = null;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final roll = _roll;
    final today = DateFormatter.startOfDay(DateTime.now());
    return Scaffold(
      appBar: AppBar(title: const Text('Daily bills')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Previous day',
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _shift(-1),
              ),
              TextButton(
                onPressed: _pickDay,
                child: Text(DateFormatter.date(_day)),
              ),
              IconButton(
                tooltip: 'Next day',
                icon: const Icon(Icons.chevron_right),
                onPressed: _day.isBefore(today) ? () => _shift(1) : null,
              ),
            ],
          ),
          Expanded(
            child: _error != null
                ? Center(child: Text('Could not load bills: $_error'))
                : roll == null
                ? const Center(child: CircularProgressIndicator())
                : roll.receipts.isEmpty
                ? const EmptyState(
                    icon: Icons.layers_outlined,
                    message: 'No bills on this day.',
                  )
                : BillStackContainer(receipts: roll.receipts),
          ),
          if (roll != null && roll.receipts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              child: Column(
                children: [
                  Text(
                    '${roll.receipts.length} bills · ${CurrencyFormatter.format(roll.total)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Drag the top bill away to see the next',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

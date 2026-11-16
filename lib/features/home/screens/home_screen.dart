import 'package:material_ui/material_ui.dart';

import '../../../app_scope.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/receipts_refresh_mixin.dart';
import '../../../core/widgets/soft_card.dart';
import '../../../domain/models/receipt.dart';
import '../../../domain/usecases/get_month_summary_usecase.dart';
import '../../../l10n/app_localizations.dart';
import '../../alerts/screens/alerts_screen.dart';
import '../../camera_scan/flow/import_receipt_flow.dart';
import '../../camera_scan/screens/camera_scan_screen.dart';
import '../../receipt_review/screens/review_screen.dart';
import '../../transaction_list/screens/transaction_list_screen.dart';
import '../../transaction_list/widgets/transaction_tile.dart';
import '../widgets/more_sheet.dart';
import '../widgets/quick_actions.dart';
import '../widgets/summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with ReceiptsRefreshMixin {
  static const int _recentCount = 4;

  MonthSummary? _summary;
  List<Receipt> _recent = const [];
  Object? _error;

  @override
  Future<void> reload() async {
    final deps = AppScope.of(context);
    try {
      final summary = await deps.getMonthSummary(DateTime.now());
      final recent = await deps.receiptRepository.getAll(limit: _recentCount);
      if (!mounted) {
        return;
      }
      setState(() {
        _summary = summary;
        _recent = recent;
        _error = null;
      });
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _error = e);
      }
    }
  }

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return l10n.greetingMorning;
    }
    return hour < 18 ? l10n.greetingAfternoon : l10n.greetingEvening;
  }

  void _push(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = AppScope.of(context).settings;
    final summary = _summary;

    if (_error != null && summary == null) {
      return Center(child: Text(l10n.loadFailed('$_error')));
    }
    if (summary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final header = _Header(
      greeting: _greeting(l10n),
      onSearch: () => _push(const TransactionListScreen(autofocusSearch: true)),
      onAlerts: () => _push(const AlertsScreen()),
    );
    final summaryCard = ListenableBuilder(
      listenable: settings,
      builder: (context, _) =>
          SummaryCard(summary: summary, budget: settings.monthlyBudget),
    );
    final actions = QuickActions(
      actions: [
        QuickAction(
          icon: Icons.document_scanner_outlined,
          label: l10n.quickScan,
          onTap: () => openScanScreen(context),
        ),
        QuickAction(
          icon: Icons.add_photo_alternate_outlined,
          label: l10n.quickImport,
          onTap: () => importReceiptFlow(context),
        ),
        QuickAction(
          icon: Icons.add,
          label: l10n.quickAdd,
          onTap: () => _push(ReviewScreen.manual()),
        ),
        QuickAction(
          icon: Icons.more_horiz,
          label: l10n.quickMore,
          onTap: () => showMoreSheet(context),
        ),
      ],
    );
    final recent = _RecentSection(
      receipts: _recent,
      onSeeAll: () => _push(const TransactionListScreen()),
      onOpen: (r) => _push(ReviewScreen.edit(receipt: r)),
    );

    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                children: [
                  header,
                  const SizedBox(height: 18),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              summaryCard,
                              const SizedBox(height: 22),
                              actions,
                            ],
                          ),
                        ),
                        const SizedBox(width: 28),
                        Expanded(child: recent),
                      ],
                    )
                  else ...[
                    summaryCard,
                    const SizedBox(height: 22),
                    actions,
                    const SizedBox(height: 26),
                    recent,
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Avatar slot, greeting, and the search + bell pill on the right.
class _Header extends StatelessWidget {
  const _Header({
    required this.greeting,
    required this.onSearch,
    required this.onAlerts,
  });

  final String greeting;
  final VoidCallback onSearch;
  final VoidCallback onAlerts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.forest,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.eco, color: AppColors.lime, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                l10n.greetingSub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.labelSmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.tile,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: l10n.searchHint,
                onPressed: onSearch,
                icon: const Icon(Icons.search, size: 22),
              ),
              IconButton(
                tooltip: l10n.alertsTitle,
                onPressed: onAlerts,
                icon: const Icon(Icons.notifications_none_rounded, size: 22),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentSection extends StatelessWidget {
  const _RecentSection({
    required this.receipts,
    required this.onSeeAll,
    required this.onOpen,
  });

  final List<Receipt> receipts;
  final VoidCallback onSeeAll;
  final ValueChanged<Receipt> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final text = Theme.of(context).textTheme;
    final today = DateFormatter.startOfDay(DateTime.now());

    String caption(Receipt r) => DateFormatter.startOfDay(r.dateTime) == today
        ? l10n.today
        : DateFormatter.mediumDate(r.dateTime, locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.recentTransactions,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            InkWell(
              onTap: onSeeAll,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.seeAll,
                      style: text.labelMedium?.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: AppColors.muted,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (receipts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: EmptyState(
              icon: Icons.receipt_long_outlined,
              message: l10n.noReceipts,
            ),
          )
        else
          SoftCard(
            child: Column(
              children: [
                for (var i = 0; i < receipts.length; i++) ...[
                  if (i > 0) const Divider(indent: 68, endIndent: 14),
                  TransactionTile(
                    receipt: receipts[i],
                    onTap: () => onOpen(receipts[i]),
                    trailingCaption: caption(receipts[i]),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

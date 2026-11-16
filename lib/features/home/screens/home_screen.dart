import 'package:material_ui/material_ui.dart';

import '../../../app_scope.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/date_labels.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../core/widgets/receipts_refresh_mixin.dart';
import '../../../domain/models/receipt.dart';
import '../../../domain/usecases/get_month_summary_usecase.dart';
import '../../../l10n/app_localizations.dart';
import '../../camera_scan/flow/import_receipt_flow.dart';
import '../../camera_scan/screens/camera_scan_screen.dart';
import '../../receipt_review/screens/review_screen.dart';
import '../../settings/widgets/budget_dialog.dart';
import '../../transaction_list/screens/transaction_list_screen.dart';
import '../../transaction_list/widgets/transaction_tile.dart';
import '../widgets/quick_actions.dart';
import '../widgets/summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with ReceiptsRefreshMixin {
  static const int _recentCount = 5;

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

  void _openAll({bool focusSearch = false}) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => TransactionListScreen(autofocusSearch: focusSearch),
    ),
  );

  Future<void> _loadDemo() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final n = await AppScope.of(context).seedDemoData();
      messenger.showSnackBar(SnackBar(content: Text(l10n.demoLoaded(n))));
    } on Exception catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.demoFailed('$e'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = AppScope.of(context).settings;
    final text = Theme.of(context).textTheme;
    final summary = _summary;

    if (_error != null && summary == null) {
      return Center(child: Text(l10n.loadFailed('$_error')));
    }
    if (summary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final header = Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(l10n),
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                l10n.greetingSub,
                style: text.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        const LanguageToggle(),
        const SizedBox(width: 8),
        IconButton.filled(
          tooltip: l10n.searchHint,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.ink,
            side: const BorderSide(color: AppColors.line),
          ),
          onPressed: () => _openAll(focusSearch: true),
          icon: const Icon(Icons.search),
        ),
      ],
    );

    final summaryCard = ListenableBuilder(
      listenable: settings,
      builder: (context, _) => SummaryCard(
        summary: summary,
        budget: settings.monthlyBudget,
        onSetBudget: () => showBudgetDialog(context),
      ),
    );

    final actions = QuickActions(
      actions: [
        QuickAction(
          icon: Icons.document_scanner_outlined,
          label: l10n.quickScan,
          onTap: () => openScanScreen(context),
        ),
        QuickAction(
          icon: Icons.photo_library_outlined,
          label: l10n.quickImport,
          onTap: () => importReceiptFlow(context),
        ),
        QuickAction(
          icon: Icons.edit_note_outlined,
          label: l10n.quickAdd,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => ReviewScreen.manual()),
          ),
        ),
        QuickAction(
          icon: Icons.auto_awesome_outlined,
          label: l10n.quickDemo,
          onTap: _loadDemo,
        ),
      ],
    );

    final recent = _RecentSection(
      receipts: _recent,
      onSeeAll: _openAll,
      onOpen: (r) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ReviewScreen.edit(receipt: r)),
      ),
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  header,
                  const SizedBox(height: 20),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              summaryCard,
                              const SizedBox(height: 20),
                              actions,
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(child: recent),
                      ],
                    )
                  else ...[
                    summaryCard,
                    const SizedBox(height: 20),
                    actions,
                    const SizedBox(height: 24),
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
            TextButton(
              onPressed: onSeeAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.seeAll),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, size: 16),
                ],
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
          Card(
            child: Column(
              children: [
                for (var i = 0; i < receipts.length; i++) ...[
                  if (i > 0) const Divider(indent: 72),
                  TransactionTile(
                    receipt: receipts[i],
                    onTap: () => onOpen(receipts[i]),
                    trailingCaption: _caption(receipts[i], l10n, locale),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  String _caption(Receipt r, AppLocalizations l10n, String locale) {
    final label = relativeDayLabel(r.dateTime, l10n, locale);
    final sameYear = r.dateTime.year == DateTime.now().year;
    // Older than yesterday: show the real date instead of "Mon, 3 Nov".
    return label == l10n.today || label == l10n.yesterday
        ? label
        : (sameYear
              ? DateFormatter.dayHeader(r.dateTime, locale)
              : DateFormatter.date(r.dateTime));
  }
}

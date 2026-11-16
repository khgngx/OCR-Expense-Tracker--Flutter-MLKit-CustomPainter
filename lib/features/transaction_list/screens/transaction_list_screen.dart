import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../app_scope.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_style.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/date_labels.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/receipts_refresh_mixin.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/receipt.dart';
import '../../../domain/models/receipt_filter.dart';
import '../../../l10n/app_localizations.dart';
import '../../receipt_review/screens/review_screen.dart';
import '../widgets/transaction_tile.dart';

/// All receipts, newest first, grouped by day, with search and category filter.
class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key, this.autofocusSearch = false});

  final bool autofocusSearch;

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen>
    with ReceiptsRefreshMixin {
  static const int _pageSize = 50;
  static const Duration _searchDebounce = Duration(milliseconds: 250);

  final List<Receipt> _receipts = [];
  final ScrollController _scroll = ScrollController();
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;
  Category? _category;
  bool _loading = true;
  bool _hasMore = true;
  Object? _error;

  ReceiptFilter get _filter =>
      ReceiptFilter(query: _search.text, category: _category);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_hasMore && !_loading && _scroll.position.extentAfter < 300) {
      _loadMore();
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, reload);
  }

  void _selectCategory(Category? category) {
    setState(() => _category = category);
    reload();
  }

  @override
  Future<void> reload() async {
    final filter = _filter;
    try {
      final page = await AppScope.of(context).receiptRepository
          .search(filter, limit: _pageSize);
      if (!mounted ||
          filter.query != _filter.query ||
          filter.category != _filter.category) {
        return; // a newer search superseded this one
      }
      setState(() {
        _receipts
          ..clear()
          ..addAll(page);
        _hasMore = page.length == _pageSize;
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

  Future<void> _loadMore() async {
    setState(() => _loading = true);
    final filter = _filter;
    try {
      final page = await AppScope.of(context).receiptRepository
          .search(filter, limit: _pageSize, offset: _receipts.length);
      if (!mounted ||
          filter.query != _filter.query ||
          filter.category != _filter.category) {
        return;
      }
      setState(() {
        _receipts.addAll(page);
        _hasMore = page.length == _pageSize;
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

  /// Deletes right away and offers Undo; the thumbnail file is only removed
  /// once the snackbar closes without Undo, so Undo can restore everything.
  Future<void> _delete(Receipt r) async {
    final deps = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _receipts.removeWhere((x) => x.id == r.id));
    await deps.receiptRepository.delete(r.id);
    messenger.clearSnackBars();
    final reason = await messenger
        .showSnackBar(
          SnackBar(
            content: Text(l10n.deletedItem(r.merchantName)),
            action: SnackBarAction(
              label: l10n.undo,
              textColor: AppColors.lime,
              onPressed: () => deps.receiptRepository.save(r),
            ),
          ),
        )
        .closed;
    if (reason != SnackBarClosedReason.action) {
      await deps.imageStorage.delete(r.thumbnailPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.transactionsTitle)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: TextField(
                  controller: _search,
                  autofocus: widget.autofocusSearch,
                  onChanged: _onSearchChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _search.clear();
                              setState(() {});
                              reload();
                            },
                          ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              _CategoryChips(selected: _category, onSelected: _selectCategory),
              const SizedBox(height: 8),
              Expanded(child: _body(l10n)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(AppLocalizations l10n) {
    if (_loading && _receipts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _receipts.isEmpty) {
      return EmptyState(
        icon: Icons.error_outline,
        message: l10n.loadFailed('$_error'),
      );
    }
    if (_receipts.isEmpty) {
      return EmptyState(
        icon: _filter.isEmpty ? Icons.receipt_long_outlined : Icons.search_off,
        message: _filter.isEmpty ? l10n.noReceipts : l10n.noResults,
      );
    }
    final groups = _groupByDay(_receipts);
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      itemCount: groups.length,
      itemBuilder: (context, i) => _DayGroup(
        day: groups[i].$1,
        receipts: groups[i].$2,
        onDelete: _delete,
        onOpen: (r) => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ReviewScreen.edit(receipt: r),
          ),
        ),
      ),
    );
  }

  /// Receipts arrive newest first, so equal days are adjacent.
  List<(DateTime, List<Receipt>)> _groupByDay(List<Receipt> receipts) {
    final groups = <(DateTime, List<Receipt>)>[];
    for (final r in receipts) {
      final day = DateFormatter.startOfDay(r.dateTime);
      if (groups.isNotEmpty && groups.last.$1 == day) {
        groups.last.$2.add(r);
      } else {
        groups.add((day, [r]));
      }
    }
    return groups;
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelected});

  final Category? selected;
  final ValueChanged<Category?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget chip(String label, bool isSelected, VoidCallback onTap) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          chip(l10n.filterAll, selected == null, () => onSelected(null)),
          for (final c in Category.values)
            chip(
              c.localizedLabel(l10n),
              selected == c,
              () => onSelected(selected == c ? null : c),
            ),
        ],
      ),
    );
  }
}

class _DayGroup extends StatelessWidget {
  const _DayGroup({
    required this.day,
    required this.receipts,
    required this.onDelete,
    required this.onOpen,
  });

  final DateTime day;
  final List<Receipt> receipts;
  final ValueChanged<Receipt> onDelete;
  final ValueChanged<Receipt> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              relativeDayLabel(day, l10n, locale),
              style: text.labelLarge?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < receipts.length; i++) ...[
                  if (i > 0) const Divider(indent: 72),
                  Dismissible(
                    key: ValueKey(receipts[i].id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => onDelete(receipts[i]),
                    background: Container(
                      color: AppColors.danger,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                    ),
                    child: TransactionTile(
                      receipt: receipts[i],
                      onTap: () => onOpen(receipts[i]),
                      trailingCaption: DateFormatter.time(receipts[i].dateTime),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

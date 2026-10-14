import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app_scope.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../domain/models/receipt.dart';
import '../../receipt_review/screens/review_screen.dart';
import '../widgets/transaction_tile.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  static const int _pageSize = 50;

  final List<Receipt> _receipts = [];
  final ScrollController _scroll = ScrollController();
  StreamSubscription<void>? _sub;
  bool _loading = true;
  bool _hasMore = true;
  Object? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sub != null) return;
    final repo = AppScope.of(context).receiptRepository;
    _sub = repo.changes.listen((_) => _reload());
    _scroll.addListener(_onScroll);
    _reload();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_hasMore && !_loading && _scroll.position.extentAfter < 300) {
      _loadMore();
    }
  }

  Future<void> _reload() async {
    try {
      final page = await AppScope.of(context).receiptRepository
          .getAll(limit: _pageSize);
      if (!mounted) return;
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
    try {
      final page = await AppScope.of(context).receiptRepository
          .getAll(limit: _pageSize, offset: _receipts.length);
      if (!mounted) return;
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

  Future<bool> _confirmDelete(Receipt r) async {
    final deps = AppScope.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete receipt?'),
        content: Text('${r.merchantName} will be removed permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return false;
    await deps.receiptRepository.delete(r.id);
    await deps.imageStorage.delete(r.thumbnailPath);
    return true;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Transactions')),
    body: _body(),
  );

  Widget _body() {
    if (_loading && _receipts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _receipts.isEmpty) {
      return EmptyState(
        icon: Icons.error_outline,
        message: 'Could not load transactions: $_error',
      );
    }
    if (_receipts.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        message: 'No receipts yet. Tap Scan to add one.',
      );
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: _receipts.length,
      itemBuilder: (context, i) {
        final r = _receipts[i];
        return Dismissible(
          key: ValueKey(r.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmDelete(r),
          onDismissed: (_) =>
              setState(() => _receipts.removeWhere((x) => x.id == r.id)),
          background: Container(
            color: Theme.of(context).colorScheme.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: TransactionTile(
            receipt: r,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ReviewScreen.edit(receipt: r),
              ),
            ),
          ),
        );
      },
    );
  }
}

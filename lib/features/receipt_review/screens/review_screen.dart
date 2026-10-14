import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../../app_scope.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/parsed_receipt.dart';
import '../../../domain/models/receipt.dart';
import '../../../domain/models/receipt_line_item.dart';
import '../widgets/editable_field.dart';

/// Lets the user check and fix OCR output (new scan) or edit a saved receipt.
class ReviewScreen extends StatefulWidget {
  const ReviewScreen._({super.key, this.existing, this.parsed, this.image});

  factory ReviewScreen.fromScan({
    Key? key,
    required ParsedReceipt parsed,
    required File image,
  }) => ReviewScreen._(key: key, parsed: parsed, image: image);

  factory ReviewScreen.edit({Key? key, required Receipt receipt}) =>
      ReviewScreen._(key: key, existing: receipt);

  final Receipt? existing;
  final ParsedReceipt? parsed;
  final File? image;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _merchant;
  late final TextEditingController _total;
  late final TextEditingController _number;
  late DateTime _dateTime;
  late Category _category;
  late List<ReceiptLineItem> _items;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    final p = widget.parsed;
    _merchant = TextEditingController(
      text: e?.merchantName ?? p?.merchantName ?? '',
    );
    final total = e?.total ?? p?.total;
    _total = TextEditingController(
      text: total == null ? '' : total.round().toString(),
    );
    _number = TextEditingController(
      text: e?.receiptNumber ?? p?.receiptNumber ?? '',
    );
    _dateTime = e?.dateTime ?? p?.dateTime ?? DateTime.now();
    _category = e?.category ?? p?.category ?? Category.food;
    _items = List.of(e?.lineItems ?? p?.lineItems ?? const []);
  }

  @override
  void dispose() {
    _merchant.dispose();
    _total.dispose();
    _number.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (!mounted) return;
    setState(
      () => _dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _dateTime.hour,
        time?.minute ?? _dateTime.minute,
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final deps = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final existing = widget.existing;
      final id = existing?.id ?? const Uuid().v4();
      var thumbnail = existing?.thumbnailPath;
      final image = widget.image;
      if (image != null) {
        thumbnail = await deps.imageStorage.saveThumbnail(id, image);
      }

      final number = _number.text.trim();
      await deps.saveReceipt(
        Receipt(
          id: id,
          merchantName: _merchant.text.trim(),
          dateTime: _dateTime,
          total: CurrencyFormatter.parse(_total.text)!,
          category: _category,
          lineItems: _items.isEmpty ? null : _items,
          thumbnailPath: thumbnail,
          receiptNumber: number.isEmpty ? null : number,
          createdAt: existing?.createdAt ?? DateTime.now(),
        ),
      );
      navigator.popUntil((route) => route.isFirst);
    } on Exception catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not save: $e')));
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.image;
    final thumbnail = widget.existing?.thumbnailPath;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing == null ? 'Review receipt' : 'Edit receipt',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (image != null || thumbnail != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 160,
                  child: Image.file(
                    image ?? File(thumbnail!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox(),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            EditableField(
              controller: _merchant,
              label: 'Merchant',
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Enter the merchant name'
                  : null,
            ),
            const SizedBox(height: 12),
            EditableField(
              controller: _total,
              label: 'Total',
              suffixText: 'VND',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => CurrencyFormatter.parse(v ?? '') == null
                  ? 'Enter the total amount'
                  : null,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date & time',
                  border: OutlineInputBorder(),
                ),
                child: Text(DateFormatter.dateTime(_dateTime)),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Category>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final c in Category.values)
                  DropdownMenuItem(value: c, child: Text(c.label)),
              ],
              onChanged: (c) => setState(() => _category = c ?? _category),
            ),
            const SizedBox(height: 12),
            EditableField(
              controller: _number,
              label: 'Receipt number (optional)',
            ),
            if (_items.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('Items', style: Theme.of(context).textTheme.titleSmall),
              for (final (i, item) in _items.indexed)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.name),
                  subtitle: item.quantity > 1
                      ? Text('x${item.quantity}')
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(CurrencyFormatter.format(item.price)),
                      IconButton(
                        tooltip: 'Remove item',
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _items.removeAt(i)),
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../../app_scope.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_style.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/thumbnail_image.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/parsed_receipt.dart';
import '../../../domain/models/receipt.dart';
import '../../../domain/models/receipt_line_item.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/editable_field.dart';

/// One screen for three jobs: check a fresh scan, edit a saved receipt, or add
/// an expense by hand.
class ReviewScreen extends StatefulWidget {
  const ReviewScreen._({
    super.key,
    this.existing,
    this.parsed,
    this.imageBytes,
  });

  factory ReviewScreen.fromScan({
    Key? key,
    required ParsedReceipt parsed,
    required Uint8List imageBytes,
  }) => ReviewScreen._(key: key, parsed: parsed, imageBytes: imageBytes);

  factory ReviewScreen.edit({Key? key, required Receipt receipt}) =>
      ReviewScreen._(key: key, existing: receipt);

  factory ReviewScreen.manual({Key? key}) => ReviewScreen._(key: key);

  final Receipt? existing;
  final ParsedReceipt? parsed;
  final Uint8List? imageBytes;

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
  bool _submitted = false;

  bool get _isScan => widget.parsed != null;

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
    if (date == null || !mounted) {
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (!mounted) {
      return;
    }
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
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _saving = true);
    final deps = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final name = _merchant.text.trim();
    try {
      final existing = widget.existing;
      final id = existing?.id ?? const Uuid().v4();
      var thumbnail = existing?.thumbnailPath;
      final image = widget.imageBytes;
      if (image != null) {
        thumbnail = await deps.imageStorage.saveThumbnail(id, image);
      }

      final number = _number.text.trim();
      await deps.saveReceipt(
        Receipt(
          id: id,
          merchantName: name,
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
      messenger.showSnackBar(SnackBar(content: Text(l10n.savedItem(name))));
    } on Exception catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.saveFailed('$e'))));
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final image = widget.imageBytes;
    final thumbnail = widget.existing?.thumbnailPath;
    final autovalidate = _submitted
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled;
    final title = widget.existing != null
        ? l10n.editTitle
        : (_isScan ? l10n.reviewTitle : l10n.addTitle);
    final parsed = widget.parsed;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                if (image != null || thumbnail != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: image != null
                        ? Image.memory(
                            image,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          )
                        : ThumbnailImage(reference: thumbnail!),
                  ),
                  const SizedBox(height: 20),
                ],
                EditableField(
                  controller: _total,
                  label: l10n.fieldTotal,
                  suffixText: 'VND',
                  textStyle: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(
                      CurrencyFormatter.maxDigits,
                    ),
                  ],
                  autovalidateMode: autovalidate,
                  helperText: _isScan && parsed!.total == null
                      ? l10n.notDetected
                      : null,
                  validator: (v) => CurrencyFormatter.parse(v ?? '') == null
                      ? l10n.enterTotal
                      : null,
                ),
                const SizedBox(height: 14),
                EditableField(
                  controller: _merchant,
                  label: l10n.fieldMerchant,
                  autovalidateMode: autovalidate,
                  helperText: _isScan && parsed!.merchantName == null
                      ? l10n.notDetected
                      : null,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.enterMerchant
                      : null,
                ),
                const SizedBox(height: 14),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.fieldDate,
                      suffixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        size: 20,
                      ),
                    ),
                    child: Text(DateFormatter.dateTime(_dateTime)),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.fieldCategory,
                  style: text.labelLarge?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in Category.values)
                      ChoiceChip(
                        avatar: Icon(
                          c.icon,
                          size: 18,
                          color: c == _category
                              ? Colors.white
                              : AppColors.forest,
                        ),
                        label: Text(c.localizedLabel(l10n)),
                        selected: c == _category,
                        labelStyle: TextStyle(
                          color: c == _category ? Colors.white : AppColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) => setState(() => _category = c),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                EditableField(controller: _number, label: l10n.fieldReceiptNo),
                if (_items.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.items,
                    style: text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        for (final (i, item) in _items.indexed)
                          ListTile(
                            dense: true,
                            title: Text(item.name),
                            subtitle: item.quantity > 1
                                ? Text('x${item.quantity}')
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(CurrencyFormatter.format(item.price)),
                                IconButton(
                                  tooltip: l10n.removeItem,
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () =>
                                      setState(() => _items.removeAt(i)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n.save),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

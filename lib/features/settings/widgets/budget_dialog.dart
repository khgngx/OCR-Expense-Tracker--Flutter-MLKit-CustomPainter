import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app_scope.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';

/// Asks for the monthly budget (VND) and stores it in the settings.
Future<void> showBudgetDialog(BuildContext context) async {
  final settings = AppScope.of(context).settings;
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(
    text: settings.hasBudget ? settings.monthlyBudget.round().toString() : '',
  );
  final result = await showDialog<double?>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.budgetDialogTitle),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(CurrencyFormatter.maxDigits),
        ],
        decoration: const InputDecoration(suffixText: 'VND'),
        onSubmitted: (v) => Navigator.pop(ctx, CurrencyFormatter.parse(v) ?? 0),
      ),
      actions: [
        if (settings.hasBudget)
          TextButton(
            onPressed: () => Navigator.pop(ctx, 0.0),
            child: Text(l10n.budgetClear),
          ),
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(88, 44)),
          onPressed: () =>
              Navigator.pop(ctx, CurrencyFormatter.parse(controller.text) ?? 0),
          child: Text(l10n.save),
        ),
      ],
    ),
  );
  controller.dispose();
  if (result != null) {
    await settings.setMonthlyBudget(result);
  }
}

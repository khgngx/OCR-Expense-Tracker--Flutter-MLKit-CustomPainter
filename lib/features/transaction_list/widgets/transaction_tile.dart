import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_style.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/models/receipt.dart';
import '../../../l10n/app_localizations.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.receipt,
    required this.onTap,
    required this.trailingCaption,
  });

  final Receipt receipt;
  final VoidCallback onTap;

  /// Small text under the amount: "Today", a date, or a time inside day groups.
  final String trailingCaption;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final category = receipt.category;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: category.tileColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                category.icon,
                color: category.tileIconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receipt.merchantName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    category.localizedLabel(l10n),
                    style: text.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '- ${CurrencyFormatter.format(receipt.total)}',
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  trailingCaption,
                  style: text.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/models/receipt.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.receipt,
    required this.onTap,
  });

  final Receipt receipt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: CircleAvatar(
      backgroundColor: AppColors.of(receipt.category).withValues(alpha: 0.15),
      child: Icon(Icons.receipt_long, color: AppColors.of(receipt.category)),
    ),
    title: Text(
      receipt.merchantName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    subtitle: Text(
      '${receipt.category.label} · ${DateFormatter.dateTime(receipt.dateTime)}',
    ),
    trailing: Text(
      CurrencyFormatter.format(receipt.total),
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),
  );
}

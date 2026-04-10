import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/core/constants/app_constants.dart';
import 'package:amar_khoroch/core/utils/currency_formatter.dart';
import 'package:amar_khoroch/data/models/transaction_model.dart';
import 'package:amar_khoroch/data/models/category_model.dart';
import 'package:amar_khoroch/data/models/account_model.dart';

/// A single transaction item in the daily detail list.
class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final CategoryModel? category;
  final AccountModel? account;
  final AccountModel? toAccount;
  final bool isVisible;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.category,
    this.account,
    this.toAccount,
    this.isVisible = true,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final isTransfer = transaction.type == TransactionType.transfer;
    final color = isTransfer
        ? AppTheme.transferColor
        : (isIncome ? AppTheme.incomeColor : AppTheme.expenseColor);

    final iconData = category != null
        ? CategoryIcons.fromCodePoint(category!.iconCodePoint)
        : (isTransfer
            ? CupertinoIcons.arrow_right_arrow_left
            : CupertinoIcons.circle);

    final iconColor =
        category != null ? Color(category!.color) : color;

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.destructive.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        child: const Icon(
          CupertinoIcons.trash,
          color: AppTheme.destructive,
        ),
      ),
      confirmDismiss: (_) async {
        onDelete?.call();
        return false; // Dialog handles actual deletion
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: AppTheme.cardDecoration,
          child: Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, size: 22, color: iconColor),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTransfer
                          ? 'Transfer'
                          : (category?.name ?? 'Uncategorized'),
                      style: AppTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (transaction.note.isNotEmpty) ...[
                          Flexible(
                            child: Text(
                              transaction.note,
                              style: AppTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (account != null) ...[
                            Text(' · ', style: AppTheme.bodySmall),
                          ],
                        ],
                        if (isTransfer && account != null && toAccount != null)
                          Flexible(
                            child: Text(
                              '${account!.name} → ${toAccount!.name}',
                              style: AppTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else if (account != null)
                          Text(
                            account!.name,
                            style: AppTheme.bodySmall,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isVisible
                        ? CurrencyFormatter.format(transaction.amount)
                        : '৳ ••••',
                    style: AppTheme.amountMedium.copyWith(color: color),
                  ),
                  Text(
                    TransactionType.label(transaction.type),
                    style: AppTheme.caption.copyWith(
                      color: color,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

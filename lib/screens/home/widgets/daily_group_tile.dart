import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/core/utils/currency_formatter.dart';
import 'package:amar_khoroch/core/utils/app_date_utils.dart';
import 'package:amar_khoroch/core/constants/app_constants.dart';
import 'package:amar_khoroch/data/models/transaction_model.dart';
import 'package:amar_khoroch/data/models/category_model.dart';
import 'package:amar_khoroch/providers/category_provider.dart';
import 'package:amar_khoroch/providers/settings_provider.dart';
import 'package:amar_khoroch/screens/daily_detail/daily_detail_screen.dart';

/// A card representing one day's transaction group.
class DailyGroupTile extends ConsumerWidget {
  final DateTime date;
  final List<TransactionModel> transactions;

  const DailyGroupTile({
    super.key,
    required this.date,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(amountVisibilityProvider);
    final categories = ref.watch(categoryProvider);

    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final expense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => DailyDetailScreen(date: date),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: AppTheme.cardDecoration,
        child: Column(
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  // Date circle
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryAccentLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.primaryAccent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Date text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppDateUtils.formatRelativeDate(date),
                          style: AppTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  // Income total
                  if (income > 0) ...[
                    Text(
                      isVisible ? '+${CurrencyFormatter.format(income)}' : '৳ ••••',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.incomeColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Expense total
                  if (expense > 0)
                    Text(
                      isVisible ? '-${CurrencyFormatter.format(expense)}' : '৳ ••••',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.expenseColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(width: 4),
                  Icon(
                    CupertinoIcons.chevron_right,
                    size: 14,
                    color: AppTheme.textTertiary,
                  ),
                ],
              ),
            ),
            // Transaction preview (show first 3)
            if (transactions.isNotEmpty) ...[
              Divider(height: 1, color: AppTheme.separator.withValues(alpha: 0.5)),
              ...transactions.take(3).map((tx) =>
                  _TransactionPreviewItem(
                    transaction: tx,
                    categories: categories,
                    isVisible: isVisible,
                  )),
              if (transactions.length > 3)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: Text(
                    '+${transactions.length - 3} more',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.primaryAccent,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TransactionPreviewItem extends StatelessWidget {
  final TransactionModel transaction;
  final List<CategoryModel> categories;
  final bool isVisible;

  const _TransactionPreviewItem({
    required this.transaction,
    required this.categories,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    final category = transaction.categoryId != null
        ? categories
            .where((c) => c.id == transaction.categoryId)
            .firstOrNull
        : null;

    final isIncome = transaction.type == TransactionType.income;
    final isTransfer = transaction.type == TransactionType.transfer;
    final color = isTransfer
        ? AppTheme.transferColor
        : (isIncome ? AppTheme.incomeColor : AppTheme.expenseColor);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (category != null ? Color(category.color) : color)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              category != null
                  ? CategoryIcons.fromCodePoint(category.iconCodePoint)
                  : (isTransfer
                      ? CupertinoIcons.arrow_right_arrow_left
                      : CupertinoIcons.circle),
              size: 16,
              color: category != null ? Color(category.color) : color,
            ),
          ),
          const SizedBox(width: 10),
          // Category name / note
          Expanded(
            child: Text(
              isTransfer
                  ? 'Transfer'
                  : (category?.name ?? transaction.note),
              style: AppTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Amount
          Text(
            isVisible
                ? CurrencyFormatter.format(transaction.amount)
                : '৳ ••••',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

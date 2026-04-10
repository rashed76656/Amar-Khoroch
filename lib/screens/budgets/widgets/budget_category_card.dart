import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/core/constants/app_constants.dart';
import 'package:amar_khoroch/core/utils/currency_formatter.dart';
import 'package:amar_khoroch/providers/budget_provider.dart';

/// A card showing a single budgeted category's progress.
class BudgetCategoryCard extends StatelessWidget {
  final BudgetCategorySummary summary;
  final bool isVisible;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BudgetCategoryCard({
    super.key,
    required this.summary,
    required this.isVisible,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final category = summary.category;
    final catColor = Color(category.color);
    final progressColor = summary.exceeded ? AppTheme.expenseColor : AppTheme.incomeColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon + name + menu
          Row(
            children: [
              // Category icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CategoryIcons.fromCodePoint(category.iconCodePoint),
                  size: 20,
                  color: catColor,
                ),
              ),
              const SizedBox(width: 12),
              // Category name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.name, style: AppTheme.titleMedium),
                    if (summary.budget.note.isNotEmpty)
                      Text(
                        summary.budget.note,
                        style: AppTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // 3-dot menu
              _buildPopupMenu(context),
            ],
          ),
          const SizedBox(height: 14),

          // Amounts row
          Row(
            children: [
              // Limit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Limit', style: AppTheme.caption),
                    const SizedBox(height: 2),
                    Text(
                      isVisible
                          ? CurrencyFormatter.format(summary.budget.amount)
                          : CurrencyFormatter.hidden,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Spent
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Spent', style: AppTheme.caption),
                    const SizedBox(height: 2),
                    Text(
                      isVisible
                          ? CurrencyFormatter.format(summary.spent)
                          : CurrencyFormatter.hidden,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: summary.exceeded
                            ? AppTheme.expenseColor
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Remaining
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      summary.exceeded ? 'Exceeded' : 'Remaining',
                      style: AppTheme.caption,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isVisible
                          ? (summary.exceeded
                              ? CurrencyFormatter.format(summary.exceededBy)
                              : CurrencyFormatter.format(summary.remaining))
                          : CurrencyFormatter.hidden,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: summary.exceeded
                            ? AppTheme.expenseColor
                            : AppTheme.incomeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: summary.progress),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 7,
                  backgroundColor: AppTheme.separator.withValues(alpha: 0.4),
                  valueColor: AlwaysStoppedAnimation(progressColor),
                );
              },
            ),
          ),

          // Exceeded warning
          if (summary.exceeded) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  size: 12,
                  color: AppTheme.expenseColor,
                ),
                const SizedBox(width: 4),
                Text(
                  isVisible
                      ? 'Exceeded by ${CurrencyFormatter.format(summary.exceededBy)}'
                      : 'Budget exceeded',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.expenseColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        final overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;
        showMenu(
          context: context,
          position: RelativeRect.fromRect(
            details.globalPosition & const Size(40, 40),
            Offset.zero & overlay.size,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: AppTheme.cardBackground,
          elevation: 8,
          items: [
            PopupMenuItem(
              onTap: onEdit,
              child: Row(
                children: [
                  Icon(CupertinoIcons.pencil,
                      size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 10),
                  Text('Edit Budget', style: AppTheme.bodyMedium),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: onDelete,
              child: Row(
                children: [
                  Icon(CupertinoIcons.trash,
                      size: 16, color: AppTheme.destructive),
                  const SizedBox(width: 10),
                  Text('Delete Budget',
                      style: AppTheme.bodyMedium
                          .copyWith(color: AppTheme.destructive)),
                ],
              ),
            ),
          ],
        );
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          CupertinoIcons.ellipsis,
          size: 16,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}

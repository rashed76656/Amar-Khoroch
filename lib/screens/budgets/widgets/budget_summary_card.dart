import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/core/utils/currency_formatter.dart';

/// Top summary card showing total budget vs total spent with animated progress.
class BudgetSummaryCard extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;
  final bool isVisible;

  const BudgetSummaryCard({
    super.key,
    required this.totalBudget,
    required this.totalSpent,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (totalBudget - totalSpent).clamp(0.0, double.infinity);
    final exceeded = totalSpent > totalBudget;
    final exceededBy = exceeded ? totalSpent - totalBudget : 0.0;
    final progress = totalBudget > 0
        ? (totalSpent / totalBudget).clamp(0.0, 1.0)
        : 0.0;
    final progressColor = exceeded ? AppTheme.expenseColor : AppTheme.incomeColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.elevatedCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryAccentLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CupertinoIcons.chart_bar_alt_fill,
                  size: 18,
                  color: AppTheme.primaryAccent,
                ),
              ),
              const SizedBox(width: 12),
              Text('Monthly Overview', style: AppTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 20),

          // Budget / Spent row
          Row(
            children: [
              Expanded(
                child: _StatColumn(
                  label: 'Total Budget',
                  amount: totalBudget,
                  color: AppTheme.textPrimary,
                  isVisible: isVisible,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: AppTheme.separator,
              ),
              Expanded(
                child: _StatColumn(
                  label: 'Total Spent',
                  amount: totalSpent,
                  color: AppTheme.expenseColor,
                  isVisible: isVisible,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: AppTheme.separator.withValues(alpha: 0.5),
                  valueColor: AlwaysStoppedAnimation(progressColor),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Remaining / Exceeded text
          if (exceeded)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  size: 14,
                  color: AppTheme.expenseColor,
                ),
                const SizedBox(width: 6),
                Text(
                  isVisible
                      ? 'Exceeded by ${CurrencyFormatter.format(exceededBy)}'
                      : 'Budget exceeded',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.expenseColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          else
            Center(
              child: Text(
                isVisible
                    ? '${CurrencyFormatter.format(remaining)} remaining'
                    : 'Within budget',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.incomeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isVisible;

  const _StatColumn({
    required this.label,
    required this.amount,
    required this.color,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTheme.caption),
        const SizedBox(height: 4),
        Text(
          isVisible ? CurrencyFormatter.format(amount) : CurrencyFormatter.hidden,
          style: AppTheme.amountMedium.copyWith(color: color),
        ),
      ],
    );
  }
}

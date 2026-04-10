import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/core/utils/currency_formatter.dart';

/// A single row in the category breakdown list.
class CategoryBreakdownItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final double amount;
  final double percentage;
  final bool isVisible;

  const CategoryBreakdownItem({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.amount,
    required this.percentage,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              // Name + percentage
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: AppTheme.bodySmall.copyWith(color: color),
                    ),
                  ],
                ),
              ),
              // Amount
              Text(
                isVisible
                    ? CurrencyFormatter.format(amount)
                    : '৳ ••••',
                style: AppTheme.amountMedium.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              backgroundColor: color.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

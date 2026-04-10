import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/core/constants/app_constants.dart';
import 'package:amar_khoroch/data/models/category_model.dart';

/// Section showing categories that don't have a budget set for the current month.
class UnbudgetedSection extends StatelessWidget {
  final List<CategoryModel> categories;
  final Function(CategoryModel) onSetBudget;

  const UnbudgetedSection({
    super.key,
    required this.categories,
    required this.onSetBudget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            'Not Budgeted',
            style: AppTheme.titleMedium,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: AppTheme.cardDecoration,
          child: Column(
            children: categories.map((cat) {
              final isLast = cat == categories.last;
              return Column(
                children: [
                  _UnbudgetedRow(
                    category: cat,
                    onSetBudget: () => onSetBudget(cat),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 64,
                      color: AppTheme.separator.withValues(alpha: 0.5),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _UnbudgetedRow extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onSetBudget;

  const _UnbudgetedRow({
    required this.category,
    required this.onSetBudget,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = Color(category.color);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              CategoryIcons.fromCodePoint(category.iconCodePoint),
              size: 18,
              color: catColor,
            ),
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: Text(category.name, style: AppTheme.bodyMedium),
          ),
          // Button
          GestureDetector(
            onTap: onSetBudget,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccentLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Set Budget',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.primaryAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

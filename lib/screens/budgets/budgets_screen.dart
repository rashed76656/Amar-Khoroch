import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/providers/budget_provider.dart';
import 'package:amar_khoroch/providers/category_provider.dart';
import 'package:amar_khoroch/providers/settings_provider.dart';
import 'package:amar_khoroch/providers/transaction_provider.dart';
import 'package:amar_khoroch/screens/home/widgets/month_selector.dart';
import 'package:amar_khoroch/screens/budgets/widgets/budget_summary_card.dart';
import 'package:amar_khoroch/screens/budgets/widgets/budget_category_card.dart';
import 'package:amar_khoroch/screens/budgets/widgets/unbudgeted_section.dart';
import 'package:amar_khoroch/screens/budgets/widgets/budget_form.dart';
import 'package:amar_khoroch/widgets/empty_state.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(budgetSummaryProvider);
    final unbudgeted = ref.watch(unbodgetedCategoriesProvider);
    final isVisible = ref.watch(amountVisibilityProvider);
    final totalLimit = ref.watch(totalBudgetLimitProvider);
    final totalSpent = ref.watch(totalBudgetSpentProvider);

    final hasAnyBudget = summaries.isNotEmpty;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text('Budgets', style: AppTheme.headlineLarge),
            ),
          ),

          // Month selector
          const SliverToBoxAdapter(child: MonthSelector()),

          // Summary card
          if (hasAnyBudget) ...[
            SliverToBoxAdapter(
              child: BudgetSummaryCard(
                totalBudget: totalLimit,
                totalSpent: totalSpent,
                isVisible: isVisible,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Budgeted categories header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Row(
                  children: [
                    Text(
                      'Budgeted Categories',
                      style: AppTheme.titleMedium,
                    ),
                    const Spacer(),
                    Text(
                      '${summaries.length} categories',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

            // Budget cards
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final summary = summaries[index];
                  return BudgetCategoryCard(
                    summary: summary,
                    isVisible: isVisible,
                    onEdit: () => _editBudget(context, ref, summary),
                    onDelete: () => _deleteBudget(context, ref, summary),
                  );
                },
                childCount: summaries.length,
              ),
            ),
          ],

          // Empty state when no budgets at all
          if (!hasAnyBudget && unbudgeted.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: CupertinoIcons.chart_bar_alt_fill,
                title: 'No budgets set',
                subtitle: 'Create expense categories first, then set budgets to track spending',
              ),
            ),

          if (!hasAnyBudget && unbudgeted.isNotEmpty)
            SliverToBoxAdapter(
              child: EmptyState(
                icon: CupertinoIcons.chart_bar_alt_fill,
                title: 'No budgets set',
                subtitle: 'Set your first budget to start tracking spending',
              ),
            ),

          // Unbudgeted section
          if (unbudgeted.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: UnbudgetedSection(
                categories: unbudgeted,
                onSetBudget: (category) =>
                    _addBudgetForCategory(context, ref, category.id),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  void _addBudgetForCategory(
      BuildContext context, WidgetRef ref, String categoryId) {
    final month = ref.read(selectedMonthProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BudgetForm(
        preselectedCategoryId: categoryId,
        month: month.month,
        year: month.year,
        onSave: (budget) {
          ref.read(budgetNotifierProvider.notifier).add(budget);
        },
      ),
    );
  }

  void _editBudget(
      BuildContext context, WidgetRef ref, BudgetCategorySummary summary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BudgetForm(
        editBudget: summary.budget,
        preselectedCategoryId: summary.budget.categoryId,
        month: summary.budget.month,
        year: summary.budget.year,
        onSave: (budget) {
          ref.read(budgetNotifierProvider.notifier).update(budget);
        },
      ),
    );
  }

  void _deleteBudget(
      BuildContext context, WidgetRef ref, BudgetCategorySummary summary) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Budget'),
        content: Text(
          'Remove the budget for "${summary.category.name}"? Your transactions won\'t be affected.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              ref
                  .read(budgetNotifierProvider.notifier)
                  .delete(summary.budget.id);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

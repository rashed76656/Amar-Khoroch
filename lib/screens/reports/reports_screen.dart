import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/core/constants/app_constants.dart';
import 'package:amar_khoroch/data/models/category_model.dart';
import 'package:amar_khoroch/providers/transaction_provider.dart';
import 'package:amar_khoroch/providers/category_provider.dart';
import 'package:amar_khoroch/providers/settings_provider.dart';
import 'package:amar_khoroch/screens/home/widgets/month_selector.dart';
import 'package:amar_khoroch/screens/reports/widgets/donut_chart.dart';
import 'package:amar_khoroch/screens/reports/widgets/category_breakdown_item.dart';
import 'package:amar_khoroch/widgets/empty_state.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int _selectedType = TransactionType.expense; // 0=income, 1=expense

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(monthlyTransactionsProvider);
    final categories = ref.watch(categoryProvider);
    final isVisible = ref.watch(amountVisibilityProvider);

    // Filter by selected type
    final filtered =
        transactions.where((t) => t.type == _selectedType).toList();

    // Group by category
    final Map<String, double> categoryAmounts = {};
    for (final tx in filtered) {
      if (tx.categoryId != null) {
        categoryAmounts[tx.categoryId!] =
            (categoryAmounts[tx.categoryId!] ?? 0) + tx.amount;
      }
    }

    final total = categoryAmounts.values.fold(0.0, (sum, v) => sum + v);

    // Build chart data
    final List<ChartCategoryData> chartData = [];
    final List<_BreakdownData> breakdownList = [];

    categoryAmounts.forEach((catId, amount) {
      final cat = categories.where((c) => c.id == catId).firstOrNull;
      if (cat != null) {
        final pct = total > 0 ? (amount / total * 100) : 0.0;
        chartData.add(ChartCategoryData(
          name: cat.name,
          amount: amount,
          color: Color(cat.color),
          percentage: pct,
        ));
        breakdownList.add(_BreakdownData(
          category: cat,
          amount: amount,
          percentage: pct,
        ));
      }
    });

    // Sort breakdown by amount descending
    breakdownList.sort((a, b) => b.amount.compareTo(a.amount));
    chartData.sort((a, b) => b.amount.compareTo(a.amount));

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text('Reports', style: AppTheme.headlineLarge),
            ),
          ),
          const SliverToBoxAdapter(child: MonthSelector()),
          // Type toggle
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppTheme.cardShadow,
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _ToggleTab(
                      label: 'Income',
                      color: AppTheme.incomeColor,
                      isSelected: _selectedType == TransactionType.income,
                      onTap: () =>
                          setState(() => _selectedType = TransactionType.income),
                    ),
                    _ToggleTab(
                      label: 'Expense',
                      color: AppTheme.expenseColor,
                      isSelected: _selectedType == TransactionType.expense,
                      onTap: () => setState(
                          () => _selectedType = TransactionType.expense),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: CupertinoIcons.chart_pie,
                title: 'No ${_selectedType == TransactionType.income ? 'income' : 'expense'} data',
                subtitle: 'Add transactions to see reports',
              ),
            )
          else ...[
            // Donut chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: DonutChart(
                  data: chartData,
                  total: total,
                  isVisible: isVisible,
                ),
              ),
            ),
            // Category breakdown
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  'Category Breakdown',
                  style: AppTheme.titleMedium,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == breakdownList.length) {
                    return const SizedBox(height: 16);
                  }
                  final item = breakdownList[index];
                  return CategoryBreakdownItem(
                    name: item.category.name,
                    icon: CategoryIcons.fromCodePoint(
                      item.category.iconCodePoint,
                    ),
                    color: Color(item.category.color),
                    amount: item.amount,
                    percentage: item.percentage,
                    isVisible: isVisible,
                  );
                },
                childCount: breakdownList.length + 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BreakdownData {
  final CategoryModel category;
  final double amount;
  final double percentage;

  _BreakdownData({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? color : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

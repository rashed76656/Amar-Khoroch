import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/data/hive/hive_init.dart';
import 'package:amar_khoroch/data/models/budget_model.dart';
import 'package:amar_khoroch/data/models/category_model.dart';
import 'package:amar_khoroch/data/repositories/budget_repository.dart';
import 'package:amar_khoroch/providers/transaction_provider.dart';
import 'package:amar_khoroch/providers/category_provider.dart';
import 'package:amar_khoroch/core/constants/app_constants.dart';
import 'package:amar_khoroch/providers/workspace_provider.dart';

/// Repository provider.
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(HiveBoxes.budgets);
});

/// Raw budget notifier.
final budgetNotifierProvider =
    StateNotifierProvider<BudgetNotifier, List<BudgetModel>>((ref) {
  final repo = ref.read(budgetRepositoryProvider);
  return BudgetNotifier(repo);
});

/// All budgets for active workspace.
final allBudgetsProvider = Provider<List<BudgetModel>>((ref) {
  final all = ref.watch(budgetNotifierProvider);
  final activeWorkspaceId = ref.watch(activeWorkspaceIdProvider);
  if (activeWorkspaceId == null) return [];
  return all.where((b) => b.workspaceId == activeWorkspaceId).toList();
});

/// Budgets for the selected month.
final monthlyBudgetsProvider = Provider<List<BudgetModel>>((ref) {
  final all = ref.watch(allBudgetsProvider);
  final month = ref.watch(selectedMonthProvider);
  return all
      .where((b) => b.year == month.year && b.month == month.month)
      .toList();
});

/// Computed budget data for the selected month.
/// Each entry contains the budget, its category, spent amount, and remaining.
final budgetSummaryProvider = Provider<List<BudgetCategorySummary>>((ref) {
  final budgets = ref.watch(monthlyBudgetsProvider);
  final transactions = ref.watch(monthlyTransactionsProvider);
  final categories = ref.watch(categoryProvider);

  final List<BudgetCategorySummary> summaries = [];

  for (final budget in budgets) {
    // Find the category
    final cat = categories.where((c) => c.id == budget.categoryId).firstOrNull;
    if (cat == null) continue;

    // Calculate spent: sum of expense transactions for this category in the month
    final spent = transactions
        .where(
            (t) => t.type == TransactionType.expense && t.categoryId == budget.categoryId)
        .fold(0.0, (sum, t) => sum + t.amount);

    final remaining = (budget.amount - spent).clamp(0.0, double.infinity);
    final exceeded = spent > budget.amount;
    final exceededBy = exceeded ? spent - budget.amount : 0.0;
    final progress = budget.amount > 0 ? (spent / budget.amount).clamp(0.0, 1.0) : 0.0;

    summaries.add(BudgetCategorySummary(
      budget: budget,
      category: cat,
      spent: spent,
      remaining: remaining,
      exceeded: exceeded,
      exceededBy: exceededBy,
      progress: progress,
    ));
  }

  // Sort by category sort order
  summaries.sort((a, b) => a.category.sortOrder.compareTo(b.category.sortOrder));

  return summaries;
});

/// Expense categories that do NOT have a budget for the selected month.
final unbodgetedCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  final expenseCategories = ref.watch(expenseCategoriesProvider);
  final budgets = ref.watch(monthlyBudgetsProvider);

  final budgetedCategoryIds = budgets.map((b) => b.categoryId).toSet();

  return expenseCategories
      .where((c) => !budgetedCategoryIds.contains(c.id))
      .toList();
});

/// Total budget limit for the selected month.
final totalBudgetLimitProvider = Provider<double>((ref) {
  final summaries = ref.watch(budgetSummaryProvider);
  return summaries.fold(0.0, (sum, s) => sum + s.budget.amount);
});

/// Total spent across all budgeted categories for the selected month.
final totalBudgetSpentProvider = Provider<double>((ref) {
  final summaries = ref.watch(budgetSummaryProvider);
  return summaries.fold(0.0, (sum, s) => sum + s.spent);
});

class BudgetNotifier extends StateNotifier<List<BudgetModel>> {
  final BudgetRepository _repo;

  BudgetNotifier(this._repo) : super([]) {
    _load();
  }

  void _load() {
    state = _repo.getAll();
  }

  Future<void> add(BudgetModel budget) async {
    await _repo.add(budget);
    _load();
  }

  Future<void> update(BudgetModel budget) async {
    await _repo.update(budget);
    _load();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    _load();
  }

  /// Check if a budget already exists for this category/month.
  bool exists(String categoryId, int year, int month, {String? excludeId}) {
    return state.any((b) =>
        b.categoryId == categoryId &&
        b.year == year &&
        b.month == month &&
        b.id != excludeId);
  }

  void refresh() => _load();
}

/// Data class holding computed budget info for display.
class BudgetCategorySummary {
  final BudgetModel budget;
  final CategoryModel category;
  final double spent;
  final double remaining;
  final bool exceeded;
  final double exceededBy;
  final double progress;

  BudgetCategorySummary({
    required this.budget,
    required this.category,
    required this.spent,
    required this.remaining,
    required this.exceeded,
    required this.exceededBy,
    required this.progress,
  });
}

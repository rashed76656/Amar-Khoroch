import 'package:hive/hive.dart';
import 'package:amar_khoroch/data/models/budget_model.dart';

class BudgetRepository {
  final Box _box;

  BudgetRepository(this._box);

  /// Get all budgets.
  List<BudgetModel> getAll() {
    return _box.values.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return BudgetModel.fromJson(map);
    }).toList();
  }

  /// Get budgets for a specific month/year.
  List<BudgetModel> getByMonth(int year, int month) {
    return getAll()
        .where((b) => b.year == year && b.month == month)
        .toList();
  }

  /// Get a budget for a specific category in a specific month.
  BudgetModel? getByCategoryAndMonth(String categoryId, int year, int month) {
    final budgets = getByMonth(year, month);
    final matches = budgets.where((b) => b.categoryId == categoryId);
    return matches.isNotEmpty ? matches.first : null;
  }

  /// Get a single budget by ID.
  BudgetModel? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    return BudgetModel.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  /// Add a new budget.
  Future<void> add(BudgetModel budget) async {
    await _box.put(budget.id, budget.toJson());
  }

  /// Update an existing budget.
  Future<void> update(BudgetModel budget) async {
    await _box.put(budget.id, budget.toJson());
  }

  /// Delete a budget by ID.
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Delete all budgets.
  Future<void> deleteAll() async {
    await _box.clear();
  }
}

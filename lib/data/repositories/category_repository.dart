import 'package:hive/hive.dart';
import 'package:amar_khoroch/data/models/category_model.dart';

class CategoryRepository {
  final Box _box;

  CategoryRepository(this._box);

  /// Get all categories, sorted by sortOrder.
  List<CategoryModel> getAll() {
    return _box.values.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return CategoryModel.fromJson(map);
    }).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Get categories filtered by type (income=0, expense=1).
  List<CategoryModel> getByType(int type) {
    return getAll().where((c) => c.type == type).toList();
  }

  /// Get a single category by ID.
  CategoryModel? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    return CategoryModel.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  /// Add a new category.
  Future<void> add(CategoryModel category) async {
    await _box.put(category.id, category.toJson());
  }

  /// Update an existing category.
  Future<void> update(CategoryModel category) async {
    await _box.put(category.id, category.toJson());
  }

  /// Delete a category by ID.
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Reorder categories by saving updated sortOrder values.
  Future<void> reorder(List<CategoryModel> categories) async {
    for (int i = 0; i < categories.length; i++) {
      final updated = categories[i].copyWith(sortOrder: i);
      await _box.put(updated.id, updated.toJson());
    }
  }

  /// Delete all categories.
  Future<void> deleteAll() async {
    await _box.clear();
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/data/hive/hive_init.dart';
import 'package:amar_khoroch/data/models/category_model.dart';
import 'package:amar_khoroch/data/repositories/category_repository.dart';
import 'package:amar_khoroch/providers/workspace_provider.dart';

/// Repository provider.
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(HiveBoxes.categories);
});

/// Raw category notifier.
final categoryNotifierProvider =
    StateNotifierProvider<CategoryNotifier, List<CategoryModel>>((ref) {
  final repo = ref.read(categoryRepositoryProvider);
  return CategoryNotifier(repo);
});

/// Categories for the active workspace.
final categoryProvider = Provider<List<CategoryModel>>((ref) {
  final all = ref.watch(categoryNotifierProvider);
  final activeWorkspaceId = ref.watch(activeWorkspaceIdProvider);
  if (activeWorkspaceId == null) return [];
  return all.where((c) => c.workspaceId == activeWorkspaceId).toList();
});

/// Income categories only.
final incomeCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  final categories = ref.watch(categoryProvider);
  return categories.where((c) => c.type == 0).toList();
});

/// Expense categories only.
final expenseCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  final categories = ref.watch(categoryProvider);
  return categories.where((c) => c.type == 1).toList();
});

class CategoryNotifier extends StateNotifier<List<CategoryModel>> {
  final CategoryRepository _repo;

  CategoryNotifier(this._repo) : super([]) {
    _load();
  }

  void _load() {
    state = _repo.getAll();
  }

  Future<void> add(CategoryModel category) async {
    final withOrder = category.copyWith(sortOrder: state.length);
    await _repo.add(withOrder);
    _load();
  }

  Future<void> update(CategoryModel category) async {
    await _repo.update(category);
    _load();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    _load();
  }

  Future<void> reorder(List<CategoryModel> reordered) async {
    await _repo.reorder(reordered);
    _load();
  }

  CategoryModel? getById(String id) {
    return _repo.getById(id);
  }

  void refresh() => _load();
}

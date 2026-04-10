import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/data/models/workspace_model.dart';
import 'package:amar_khoroch/data/repositories/workspace_repository.dart';
import 'package:amar_khoroch/data/hive/hive_init.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import 'package:amar_khoroch/core/constants/app_constants.dart';
import 'package:amar_khoroch/data/models/category_model.dart';
import 'package:amar_khoroch/providers/category_provider.dart';

final workspaceRepositoryProvider = Provider<WorkspaceRepository>((ref) {
  return WorkspaceRepository(HiveBoxes.workspaces);
});

final activeWorkspaceIdProvider = StateProvider<String?>((ref) {
  // Try to read last active from settings
  // The settings provider should expose this, or we can read it directly from hive here
  return HiveBoxes.settings.get('activeWorkspaceId') as String?;
});

final workspacesProvider =
    StateNotifierProvider<WorkspaceNotifier, List<WorkspaceModel>>((ref) {
  final repo = ref.read(workspaceRepositoryProvider);
  return WorkspaceNotifier(repo, ref);
});

final activeWorkspaceProvider = Provider<WorkspaceModel?>((ref) {
  final activeId = ref.watch(activeWorkspaceIdProvider);
  final all = ref.watch(workspacesProvider);
  if (activeId == null || all.isEmpty) return null;
  return all.where((w) => w.id == activeId).firstOrNull ?? all.first;
});

class WorkspaceNotifier extends StateNotifier<List<WorkspaceModel>> {
  final WorkspaceRepository _repo;
  final Ref _ref;

  WorkspaceNotifier(this._repo, this._ref) : super([]) {
    _load();
  }

  void _load() {
    final list = _repo.getAll();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    state = list;

    // Auto-select if nothing is selected but we have workspaces
    final currentId = _ref.read(activeWorkspaceIdProvider);
    if (list.isNotEmpty) {
      if (currentId == null || !list.any((w) => w.id == currentId)) {
        setActive(list.first.id);
      }
    } else {
      if (currentId != null) {
        _ref.read(activeWorkspaceIdProvider.notifier).state = null;
        HiveBoxes.settings.delete('activeWorkspaceId');
      }
    }
  }

  Future<void> add(WorkspaceModel workspace) async {
    await _repo.add(workspace);
    _seedDefaultCategories(workspace.id);
    _load();
    if (state.length == 1) {
      setActive(workspace.id);
    }
  }

  void _seedDefaultCategories(String workspaceId) {
    final categories = [
      // Income
      CategoryModel(id: const Uuid().v4(), workspaceId: workspaceId, name: 'Salary', type: TransactionType.income, color: 0xFF4CAF50, iconCodePoint: CupertinoIcons.money_dollar.codePoint, sortOrder: 0),
      CategoryModel(id: const Uuid().v4(), workspaceId: workspaceId, name: 'Business', type: TransactionType.income, color: 0xFF2196F3, iconCodePoint: CupertinoIcons.briefcase.codePoint, sortOrder: 1),
      // Expense
      CategoryModel(id: const Uuid().v4(), workspaceId: workspaceId, name: 'Food', type: TransactionType.expense, color: 0xFFFF9800, iconCodePoint: CupertinoIcons.cart.codePoint, sortOrder: 0),
      CategoryModel(id: const Uuid().v4(), workspaceId: workspaceId, name: 'Transport', type: TransactionType.expense, color: 0xFF9C27B0, iconCodePoint: CupertinoIcons.car.codePoint, sortOrder: 1),
      CategoryModel(id: const Uuid().v4(), workspaceId: workspaceId, name: 'Bills', type: TransactionType.expense, color: 0xFFF44336, iconCodePoint: CupertinoIcons.doc_text.codePoint, sortOrder: 2),
      CategoryModel(id: const Uuid().v4(), workspaceId: workspaceId, name: 'Shopping', type: TransactionType.expense, color: 0xFFE91E63, iconCodePoint: CupertinoIcons.bag.codePoint, sortOrder: 3),
      CategoryModel(id: const Uuid().v4(), workspaceId: workspaceId, name: 'Education', type: TransactionType.expense, color: 0xFF009688, iconCodePoint: CupertinoIcons.book.codePoint, sortOrder: 4),
      CategoryModel(id: const Uuid().v4(), workspaceId: workspaceId, name: 'Rent', type: TransactionType.expense, color: 0xFF3F51B5, iconCodePoint: CupertinoIcons.house.codePoint, sortOrder: 5),
      CategoryModel(id: const Uuid().v4(), workspaceId: workspaceId, name: 'Travel', type: TransactionType.expense, color: 0xFF00BCD4, iconCodePoint: CupertinoIcons.airplane.codePoint, sortOrder: 6),
      CategoryModel(id: const Uuid().v4(), workspaceId: workspaceId, name: 'Medical', type: TransactionType.expense, color: 0xFFF44336, iconCodePoint: CupertinoIcons.heart.codePoint, sortOrder: 7),
      CategoryModel(id: const Uuid().v4(), workspaceId: workspaceId, name: 'Internet', type: TransactionType.expense, color: 0xFF4CAF50, iconCodePoint: CupertinoIcons.wifi.codePoint, sortOrder: 8),
      CategoryModel(id: const Uuid().v4(), workspaceId: workspaceId, name: 'Mobile', type: TransactionType.expense, color: 0xFF607D8B, iconCodePoint: CupertinoIcons.device_phone_portrait.codePoint, sortOrder: 9),
    ];
    final notifier = _ref.read(categoryNotifierProvider.notifier);
    for (var c in categories) {
      notifier.add(c); // Doesn't require active workspace context because workspaceId is injected
    }
  }

  Future<void> update(WorkspaceModel workspace) async {
    await _repo.update(workspace);
    _load();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    // Note: Deleting a workspace should technically cascade delete its transactions, categories, etc.
    // For now, we will handle that at the UI or as a cleanup pass.
    _load();
  }

  void setActive(String id) {
    _ref.read(activeWorkspaceIdProvider.notifier).state = id;
    HiveBoxes.settings.put('activeWorkspaceId', id);
  }

  void refresh() => _load();
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/data/hive/hive_init.dart';
import 'package:amar_khoroch/data/models/account_model.dart';
import 'package:amar_khoroch/data/repositories/account_repository.dart';
import 'package:amar_khoroch/providers/workspace_provider.dart';

/// Repository provider.
final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(HiveBoxes.accounts);
});

/// Raw account notifier.
final accountNotifierProvider =
    StateNotifierProvider<AccountNotifier, List<AccountModel>>((ref) {
  final repo = ref.read(accountRepositoryProvider);
  return AccountNotifier(repo);
});

/// Accounts (wallets) for active workspace.
final accountProvider = Provider<List<AccountModel>>((ref) {
  final all = ref.watch(accountNotifierProvider);
  final activeWorkspaceId = ref.watch(activeWorkspaceIdProvider);
  if (activeWorkspaceId == null) return [];
  return all.where((a) => a.workspaceId == activeWorkspaceId).toList();
});

/// Total balance of all active accounts.
final totalBalanceProvider = Provider<double>((ref) {
  final accounts = ref.watch(accountProvider);
  return accounts.fold(0.0, (sum, a) => sum + a.balance);
});

class AccountNotifier extends StateNotifier<List<AccountModel>> {
  final AccountRepository _repo;

  AccountNotifier(this._repo) : super([]) {
    _load();
  }

  void _load() {
    state = _repo.getAll();
  }

  Future<void> add(AccountModel account) async {
    final withOrder = account.copyWith(sortOrder: state.length);
    await _repo.add(withOrder);
    _load();
  }

  Future<void> update(AccountModel account) async {
    await _repo.update(account);
    _load();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    _load();
  }

  Future<void> archive(String id) async {
    final account = _repo.getById(id);
    if (account == null) return;
    await _repo.update(account.copyWith(isArchived: true));
    _load();
  }

  /// Update balance by delta (used during transaction add/edit/delete).
  Future<void> updateBalance(String id, double delta) async {
    await _repo.updateBalance(id, delta);
    _load();
  }

  /// Set absolute balance (used during account edit).
  Future<void> setBalance(String id, double balance) async {
    await _repo.setBalance(id, balance);
    _load();
  }

  Future<void> reorder(List<AccountModel> reordered) async {
    for (int i = 0; i < reordered.length; i++) {
      final updated = reordered[i].copyWith(sortOrder: i);
      await _repo.update(updated);
    }
    _load();
  }

  void refresh() => _load();
}

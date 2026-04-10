import 'package:hive/hive.dart';
import 'package:amar_khoroch/data/models/account_model.dart';

class AccountRepository {
  final Box _box;

  AccountRepository(this._box);

  /// Get all active (non-archived) accounts, sorted by sortOrder.
  List<AccountModel> getAll() {
    return _box.values
        .map((e) {
          final map = Map<String, dynamic>.from(e as Map);
          return AccountModel.fromJson(map);
        })
        .where((a) => !a.isArchived)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Get all accounts including archived.
  List<AccountModel> getAllIncludingArchived() {
    return _box.values
        .map((e) {
          final map = Map<String, dynamic>.from(e as Map);
          return AccountModel.fromJson(map);
        })
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Get a single account by ID.
  AccountModel? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    return AccountModel.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  /// Add a new account.
  Future<void> add(AccountModel account) async {
    await _box.put(account.id, account.toJson());
  }

  /// Update an existing account.
  Future<void> update(AccountModel account) async {
    await _box.put(account.id, account.toJson());
  }

  /// Delete an account by ID.
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Update account balance by a delta amount.
  Future<void> updateBalance(String id, double delta) async {
    final account = getById(id);
    if (account == null) return;
    final updated = account.copyWith(balance: account.balance + delta);
    await update(updated);
  }

  /// Set absolute balance for an account.
  Future<void> setBalance(String id, double balance) async {
    final account = getById(id);
    if (account == null) return;
    final updated = account.copyWith(balance: balance);
    await update(updated);
  }

  /// Get total balance of all active accounts.
  double getTotalBalance() {
    return getAll().fold(0.0, (sum, a) => sum + a.balance);
  }

  /// Delete all accounts.
  Future<void> deleteAll() async {
    await _box.clear();
  }
}

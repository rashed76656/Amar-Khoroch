import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/data/hive/hive_init.dart';
import 'package:amar_khoroch/data/models/transaction_model.dart';
import 'package:amar_khoroch/data/repositories/transaction_repository.dart';
import 'package:amar_khoroch/providers/account_provider.dart';
import 'package:amar_khoroch/core/constants/app_constants.dart';
import 'package:amar_khoroch/core/utils/app_date_utils.dart';
import 'package:amar_khoroch/providers/workspace_provider.dart';

/// Repository provider.
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(HiveBoxes.transactions);
});

/// Currently selected month for filtering.
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

/// Raw transactions notifier (all workspaces).
final transactionNotifierProvider =
    StateNotifierProvider<TransactionNotifier, List<TransactionModel>>((ref) {
  final repo = ref.read(transactionRepositoryProvider);
  return TransactionNotifier(repo, ref);
});

/// All transactions for the active workspace.
final allTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final all = ref.watch(transactionNotifierProvider);
  final activeWorkspaceId = ref.watch(activeWorkspaceIdProvider);
  if (activeWorkspaceId == null) return [];
  return all.where((t) => t.workspaceId == activeWorkspaceId).toList();
});

/// Transactions for the selected month.
final monthlyTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final all = ref.watch(allTransactionsProvider);
  final month = ref.watch(selectedMonthProvider);
  return all
      .where((t) => AppDateUtils.isInMonth(t.date, month.year, month.month))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));
});

/// Monthly income total.
final monthlyIncomeProvider = Provider<double>((ref) {
  final txns = ref.watch(monthlyTransactionsProvider);
  return txns
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// Monthly expense total.
final monthlyExpenseProvider = Provider<double>((ref) {
  final txns = ref.watch(monthlyTransactionsProvider);
  return txns
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// Transactions grouped by date (for the selected month).
final dailyGroupedTransactionsProvider =
    Provider<Map<DateTime, List<TransactionModel>>>((ref) {
  final txns = ref.watch(monthlyTransactionsProvider);
  final Map<DateTime, List<TransactionModel>> grouped = {};

  for (final t in txns) {
    final dateKey = AppDateUtils.dateOnly(t.date);
    grouped.putIfAbsent(dateKey, () => []).add(t);
  }

  // Sort each day's transactions by creation time (newest first)
  for (final list in grouped.values) {
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  return grouped;
});

/// Sorted date keys for daily groups (newest first).
final sortedDateKeysProvider = Provider<List<DateTime>>((ref) {
  final grouped = ref.watch(dailyGroupedTransactionsProvider);
  return grouped.keys.toList()..sort((a, b) => b.compareTo(a));
});

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  final TransactionRepository _repo;
  final Ref _ref;

  TransactionNotifier(this._repo, this._ref) : super([]) {
    _load();
  }

  void _load() {
    state = _repo.getAll();
  }

  /// Add a new transaction and update account balances.
  Future<void> add(TransactionModel transaction) async {
    await _repo.add(transaction);
    _applyBalanceChange(transaction, reverse: false);
    _load();
  }

  /// Edit a transaction: reverse old effect, apply new effect.
  Future<void> edit(
      TransactionModel oldTransaction, TransactionModel newTransaction) async {
    _applyBalanceChange(oldTransaction, reverse: true);
    await _repo.update(newTransaction);
    _applyBalanceChange(newTransaction, reverse: false);
    _load();
  }

  /// Delete a transaction and reverse its balance effect.
  Future<void> delete(TransactionModel transaction) async {
    _applyBalanceChange(transaction, reverse: true);
    await _repo.delete(transaction.id);
    _load();
  }

  /// Apply or reverse a transaction's effect on account balances.
  void _applyBalanceChange(TransactionModel tx, {required bool reverse}) {
    final accountNotifier = _ref.read(accountNotifierProvider.notifier);
    final multiplier = reverse ? -1.0 : 1.0;

    switch (tx.type) {
      case TransactionType.income:
        // Income adds money to the account
        accountNotifier.updateBalance(tx.accountId, tx.amount * multiplier);
        break;
      case TransactionType.expense:
        // Expense subtracts money from the account
        accountNotifier.updateBalance(tx.accountId, -tx.amount * multiplier);
        break;
      case TransactionType.transfer:
        // Transfer: subtract from source, add to destination
        accountNotifier.updateBalance(tx.accountId, -tx.amount * multiplier);
        if (tx.toAccountId != null) {
          accountNotifier.updateBalance(
              tx.toAccountId!, tx.amount * multiplier);
        }
        break;
    }
  }

  void refresh() => _load();
}

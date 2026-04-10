import 'package:hive/hive.dart';
import 'package:amar_khoroch/data/models/transaction_model.dart';

class TransactionRepository {
  final Box _box;

  TransactionRepository(this._box);

  /// Get all transactions.
  List<TransactionModel> getAll() {
    return _box.values.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return TransactionModel.fromJson(map);
    }).toList();
  }

  /// Get transactions for a specific month.
  List<TransactionModel> getByMonth(int year, int month) {
    return getAll().where((t) {
      return t.date.year == year && t.date.month == month;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get transactions for a specific date.
  List<TransactionModel> getByDate(DateTime date) {
    return getAll().where((t) {
      return t.date.year == date.year &&
          t.date.month == date.month &&
          t.date.day == date.day;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get a single transaction by ID.
  TransactionModel? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    return TransactionModel.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  /// Add a new transaction.
  Future<void> add(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction.toJson());
  }

  /// Update an existing transaction.
  Future<void> update(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction.toJson());
  }

  /// Delete a transaction by ID.
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Delete all transactions.
  Future<void> deleteAll() async {
    await _box.clear();
  }
}

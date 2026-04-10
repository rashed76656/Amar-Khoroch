import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxes {
  HiveBoxes._();

  static const String _transactionsBox = 'transactions';
  static const String _accountsBox = 'accounts';
  static const String _categoriesBox = 'categories';
  static const String _settingsBox = 'settings';
  static const String _budgetsBox = 'budgets';
  static const String _workspacesBox = 'workspaces';

  static late Box transactions;
  static late Box accounts;
  static late Box categories;
  static late Box settings;
  static late Box budgets;
  static late Box workspaces;

  static Future<void> init() async {
    await Hive.initFlutter();

    transactions = await Hive.openBox(_transactionsBox);
    accounts = await Hive.openBox(_accountsBox);
    categories = await Hive.openBox(_categoriesBox);
    settings = await Hive.openBox(_settingsBox);
    budgets = await Hive.openBox(_budgetsBox);
    workspaces = await Hive.openBox(_workspacesBox);
  }

  /// Clears all data from all boxes. Used for "Reset All Data" feature.
  static Future<void> clearAll() async {
    await transactions.clear();
    await accounts.clear();
    await categories.clear();
    await budgets.clear();
    await workspaces.clear();
    // Keep settings intact during data reset
  }
}

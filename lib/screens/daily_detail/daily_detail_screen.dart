import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/core/constants/app_constants.dart';
import 'package:amar_khoroch/core/utils/currency_formatter.dart';
import 'package:amar_khoroch/core/utils/app_date_utils.dart';
import 'package:amar_khoroch/data/models/transaction_model.dart';

import 'package:amar_khoroch/providers/transaction_provider.dart';
import 'package:amar_khoroch/providers/category_provider.dart';
import 'package:amar_khoroch/providers/account_provider.dart';
import 'package:amar_khoroch/providers/settings_provider.dart';
import 'package:amar_khoroch/screens/add_transaction/add_transaction_screen.dart';
import 'package:amar_khoroch/screens/daily_detail/widgets/transaction_item.dart';
import 'package:amar_khoroch/widgets/empty_state.dart';

class DailyDetailScreen extends ConsumerWidget {
  final DateTime date;

  const DailyDetailScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTransactions = ref.watch(allTransactionsProvider);
    final isVisible = ref.watch(amountVisibilityProvider);
    final categories = ref.watch(categoryProvider);
    final accounts = ref.watch(accountProvider);

    // Filter transactions for this day
    final dayTransactions = allTransactions
        .where((t) => AppDateUtils.isSameDay(t.date, date))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final income = dayTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final expense = dayTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            CupertinoIcons.back,
            color: AppTheme.textPrimary,
          ),
        ),
        title: Text(
          AppDateUtils.formatRelativeDate(date),
          style: AppTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Summary header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration,
            child: Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    label: 'Income',
                    amount: income,
                    color: AppTheme.incomeColor,
                    icon: CupertinoIcons.arrow_up_circle_fill,
                    isVisible: isVisible,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.separator,
                ),
                Expanded(
                  child: _SummaryItem(
                    label: 'Expense',
                    amount: expense,
                    color: AppTheme.expenseColor,
                    icon: CupertinoIcons.arrow_down_circle_fill,
                    isVisible: isVisible,
                  ),
                ),
              ],
            ),
          ),
          // Transaction list
          Expanded(
            child: dayTransactions.isEmpty
                ? const EmptyState(
                    icon: CupertinoIcons.doc_text,
                    title: 'No transactions',
                    subtitle: 'Nothing recorded for this day',
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: dayTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = dayTransactions[index];
                      return TransactionItem(
                        transaction: tx,
                        category: tx.categoryId != null
                            ? categories
                                .where((c) => c.id == tx.categoryId)
                                .firstOrNull
                            : null,
                        account: accounts
                            .where((a) => a.id == tx.accountId)
                            .firstOrNull,
                        toAccount: tx.toAccountId != null
                            ? accounts
                                .where((a) => a.id == tx.toAccountId)
                                .firstOrNull
                            : null,
                        isVisible: isVisible,
                        onTap: () => _editTransaction(context, tx),
                        onDelete: () => _deleteTransaction(context, ref, tx),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTransaction(context),
        backgroundColor: AppTheme.primaryAccent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          CupertinoIcons.add,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  void _addTransaction(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => AddTransactionScreen(initialDate: date),
      ),
    );
  }

  void _editTransaction(BuildContext context, TransactionModel tx) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => AddTransactionScreen(editTransaction: tx),
      ),
    );
  }

  void _deleteTransaction(
      BuildContext context, WidgetRef ref, TransactionModel tx) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Transaction'),
        content: Text(
          'Are you sure you want to delete this ${TransactionType.label(tx.type).toLowerCase()} of ${CurrencyFormatter.format(tx.amount)}?',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              ref.read(transactionNotifierProvider.notifier).delete(tx);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final bool isVisible;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: AppTheme.caption.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          isVisible ? CurrencyFormatter.format(amount) : '৳ ••••',
          style: AppTheme.titleMedium.copyWith(color: color),
        ),
      ],
    );
  }
}

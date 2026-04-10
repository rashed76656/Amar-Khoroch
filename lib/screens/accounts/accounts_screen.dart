import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/core/constants/app_constants.dart';
import 'package:amar_khoroch/core/utils/currency_formatter.dart';
import 'package:amar_khoroch/data/models/account_model.dart';
import 'package:amar_khoroch/providers/account_provider.dart';
import 'package:amar_khoroch/providers/settings_provider.dart';
import 'package:amar_khoroch/screens/accounts/widgets/account_form.dart';
import 'package:amar_khoroch/widgets/empty_state.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountProvider);
    final totalBalance = ref.watch(totalBalanceProvider);
    final isVisible = ref.watch(amountVisibilityProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.back, color: AppTheme.textPrimary),
        ),
        title: Text('Accounts', style: AppTheme.titleLarge),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => _addAccount(context, ref),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                CupertinoIcons.add_circled,
                color: AppTheme.primaryAccent,
                size: 24,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Total balance header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF5EDE3),
                  Color(0xFFEDE4D8),
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              boxShadow: AppTheme.elevatedShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Balance',
                      style: AppTheme.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isVisible
                          ? CurrencyFormatter.format(totalBalance)
                          : CurrencyFormatter.hidden,
                      style: AppTheme.headlineMedium,
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () =>
                      ref.read(amountVisibilityProvider.notifier).toggle(),
                  child: Icon(
                    isVisible
                        ? CupertinoIcons.eye
                        : CupertinoIcons.eye_slash,
                    color: AppTheme.textSecondary,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          // Account list
          Expanded(
            child: accounts.isEmpty
                ? const EmptyState(
                    icon: CupertinoIcons.creditcard,
                    title: 'No accounts yet',
                    subtitle: 'Tap + to add your first account',
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      return _AccountTile(
                        account: account,
                        isVisible: isVisible,
                        onEdit: () =>
                            _editAccount(context, ref, account),
                        onDelete: () =>
                            _deleteAccount(context, ref, account),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _addAccount(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AccountForm(
        onSave: (account) {
          ref.read(accountNotifierProvider.notifier).add(account);
        },
      ),
    );
  }

  void _editAccount(
      BuildContext context, WidgetRef ref, AccountModel account) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AccountForm(
        editAccount: account,
        onSave: (updated) {
          ref.read(accountNotifierProvider.notifier).update(updated);
        },
      ),
    );
  }

  void _deleteAccount(
      BuildContext context, WidgetRef ref, AccountModel account) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Account'),
        content: Text(
            'Delete "${account.name}"? This cannot be undone. Transactions linked to this account will keep their data.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              ref.read(accountNotifierProvider.notifier).delete(account.id);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final AccountModel account;
  final bool isVisible;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AccountTile({
    required this.account,
    required this.isVisible,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration,
        child: Row(
          children: [
            // Type icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryAccentLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                AccountType.icon(account.type),
                size: 22,
                color: AppTheme.primaryAccent,
              ),
            ),
            const SizedBox(width: 14),
            // Name + type
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(account.name, style: AppTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    AccountType.label(account.type),
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ),
            // Balance
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isVisible
                      ? CurrencyFormatter.format(account.balance)
                      : CurrencyFormatter.hidden,
                  style: AppTheme.amountMedium.copyWith(
                    color: account.balance >= 0
                        ? AppTheme.textPrimary
                        : AppTheme.expenseColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            // Delete button
            GestureDetector(
              onTap: onDelete,
              child: Icon(
                CupertinoIcons.trash,
                size: 18,
                color: AppTheme.destructive.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

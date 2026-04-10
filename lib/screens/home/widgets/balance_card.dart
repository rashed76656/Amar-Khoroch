import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/core/utils/currency_formatter.dart';
import 'package:amar_khoroch/providers/account_provider.dart';
import 'package:amar_khoroch/providers/transaction_provider.dart';
import 'package:amar_khoroch/providers/settings_provider.dart';

/// Top balance summary card showing total balance, income, expense, and net.
class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalBalance = ref.watch(totalBalanceProvider);
    final monthlyIncome = ref.watch(monthlyIncomeProvider);
    final monthlyExpense = ref.watch(monthlyExpenseProvider);
    final netBalance = monthlyIncome - monthlyExpense;
    final isVisible = ref.watch(amountVisibilityProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () =>
                    ref.read(amountVisibilityProvider.notifier).toggle(),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isVisible
                        ? CupertinoIcons.eye
                        : CupertinoIcons.eye_slash,
                    key: ValueKey(isVisible),
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Total balance amount
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              isVisible
                  ? CurrencyFormatter.format(totalBalance)
                  : CurrencyFormatter.hidden,
              key: ValueKey('$totalBalance-$isVisible'),
              style: AppTheme.headlineLarge.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Income / Expense / Net row
          Row(
            children: [
              _BalanceItem(
                label: 'Income',
                amount: monthlyIncome,
                color: AppTheme.incomeColor,
                icon: CupertinoIcons.arrow_up_circle_fill,
                isVisible: isVisible,
              ),
              const SizedBox(width: 12),
              _BalanceItem(
                label: 'Expense',
                amount: monthlyExpense,
                color: AppTheme.expenseColor,
                icon: CupertinoIcons.arrow_down_circle_fill,
                isVisible: isVisible,
              ),
              const SizedBox(width: 12),
              _BalanceItem(
                label: 'Net',
                amount: netBalance,
                color: netBalance >= 0
                    ? AppTheme.incomeColor
                    : AppTheme.expenseColor,
                icon: netBalance >= 0
                    ? CupertinoIcons.arrow_up_right
                    : CupertinoIcons.arrow_down_right,
                isVisible: isVisible,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final bool isVisible;

  const _BalanceItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: AppTheme.caption.copyWith(color: color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isVisible
                  ? CurrencyFormatter.format(amount)
                  : '৳ ••••',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

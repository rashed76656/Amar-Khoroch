import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/core/constants/app_constants.dart';
import 'package:amar_khoroch/providers/transaction_provider.dart';
import 'package:amar_khoroch/providers/account_provider.dart';
import 'package:amar_khoroch/screens/home/widgets/month_selector.dart';
import 'package:amar_khoroch/screens/home/widgets/balance_card.dart';
import 'package:amar_khoroch/screens/home/widgets/daily_group_tile.dart';
import 'package:amar_khoroch/screens/home/widgets/workspace_switcher.dart';
import 'package:amar_khoroch/screens/add_transaction/add_transaction_screen.dart';
import 'package:amar_khoroch/screens/accounts/accounts_screen.dart';
import 'package:amar_khoroch/screens/reports/reports_screen.dart';
import 'package:amar_khoroch/screens/budgets/budgets_screen.dart';
import 'package:amar_khoroch/screens/settings/settings_screen.dart';
import 'package:amar_khoroch/widgets/empty_state.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _TransactionsTab(),
          BudgetsScreen(),
          ReportsScreen(),
          SettingsScreen(),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
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
            )
          : null,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppTheme.separator.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: CupertinoIcons.rectangle_stack,
                activeIcon: CupertinoIcons.rectangle_stack_fill,
                label: 'Transactions',
                isActive: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _NavItem(
                icon: CupertinoIcons.chart_bar_alt_fill,
                activeIcon: CupertinoIcons.chart_bar_alt_fill,
                label: 'Budgets',
                isActive: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _NavItem(
                icon: CupertinoIcons.chart_pie,
                activeIcon: CupertinoIcons.chart_pie_fill,
                label: 'Reports',
                isActive: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
              ),
              _NavItem(
                icon: CupertinoIcons.gear,
                activeIcon: CupertinoIcons.gear_solid,
                label: 'Settings',
                isActive: _currentIndex == 3,
                onTap: () => setState(() => _currentIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addTransaction(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => const AddTransactionScreen(),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryAccent.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive ? AppTheme.primaryAccent : AppTheme.textTertiary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color:
                    isActive ? AppTheme.primaryAccent : AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The transactions tab content.
class _TransactionsTab extends ConsumerWidget {
  const _TransactionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(dailyGroupedTransactionsProvider);
    final dateKeys = ref.watch(sortedDateKeysProvider);
    final accounts = ref.watch(accountProvider);

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App title / Workspace Switcher
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: WorkspaceSwitcher(),
            ),
          ),
          // Month selector
          const SliverToBoxAdapter(
            child: MonthSelector(),
          ),
          // Balance card
          const SliverToBoxAdapter(
            child: BalanceCard(),
          ),
          // Manage Accounts button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => const AccountsScreen(),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.creditcard,
                        size: 18,
                        color: AppTheme.primaryAccent,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Manage Wallets',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${accounts.length} wallets',
                        style: AppTheme.bodySmall,
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        CupertinoIcons.chevron_right,
                        size: 14,
                        color: AppTheme.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          // Daily transaction groups or empty state
          if (dateKeys.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: CupertinoIcons.doc_text,
                title: 'No transactions yet',
                subtitle:
                    'Tap the + button to add your first transaction',
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == dateKeys.length) {
                    return const SizedBox(height: 80); // FAB spacing
                  }
                  final date = dateKeys[index];
                  final txns = grouped[date]!;
                  return DailyGroupTile(date: date, transactions: txns);
                },
                childCount: dateKeys.length + 1,
              ),
            ),
        ],
      ),
    );
  }
}

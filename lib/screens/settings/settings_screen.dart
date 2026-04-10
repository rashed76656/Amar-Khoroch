import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/data/hive/hive_init.dart';
import 'package:amar_khoroch/providers/account_provider.dart';
import 'package:amar_khoroch/providers/category_provider.dart';
import 'package:amar_khoroch/providers/transaction_provider.dart';
import 'package:amar_khoroch/providers/settings_provider.dart';
import 'package:amar_khoroch/providers/security_provider.dart';
import 'package:amar_khoroch/screens/categories/category_management_screen.dart';
import 'package:amar_khoroch/screens/accounts/accounts_screen.dart';
import 'package:amar_khoroch/screens/workspaces/workspace_management_screen.dart';
import 'package:amar_khoroch/screens/security/pin_screen.dart';
import 'package:amar_khoroch/providers/budget_provider.dart';
import 'package:amar_khoroch/providers/workspace_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(amountVisibilityProvider);
    final security = ref.watch(securityProvider);

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Text('Settings', style: AppTheme.headlineLarge),
            ),
          ),

          // General section
          SliverToBoxAdapter(child: _SectionHeader(title: 'General')),
          SliverToBoxAdapter(
            child: _SettingsTile(
              icon: isVisible ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
              title: 'Show Amounts',
              subtitle: 'Toggle balance visibility',
              trailing: CupertinoSwitch(
                value: isVisible,
                activeTrackColor: AppTheme.primaryAccent,
                onChanged: (_) =>
                    ref.read(amountVisibilityProvider.notifier).toggle(),
              ),
            ),
          ),

          // Security section
          SliverToBoxAdapter(child: _SectionHeader(title: 'Security')),
          SliverToBoxAdapter(
            child: _SettingsTile(
              icon: security.isPinEnabled
                  ? CupertinoIcons.lock_fill
                  : CupertinoIcons.lock_open_fill,
              title: security.isPinEnabled ? 'Disable PIN' : 'Enable PIN',
              subtitle: 'App lock security',
              onTap: () {
                if (security.isPinEnabled) {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) =>
                          const PinScreen(mode: PinScreenMode.remove),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) =>
                          const PinScreen(mode: PinScreenMode.setup),
                    ),
                  );
                }
              },
            ),
          ),

          // Data section
          SliverToBoxAdapter(
            child: _SectionHeader(title: 'Data & Configuration'),
          ),
          SliverToBoxAdapter(
            child: _SettingsTile(
              icon: CupertinoIcons.folder,
              title: 'Manage Workspaces',
              subtitle: 'Create additional profiles',
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => const WorkspaceManagementScreen(),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: _SettingsTile(
              icon: CupertinoIcons.tag,
              title: 'Manage Categories',
              subtitle: 'Add, edit, or reorder categories',
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => const CategoryManagementScreen(),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: _SettingsTile(
              icon: CupertinoIcons.creditcard,
              title: 'Manage Wallets',
              subtitle: 'Add or edit internal wallets',
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => const AccountsScreen()),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: _SettingsTile(
              icon: CupertinoIcons.trash,
              title: 'Reset All Data',
              subtitle: 'Permanently delete all workspaces & data',
              titleColor: AppTheme.destructive,
              onTap: () => _resetData(context, ref),
            ),
          ),

          // App info section
          SliverToBoxAdapter(child: _SectionHeader(title: 'About')),
          SliverToBoxAdapter(
            child: _SettingsTile(
              icon: CupertinoIcons.info,
              title: 'Amar Khoroch',
              subtitle: 'Version 1.0.0 • Made by Raxhu❤️ | Bangladesh.',
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  void _resetData(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Reset All Data'),
        content: const Text(
          'This will permanently delete ALL transactions, accounts, and categories. This action cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Reset Everything'),
            onPressed: () {
              Navigator.pop(ctx);
              _confirmReset(context, ref);
            },
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Are you absolutely sure?'),
        content: const Text(
          'All your workspaces and financial data will be permanently deleted.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Yes, Delete All'),
            onPressed: () async {
              await HiveBoxes.clearAll();
              ref.read(transactionNotifierProvider.notifier).refresh();
              ref.read(accountNotifierProvider.notifier).refresh();
              ref.read(categoryNotifierProvider.notifier).refresh();
              ref.read(budgetNotifierProvider.notifier).refresh();
              ref.read(workspacesProvider.notifier).refresh();
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: AppTheme.caption.copyWith(
          letterSpacing: 1.0,
          fontSize: 11,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle = '',
    this.titleColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.cardDecoration,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryAccentLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: titleColor ?? AppTheme.primaryAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.titleMedium.copyWith(
                      color: titleColor ?? AppTheme.textPrimary,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(subtitle, style: AppTheme.bodySmall),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (onTap != null && trailing == null)
              Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: AppTheme.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}

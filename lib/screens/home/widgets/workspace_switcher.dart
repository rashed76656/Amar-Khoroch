import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/providers/workspace_provider.dart';
import 'package:amar_khoroch/data/models/workspace_model.dart';
import 'package:amar_khoroch/screens/workspaces/widgets/workspace_form.dart';

IconData _getWorkspaceIcon(int codePoint) {
  if (codePoint == CupertinoIcons.person.codePoint) return CupertinoIcons.person;
  if (codePoint == CupertinoIcons.briefcase.codePoint) return CupertinoIcons.briefcase;
  return CupertinoIcons.person;
}

class WorkspaceSwitcher extends ConsumerWidget {
  const WorkspaceSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeWorkspaceProvider);

    if (active == null) return const SizedBox();

    return GestureDetector(
      onTap: () => _showSwitcherBlock(context, ref),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Color(active.color).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getWorkspaceIcon(active.iconCodePoint),
              size: 20,
              color: Color(active.color),
            ),
          ),
          const SizedBox(width: 10),
          Text(active.name, style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          Icon(CupertinoIcons.chevron_down, size: 18, color: AppTheme.textSecondary),
        ],
      ),
    );
  }

  void _showSwitcherBlock(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SwitcherSheet(),
    );
  }
}

class _SwitcherSheet extends ConsumerWidget {
  const _SwitcherSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaces = ref.watch(workspacesProvider);
    final active = ref.watch(activeWorkspaceProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(bottom: 24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Switch Profile',
                style: AppTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ...workspaces.map((w) {
              final isActive = active?.id == w.id;
              final accent = Color(w.color);
              return GestureDetector(
                onTap: () {
                  ref.read(workspacesProvider.notifier).setActive(w.id);
                  Navigator.pop(context);
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isActive ? accent.withValues(alpha: 0.1) : AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: isActive ? Border.all(color: accent, width: 1.5) : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getWorkspaceIcon(w.iconCodePoint),
                          size: 20,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          w.name,
                          style: AppTheme.titleMedium.copyWith(
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isActive)
                        Icon(CupertinoIcons.checkmark_alt_circle_fill, size: 24, color: accent),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const WorkspaceForm(),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.add, size: 20, color: AppTheme.primaryAccent),
                      const SizedBox(width: 8),
                      Text(
                        'Create New Account',
                        style: AppTheme.titleMedium.copyWith(color: AppTheme.primaryAccent),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

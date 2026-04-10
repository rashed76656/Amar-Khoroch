import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/data/models/workspace_model.dart';
import 'package:amar_khoroch/providers/workspace_provider.dart';
import 'package:amar_khoroch/screens/workspaces/widgets/workspace_form.dart';
import 'package:amar_khoroch/widgets/empty_state.dart';

class WorkspaceManagementScreen extends ConsumerWidget {
  const WorkspaceManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaces = ref.watch(workspacesProvider);
    final activeId = ref.watch(activeWorkspaceIdProvider);

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
        title: Text('Profiles', style: AppTheme.titleLarge),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => _addWorkspace(context),
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
      body: workspaces.isEmpty
          ? const EmptyState(
              icon: CupertinoIcons.person_3_fill,
              title: 'No profiles',
              subtitle: 'Tap + to create a profile',
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: workspaces.length,
              itemBuilder: (context, index) {
                final w = workspaces[index];
                final isActive = w.id == activeId;

                return _WorkspaceTile(
                  workspace: w,
                  isActive: isActive,
                  onEdit: () => _editWorkspace(context, w),
                  onDelete: () => _deleteWorkspace(context, ref, w, isActive),
                  onTap: () {
                    ref.read(workspacesProvider.notifier).setActive(w.id);
                  },
                );
              },
            ),
    );
  }

  void _addWorkspace(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const WorkspaceForm(),
    );
  }

  void _editWorkspace(BuildContext context, WorkspaceModel workspace) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WorkspaceForm(editWorkspace: workspace),
    );
  }

  void _deleteWorkspace(BuildContext context, WidgetRef ref, WorkspaceModel workspace, bool isActive) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Profile'),
        content: Text(isActive 
            ? 'You cannot delete the currently active profile. Switch to another profile first.' 
            : 'Delete profile "${workspace.name}"? This will not delete transactions permanently but removes access scope.'),
        actions: [
          if (isActive)
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(ctx),
            )
          else ...[
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(ctx),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Delete'),
              onPressed: () {
                ref.read(workspacesProvider.notifier).delete(workspace.id);
                Navigator.pop(ctx);
              },
            ),
          ]
        ],
      ),
    );
  }
}

class _WorkspaceTile extends StatelessWidget {
  final WorkspaceModel workspace;
  final bool isActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _WorkspaceTile({
    required this.workspace,
    required this.isActive,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  IconData _getWorkspaceIconFallback(int codePoint) {
    if (codePoint == CupertinoIcons.person.codePoint) return CupertinoIcons.person;
    if (codePoint == CupertinoIcons.briefcase.codePoint) return CupertinoIcons.briefcase;
    if (codePoint == CupertinoIcons.house.codePoint) return CupertinoIcons.house;
    if (codePoint == CupertinoIcons.airplane.codePoint) return CupertinoIcons.airplane;
    return CupertinoIcons.person;
  }

  @override
  Widget build(BuildContext context) {
    final accent = Color(workspace.color);
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isActive ? accent.withValues(alpha: 0.1) : AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: isActive ? Border.all(color: accent, width: 1.5) : null,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getWorkspaceIconFallback(workspace.iconCodePoint),
                  color: accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workspace.name,
                      style: AppTheme.titleMedium,
                    ),
                    if (isActive)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Active profile',
                          style: AppTheme.bodySmall.copyWith(color: accent),
                        ),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(CupertinoIcons.pencil, size: 20, color: AppTheme.textSecondary),
                ),
              ),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(CupertinoIcons.trash, size: 20, color: AppTheme.expenseColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

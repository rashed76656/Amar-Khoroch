import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/data/models/workspace_model.dart';
import 'package:amar_khoroch/providers/workspace_provider.dart';

class WorkspaceSetupScreen extends ConsumerStatefulWidget {
  const WorkspaceSetupScreen({super.key});

  @override
  ConsumerState<WorkspaceSetupScreen> createState() => _WorkspaceSetupScreenState();
}

class _WorkspaceSetupScreenState extends ConsumerState<WorkspaceSetupScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createWorkspace() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);

    final workspace = WorkspaceModel(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(workspacesProvider.notifier).add(workspace);
    // Provider auto-selects if it's the first one, removing this screen from wrapper
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryAccentLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.rocket_fill,
                  size: 40,
                  color: AppTheme.primaryAccent,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to Amar Khoroch',
                style: AppTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Let\'s create your first financial profile. You can add more profiles later for family, business, or travel.',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                decoration: AppTheme.cardDecoration,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _nameController,
                  style: AppTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'e.g. Personal Budget',
                    hintStyle: AppTheme.bodyLarge.copyWith(color: AppTheme.textTertiary),
                    border: InputBorder.none,
                    icon: Icon(CupertinoIcons.person_solid, color: AppTheme.textSecondary),
                  ),
                  onSubmitted: (_) => _createWorkspace(),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _isLoading ? null : _createWorkspace,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryAccent,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryAccent.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const CupertinoActivityIndicator(color: Colors.white)
                        : Text(
                            'Get Started',
                            style: AppTheme.titleMedium.copyWith(color: Colors.white),
                          ),
                  ),
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

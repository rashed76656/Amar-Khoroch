import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/core/constants/app_constants.dart';
import 'package:amar_khoroch/data/models/workspace_model.dart';
import 'package:amar_khoroch/providers/workspace_provider.dart';

class WorkspaceForm extends ConsumerStatefulWidget {
  final WorkspaceModel? editWorkspace;

  const WorkspaceForm({super.key, this.editWorkspace});

  @override
  ConsumerState<WorkspaceForm> createState() => _WorkspaceFormState();
}

class _WorkspaceFormState extends ConsumerState<WorkspaceForm> {
  final _nameController = TextEditingController();
  late int _selectedColor;
  late int _selectedIcon;

  @override
  void initState() {
    super.initState();
    if (widget.editWorkspace != null) {
      _nameController.text = widget.editWorkspace!.name;
      _selectedColor = widget.editWorkspace!.color;
      _selectedIcon = widget.editWorkspace!.iconCodePoint;
    } else {
      _selectedColor = CategoryColors.available[4].toARGB32(); // Blue default
      _selectedIcon = CupertinoIcons.person.codePoint;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    if (widget.editWorkspace != null) {
      final updated = widget.editWorkspace!.copyWith(
        name: name,
        color: _selectedColor,
        iconCodePoint: _selectedIcon,
        updatedAt: DateTime.now(),
      );
      ref.read(workspacesProvider.notifier).update(updated);
    } else {
      final newWorkspace = WorkspaceModel(
        id: const Uuid().v4(),
        name: name,
        color: _selectedColor,
        iconCodePoint: _selectedIcon,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      ref.read(workspacesProvider.notifier).add(newWorkspace);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editWorkspace != null;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Profile' : 'New Profile',
                    style: AppTheme.headlineMedium,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(CupertinoIcons.xmark, size: 20, color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Preview Icon
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Color(_selectedColor).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getWorkspaceIconFallback(_selectedIcon),
                          size: 36,
                          color: Color(_selectedColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Container(
                      decoration: AppTheme.cardDecoration,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextField(
                        controller: _nameController,
                        style: AppTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Profile Name (e.g. Travel fund)',
                          hintStyle: AppTheme.bodyLarge.copyWith(color: AppTheme.textTertiary),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Color Picker
                    Text('Color', style: AppTheme.titleMedium),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: CategoryColors.available.length,
                        itemBuilder: (context, index) {
                          final color = CategoryColors.available[index];
                          final colorValue = color.toARGB32();
                          final isSelected = colorValue == _selectedColor;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColor = colorValue),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected ? Border.all(color: AppTheme.background, width: 3) : null,
                                boxShadow: isSelected
                                    ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1)]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(CupertinoIcons.checkmark_alt, color: Colors.white)
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Icon Picker
                    Text('Icon', style: AppTheme.titleMedium),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: 4, // Expose standard icons
                      itemBuilder: (context, index) {
                        final availableIcons = [CupertinoIcons.person, CupertinoIcons.briefcase, CupertinoIcons.house, CupertinoIcons.airplane];
                        final icon = availableIcons[index];
                        final isSelected = icon.codePoint == _selectedIcon;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedIcon = icon.codePoint),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? Color(_selectedColor).withValues(alpha: 0.15) : AppTheme.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected ? Border.all(color: Color(_selectedColor), width: 1.5) : null,
                            ),
                            child: Icon(
                              icon,
                              color: isSelected ? Color(_selectedColor) : AppTheme.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    GestureDetector(
                      onTap: _save,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryAccent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryAccent.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            isEditing ? 'Save Changes' : 'Create Profile',
                            style: AppTheme.titleMedium.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWorkspaceIconFallback(int codePoint) {
    if (codePoint == CupertinoIcons.person.codePoint) return CupertinoIcons.person;
    if (codePoint == CupertinoIcons.briefcase.codePoint) return CupertinoIcons.briefcase;
    if (codePoint == CupertinoIcons.house.codePoint) return CupertinoIcons.house;
    if (codePoint == CupertinoIcons.airplane.codePoint) return CupertinoIcons.airplane;
    return CupertinoIcons.person;
  }
}

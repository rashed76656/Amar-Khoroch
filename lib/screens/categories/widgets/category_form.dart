import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/core/constants/app_constants.dart';
import 'package:amar_khoroch/data/models/category_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/providers/workspace_provider.dart';

/// Bottom sheet form for adding/editing a category.
class CategoryForm extends ConsumerStatefulWidget {
  final int type;
  final CategoryModel? editCategory;
  final ValueChanged<CategoryModel> onSave;

  const CategoryForm({
    super.key,
    required this.type,
    this.editCategory,
    required this.onSave,
  });

  @override
  ConsumerState<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends ConsumerState<CategoryForm> {
  final _nameController = TextEditingController();
  late int _selectedIconIndex;
  late int _selectedColorIndex;

  bool get isEditing => widget.editCategory != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final cat = widget.editCategory!;
      _nameController.text = cat.name;
      _selectedIconIndex = CategoryIcons.available
          .indexWhere((i) => i.codePoint == cat.iconCodePoint);
      if (_selectedIconIndex < 0) _selectedIconIndex = 0;
      _selectedColorIndex = CategoryColors.available
          .indexWhere((c) => c.toARGB32() == cat.color);
      if (_selectedColorIndex < 0) _selectedColorIndex = 0;
    } else {
      _selectedIconIndex = 0;
      _selectedColorIndex = 0;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.separator,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEditing ? 'Edit Category' : 'Add Category',
              style: AppTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Name input
            Container(
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(12),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _nameController,
                style: AppTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Category name',
                  hintStyle: AppTheme.bodyLarge
                      .copyWith(color: AppTheme.textTertiary),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Icon picker
            Text('Icon', style: AppTheme.caption),
            const SizedBox(height: 8),
            SizedBox(
              height: 160,
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: CategoryIcons.available.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedIconIndex == index;
                  final iconColor = CategoryColors
                      .available[_selectedColorIndex];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedIconIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? iconColor.withValues(alpha: 0.12)
                            : AppTheme.background,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border.all(color: iconColor, width: 1.5)
                            : null,
                      ),
                      child: Icon(
                        CategoryIcons.available[index],
                        size: 22,
                        color: isSelected
                            ? iconColor
                            : AppTheme.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Color picker
            Text('Color', style: AppTheme.caption),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(
                CategoryColors.available.length,
                (index) {
                  final color = CategoryColors.available[index];
                  final isSelected = _selectedColorIndex == index;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedColorIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              CupertinoIcons.checkmark,
                              size: 18,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            GestureDetector(
              onTap: _save,
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
                  child: Text(
                    isEditing ? 'Update Category' : 'Add Category',
                    style: AppTheme.titleMedium
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    final activeWorkspaceId = ref.read(activeWorkspaceIdProvider) ?? 'default';

    final category = CategoryModel(
      id: isEditing ? widget.editCategory!.id : const Uuid().v4(),
      workspaceId: activeWorkspaceId,
      name: name,
      type: widget.type,
      iconCodePoint: CategoryIcons.available[_selectedIconIndex].codePoint,
      color: CategoryColors.available[_selectedColorIndex].toARGB32(),
      sortOrder: isEditing ? widget.editCategory!.sortOrder : 0,
    );

    widget.onSave(category);
    Navigator.pop(context);
  }
}

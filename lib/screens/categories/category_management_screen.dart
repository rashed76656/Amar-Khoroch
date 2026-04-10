import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/core/constants/app_constants.dart';
import 'package:amar_khoroch/data/models/category_model.dart';
import 'package:amar_khoroch/providers/category_provider.dart';
import 'package:amar_khoroch/screens/categories/widgets/category_form.dart';
import 'package:amar_khoroch/widgets/empty_state.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  final int initialType;

  const CategoryManagementScreen({super.key, this.initialType = 1});

  @override
  ConsumerState<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState
    extends ConsumerState<CategoryManagementScreen> {
  late int _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  Widget build(BuildContext context) {
    final incomeCategories = ref.watch(incomeCategoriesProvider);
    final expenseCategories = ref.watch(expenseCategoriesProvider);
    final categories =
        _selectedType == CategoryType.income ? incomeCategories : expenseCategories;

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
        title: Text('Categories', style: AppTheme.titleLarge),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => _addCategory(),
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
          // Type toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.cardShadow,
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _ToggleTab(
                    label: 'Income',
                    color: AppTheme.incomeColor,
                    isSelected: _selectedType == CategoryType.income,
                    onTap: () =>
                        setState(() => _selectedType = CategoryType.income),
                  ),
                  _ToggleTab(
                    label: 'Expense',
                    color: AppTheme.expenseColor,
                    isSelected: _selectedType == CategoryType.expense,
                    onTap: () =>
                        setState(() => _selectedType = CategoryType.expense),
                  ),
                ],
              ),
            ),
          ),
          // Category list
          Expanded(
            child: categories.isEmpty
                ? EmptyState(
                    icon: CupertinoIcons.tag,
                    title: 'No ${_selectedType == CategoryType.income ? 'income' : 'expense'} categories',
                    subtitle: 'Tap + to add a category',
                  )
                : ReorderableListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 16),
                    buildDefaultDragHandles: false,
                    itemCount: categories.length,
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) newIndex--;
                      final list = List<CategoryModel>.from(categories);
                      final item = list.removeAt(oldIndex);
                      list.insert(newIndex, item);
                      ref.read(categoryNotifierProvider.notifier).reorder(list);
                    },
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return _CategoryTile(
                        key: ValueKey(cat.id),
                        category: cat,
                        index: index,
                        onEdit: () => _editCategory(cat),
                        onDelete: () => _deleteCategory(cat),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _addCategory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryForm(
        type: _selectedType,
        onSave: (category) {
          ref.read(categoryNotifierProvider.notifier).add(category);
        },
      ),
    );
  }

  void _editCategory(CategoryModel category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryForm(
        type: _selectedType,
        editCategory: category,
        onSave: (updated) {
          ref.read(categoryNotifierProvider.notifier).update(updated);
        },
      ),
    );
  }

  void _deleteCategory(CategoryModel category) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Category'),
        content: Text('Delete "${category.name}"? Transactions using this category will keep their data.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              ref.read(categoryNotifierProvider.notifier).delete(category.id);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryTile({
    super.key,
    required this.category,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          // Drag handle
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                CupertinoIcons.line_horizontal_3,
                color: AppTheme.textTertiary,
                size: 20,
              ),
            ),
          ),
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(category.color).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              CategoryIcons.fromCodePoint(category.iconCodePoint),
              size: 20,
              color: Color(category.color),
            ),
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: Text(category.name, style: AppTheme.titleMedium),
          ),
          // Edit
          GestureDetector(
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                CupertinoIcons.pencil,
                size: 18,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          // Delete
          GestureDetector(
            onTap: onDelete,
            child: Padding(
              padding: const EdgeInsets.only(right: 12, left: 4, top: 8, bottom: 8),
              child: Icon(
                CupertinoIcons.trash,
                size: 18,
                color: AppTheme.destructive.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? color : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

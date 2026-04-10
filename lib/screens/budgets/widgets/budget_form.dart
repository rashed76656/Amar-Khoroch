import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/core/constants/app_constants.dart';
import 'package:amar_khoroch/data/models/budget_model.dart';
import 'package:amar_khoroch/data/models/category_model.dart';
import 'package:amar_khoroch/providers/category_provider.dart';
import 'package:amar_khoroch/providers/budget_provider.dart';
import 'package:amar_khoroch/providers/workspace_provider.dart';

class BudgetForm extends ConsumerStatefulWidget {
  final BudgetModel? editBudget;
  final String? preselectedCategoryId;
  final int month;
  final int year;
  final void Function(BudgetModel) onSave;

  const BudgetForm({
    super.key,
    this.editBudget,
    this.preselectedCategoryId,
    required this.month,
    required this.year,
    required this.onSave,
  });

  @override
  ConsumerState<BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends ConsumerState<BudgetForm> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedCategoryId;

  bool get isEditing => widget.editBudget != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final b = widget.editBudget!;
      _selectedCategoryId = b.categoryId;
      _amountController.text = b.amount.toStringAsFixed(0);
      _noteController.text = b.note;
    } else {
      _selectedCategoryId = widget.preselectedCategoryId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only show expense categories for budgeting
    final categories = ref.watch(expenseCategoriesProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
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
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                isEditing ? 'Edit Budget' : 'Set Budget',
                style: AppTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Category selector (disabled if editing)
                  _buildDropdown(
                    label: 'Category',
                    value: _selectedCategoryId,
                    items: categories,
                    onChanged: isEditing
                        ? (v) {} // Can't change category of existing budget
                        : (v) => setState(() => _selectedCategoryId = v),
                    enabled: !isEditing,
                  ),
                  const SizedBox(height: 16),

                  // Amount input
                  _buildAmountInput(),
                  const SizedBox(height: 16),

                  // Note input
                  _buildNoteInput(),
                  const SizedBox(height: 32),

                  // Save button
                  _buildSaveButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<CategoryModel> items,
    required ValueChanged<String?> onChanged,
    required bool enabled,
  }) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: items.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No expense categories available.',
                style: AppTheme.bodySmall,
              ),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: items.any((c) => c.id == value) ? value : null,
                hint: Text(label, style: AppTheme.bodyMedium),
                isExpanded: true,
                icon: enabled
                    ? const Icon(CupertinoIcons.chevron_down, size: 16)
                    : const SizedBox(),
                items: items.map((cat) {
                  return DropdownMenuItem(
                    value: cat.id,
                    child: Row(
                      children: [
                        Icon(
                          CategoryIcons.fromCodePoint(cat.iconCodePoint),
                          size: 18,
                          color: Color(cat.color),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          cat.name,
                          style: AppTheme.bodyMedium.copyWith(
                            color: enabled
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: enabled ? onChanged : null,
              ),
            ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Text(
            AppConstants.currencySymbol,
            style: AppTheme.headlineMedium.copyWith(
              color: AppTheme.primaryAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: AppTheme.headlineMedium,
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: AppTheme.headlineMedium.copyWith(
                  color: AppTheme.textTertiary,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                labelText: 'Monthly Limit',
                labelStyle: AppTheme.caption,
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteInput() {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: _noteController,
        style: AppTheme.bodyMedium,
        maxLines: 2,
        decoration: InputDecoration(
          hintText: 'Add a note (optional)',
          hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              CupertinoIcons.pencil,
              size: 20,
              color: AppTheme.primaryAccent,
            ),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 28, minHeight: 0),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
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
            isEditing ? 'Update Budget' : 'Save Budget',
            style: AppTheme.titleMedium.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_selectedCategoryId == null) {
      _showError('Please select a category');
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showError('Please enter a budget limit');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    // Check for duplicates
    final exists = ref.read(budgetNotifierProvider.notifier).exists(
          _selectedCategoryId!,
          widget.year,
          widget.month,
          excludeId: isEditing ? widget.editBudget!.id : null,
        );
    if (exists) {
      _showError('A budget already exists for this category in this month');
      return;
    }

    final activeWorkspaceId = ref.read(activeWorkspaceIdProvider) ?? 'default';

    final budget = BudgetModel(
      id: isEditing ? widget.editBudget!.id : const Uuid().v4(),
      workspaceId: activeWorkspaceId,
      categoryId: _selectedCategoryId!,
      month: widget.month,
      year: widget.year,
      amount: amount,
      note: _noteController.text.trim(),
      createdAt: isEditing ? widget.editBudget!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(budget);
    Navigator.pop(context);
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Validation Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/core/constants/app_constants.dart';
import 'package:amar_khoroch/data/models/transaction_model.dart';
import 'package:amar_khoroch/data/models/category_model.dart';
import 'package:amar_khoroch/data/models/account_model.dart';
import 'package:amar_khoroch/providers/transaction_provider.dart';
import 'package:amar_khoroch/providers/category_provider.dart';
import 'package:amar_khoroch/providers/account_provider.dart';
import 'package:amar_khoroch/providers/workspace_provider.dart';
import 'package:amar_khoroch/core/utils/app_date_utils.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionModel? editTransaction;
  final DateTime? initialDate;

  const AddTransactionScreen({
    super.key,
    this.editTransaction,
    this.initialDate,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  late int _type;
  final _amountController = TextEditingController();
  String? _selectedAccountId;
  String? _selectedToAccountId;
  String? _selectedCategoryId;
  late DateTime _selectedDate;
  final _noteController = TextEditingController();

  bool get isEditing => widget.editTransaction != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final tx = widget.editTransaction!;
      _type = tx.type;
      _amountController.text = tx.amount.toStringAsFixed(0);
      _selectedAccountId = tx.accountId;
      _selectedToAccountId = tx.toAccountId;
      _selectedCategoryId = tx.categoryId;
      _selectedDate = tx.date;
      _noteController.text = tx.note;
    } else {
      _type = TransactionType.expense;
      _selectedDate = widget.initialDate ?? DateTime.now();
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
    final accounts = ref.watch(accountProvider);
    final incomeCategories = ref.watch(incomeCategoriesProvider);
    final expenseCategories = ref.watch(expenseCategoriesProvider);
    final categories = _type == TransactionType.income
        ? incomeCategories
        : expenseCategories;

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
        title: Text(
          isEditing ? 'Edit Transaction' : 'Add Transaction',
          style: AppTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Type selector
            _buildTypeSelector(),
            const SizedBox(height: 20),

            // Amount input
            _buildAmountInput(),
            const SizedBox(height: 16),

            // Account selector
            if (_type == TransactionType.transfer) ...[
              _buildDropdown(
                label: 'From Account',
                value: _selectedAccountId,
                items: accounts,
                onChanged: (v) => setState(() => _selectedAccountId = v),
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'To Account',
                value: _selectedToAccountId,
                items: accounts
                    .where((a) => a.id != _selectedAccountId)
                    .toList(),
                onChanged: (v) => setState(() => _selectedToAccountId = v),
              ),
            ] else ...[
              _buildDropdown(
                label: 'Account',
                value: _selectedAccountId,
                items: accounts,
                onChanged: (v) => setState(() => _selectedAccountId = v),
              ),
            ],
            const SizedBox(height: 16),

            // Category selector (not for transfer)
            if (_type != TransactionType.transfer) ...[
              _buildCategoryPicker(categories),
              const SizedBox(height: 16),
            ],

            // Date picker
            _buildDatePicker(),
            const SizedBox(height: 16),

            // Note
            _buildNoteInput(),
            const SizedBox(height: 32),

            // Save button
            _buildSaveButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _TypeTab(
            label: 'Income',
            color: AppTheme.incomeColor,
            isSelected: _type == TransactionType.income,
            onTap: () => setState(() {
              _type = TransactionType.income;
              _selectedCategoryId = null;
            }),
          ),
          _TypeTab(
            label: 'Expense',
            color: AppTheme.expenseColor,
            isSelected: _type == TransactionType.expense,
            onTap: () => setState(() {
              _type = TransactionType.expense;
              _selectedCategoryId = null;
            }),
          ),
          _TypeTab(
            label: 'Transfer',
            color: AppTheme.transferColor,
            isSelected: _type == TransactionType.transfer,
            onTap: () => setState(() {
              _type = TransactionType.transfer;
              _selectedCategoryId = null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Text(
            AppConstants.currencySymbol,
            style: AppTheme.headlineLarge.copyWith(
              color: AppTheme.primaryAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: AppTheme.headlineLarge,
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: AppTheme.headlineLarge.copyWith(
                  color: AppTheme.textTertiary,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<AccountModel> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: items.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No accounts yet. Create one first.',
                style: AppTheme.bodySmall,
              ),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: items.any((a) => a.id == value) ? value : null,
                hint: Text(label, style: AppTheme.bodyMedium),
                isExpanded: true,
                icon: const Icon(CupertinoIcons.chevron_down, size: 16),
                items: items.map((account) {
                  return DropdownMenuItem(
                    value: account.id,
                    child: Row(
                      children: [
                        Icon(
                          AccountType.icon(account.type),
                          size: 18,
                          color: AppTheme.primaryAccent,
                        ),
                        const SizedBox(width: 10),
                        Text(account.name, style: AppTheme.bodyMedium),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
    );
  }

  Widget _buildCategoryPicker(List<CategoryModel> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('Category', style: AppTheme.caption),
        ),
        if (categories.isEmpty)
          Container(
            decoration: AppTheme.cardDecoration,
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'No categories yet. Add from Settings.',
                style: AppTheme.bodySmall,
              ),
            ),
          )
        else
          Container(
            decoration: AppTheme.cardDecoration,
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                final isSelected = _selectedCategoryId == cat.id;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategoryId = cat.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(cat.color).withValues(alpha: 0.15)
                          : AppTheme.background,
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? Border.all(
                              color: Color(cat.color),
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CategoryIcons.fromCodePoint(cat.iconCodePoint),
                          size: 18,
                          color: Color(cat.color),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat.name,
                          style: AppTheme.bodySmall.copyWith(
                            color: isSelected
                                ? Color(cat.color)
                                : AppTheme.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () => _showDatePicker(),
      child: Container(
        decoration: AppTheme.cardDecoration,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.calendar,
              size: 20,
              color: AppTheme.primaryAccent,
            ),
            const SizedBox(width: 12),
            Text(
              AppDateUtils.formatDate(_selectedDate),
              style: AppTheme.bodyMedium,
            ),
            const Spacer(),
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
            isEditing ? 'Update Transaction' : 'Save Transaction',
            style: AppTheme.titleMedium.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _showDatePicker() {
    DateTime tempDate = _selectedDate;
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Done'),
                    onPressed: () {
                      setState(() => _selectedDate = tempDate);
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate,
                maximumDate: DateTime.now().add(const Duration(days: 1)),
                onDateTimeChanged: (date) => tempDate = date,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    // Validate amount
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showError('Please enter an amount');
      return;
    }
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    // Validate account
    if (_selectedAccountId == null) {
      _showError('Please select an account');
      return;
    }

    // Validate transfer account
    if (_type == TransactionType.transfer && _selectedToAccountId == null) {
      _showError('Please select a destination account');
      return;
    }

    // Validate category (not for transfer)
    if (_type != TransactionType.transfer && _selectedCategoryId == null) {
      _showError('Please select a category');
      return;
    }

    final activeWorkspaceId = ref.read(activeWorkspaceIdProvider) ?? 'default';

    final transaction = TransactionModel(
      id: isEditing ? widget.editTransaction!.id : const Uuid().v4(),
      workspaceId: activeWorkspaceId,
      type: _type,
      amount: amount,
      accountId: _selectedAccountId!,
      toAccountId:
          _type == TransactionType.transfer ? _selectedToAccountId : null,
      categoryId:
          _type == TransactionType.transfer ? null : _selectedCategoryId,
      date: _selectedDate,
      note: _noteController.text.trim(),
      createdAt:
          isEditing ? widget.editTransaction!.createdAt : DateTime.now(),
    );

    if (isEditing) {
      ref
          .read(transactionNotifierProvider.notifier)
          .edit(widget.editTransaction!, transaction);
    } else {
      ref.read(transactionNotifierProvider.notifier).add(transaction);
    }

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

class _TypeTab extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeTab({
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.12) : Colors.transparent,
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

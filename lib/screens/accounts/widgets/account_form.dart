import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/core/constants/app_constants.dart';
import 'package:amar_khoroch/data/models/account_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/providers/workspace_provider.dart';

/// Bottom sheet form for adding/editing an account.
class AccountForm extends ConsumerStatefulWidget {
  final AccountModel? editAccount;
  final ValueChanged<AccountModel> onSave;

  const AccountForm({
    super.key,
    this.editAccount,
    required this.onSave,
  });

  @override
  ConsumerState<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends ConsumerState<AccountForm> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  int _selectedType = AccountType.cash;

  bool get isEditing => widget.editAccount != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final acc = widget.editAccount!;
      _nameController.text = acc.name;
      _balanceController.text = acc.balance.toStringAsFixed(0);
      _selectedType = acc.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
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
              isEditing ? 'Edit Account' : 'Add Account',
              style: AppTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Name input
            _buildInputField(
              controller: _nameController,
              hint: 'Account name',
              icon: CupertinoIcons.textformat,
            ),
            const SizedBox(height: 12),

            // Balance input
            _buildInputField(
              controller: _balanceController,
              hint: isEditing ? 'Current balance' : 'Initial balance',
              icon: CupertinoIcons.money_dollar,
              keyboardType: TextInputType.number,
              prefix: '৳ ',
            ),
            const SizedBox(height: 16),

            // Account type selector
            Text('Account Type', style: AppTheme.caption),
            const SizedBox(height: 8),
            Row(
              children: [
                _TypeOption(
                  type: AccountType.cash,
                  label: 'Cash',
                  icon: CupertinoIcons.money_dollar,
                  isSelected: _selectedType == AccountType.cash,
                  onTap: () =>
                      setState(() => _selectedType = AccountType.cash),
                ),
                const SizedBox(width: 8),
                _TypeOption(
                  type: AccountType.bank,
                  label: 'Bank',
                  icon: CupertinoIcons.building_2_fill,
                  isSelected: _selectedType == AccountType.bank,
                  onTap: () =>
                      setState(() => _selectedType = AccountType.bank),
                ),
                const SizedBox(width: 8),
                _TypeOption(
                  type: AccountType.mobileWallet,
                  label: 'Mobile',
                  icon: CupertinoIcons.device_phone_portrait,
                  isSelected: _selectedType == AccountType.mobileWallet,
                  onTap: () => setState(
                      () => _selectedType = AccountType.mobileWallet),
                ),
              ],
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
                    isEditing ? 'Update Account' : 'Add Account',
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? prefix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryAccent),
          const SizedBox(width: 10),
          if (prefix != null)
            Text(prefix,
                style: AppTheme.bodyLarge
                    .copyWith(color: AppTheme.primaryAccent)),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: AppTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                    AppTheme.bodyLarge.copyWith(color: AppTheme.textTertiary),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an account name')),
      );
      return;
    }

    final balanceText = _balanceController.text.trim();
    final balance =
        balanceText.isEmpty ? 0.0 : (double.tryParse(balanceText) ?? 0.0);

    final activeWorkspaceId = ref.read(activeWorkspaceIdProvider) ?? 'default';

    final account = AccountModel(
      id: isEditing ? widget.editAccount!.id : const Uuid().v4(),
      workspaceId: activeWorkspaceId,
      name: name,
      type: _selectedType,
      balance: balance,
      sortOrder: isEditing ? widget.editAccount!.sortOrder : 0,
      isArchived: false,
    );

    widget.onSave(account);
    Navigator.pop(context);
  }
}

class _TypeOption extends StatelessWidget {
  final int type;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeOption({
    required this.type,
    required this.label,
    required this.icon,
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
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryAccent.withValues(alpha: 0.1)
                : AppTheme.background,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: AppTheme.primaryAccent, width: 1.5)
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                color:
                    isSelected ? AppTheme.primaryAccent : AppTheme.textSecondary,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppTheme.primaryAccent
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

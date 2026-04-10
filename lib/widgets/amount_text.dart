import 'package:flutter/material.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/core/utils/currency_formatter.dart';
import 'package:amar_khoroch/core/constants/app_constants.dart';

/// Displays a formatted amount colored by transaction type.
class AmountText extends StatelessWidget {
  final double amount;
  final int? transactionType; // null = neutral (uses primary color)
  final TextStyle? style;
  final bool showSign;
  final bool visible;

  const AmountText({
    super.key,
    required this.amount,
    this.transactionType,
    this.style,
    this.showSign = false,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return Text(
        CurrencyFormatter.hidden,
        style: (style ?? AppTheme.amountMedium).copyWith(
          color: AppTheme.textTertiary,
        ),
      );
    }

    final color = _getColor();
    final text = showSign
        ? CurrencyFormatter.formatSigned(
            transactionType == TransactionType.expense ? -amount : amount)
        : CurrencyFormatter.format(amount);

    return Text(
      text,
      style: (style ?? AppTheme.amountMedium).copyWith(color: color),
    );
  }

  Color _getColor() {
    if (transactionType == null) return AppTheme.textPrimary;
    switch (transactionType!) {
      case TransactionType.income:
        return AppTheme.incomeColor;
      case TransactionType.expense:
        return AppTheme.expenseColor;
      case TransactionType.transfer:
        return AppTheme.transferColor;
      default:
        return AppTheme.textPrimary;
    }
  }
}

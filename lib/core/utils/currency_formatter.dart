import 'package:intl/intl.dart';
import 'package:amar_khoroch/core/constants/app_constants.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat('#,##0', 'en_US');

  /// Formats amount as: ৳ 1,250
  static String format(double amount) {
    return '${AppConstants.currencySymbol} ${_formatter.format(amount.round().abs())}';
  }

  /// Formats with sign: +৳ 1,250 or -৳ 1,250
  static String formatSigned(double amount) {
    final sign = amount >= 0 ? '+' : '-';
    return '$sign${AppConstants.currencySymbol} ${_formatter.format(amount.round().abs())}';
  }

  /// Returns just the numeric part: 1,250
  static String formatNumber(double amount) {
    return _formatter.format(amount.round().abs());
  }

  /// Hidden amount display
  static const String hidden = '৳ ••••';
}

import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final _monthYearFormat = DateFormat('MMMM yyyy');
  static final _dateFormat = DateFormat('d MMM yyyy');
  static final _dayFormat = DateFormat('EEEE');
  static final _shortDayFormat = DateFormat('EEE');
  static final _dayMonthFormat = DateFormat('d MMM');

  /// "April 2026"
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// "10 Apr 2026"
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// "Thursday"
  static String formatDay(DateTime date) {
    return _dayFormat.format(date);
  }

  /// "Thu"
  static String formatShortDay(DateTime date) {
    return _shortDayFormat.format(date);
  }

  /// "10 Apr"
  static String formatDayMonth(DateTime date) {
    return _dayMonthFormat.format(date);
  }

  /// Check if two dates are the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Check if a date falls within a given month/year.
  static bool isInMonth(DateTime date, int year, int month) {
    return date.year == year && date.month == month;
  }

  /// Get the start of a month (first day, midnight).
  static DateTime startOfMonth(int year, int month) {
    return DateTime(year, month, 1);
  }

  /// Get the end of a month (last day, end of day).
  static DateTime endOfMonth(int year, int month) {
    return DateTime(year, month + 1, 0, 23, 59, 59);
  }

  /// Get previous month.
  static DateTime previousMonth(DateTime date) {
    return DateTime(date.year, date.month - 1);
  }

  /// Get next month.
  static DateTime nextMonth(DateTime date) {
    return DateTime(date.year, date.month + 1);
  }

  /// Strip time component, keeping only date.
  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Check if a given month/year is the current month.
  static bool isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// "Today", "Yesterday", or "Thu, 10 Apr"
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return '${formatShortDay(date)}, ${formatDayMonth(date)}';
  }
}

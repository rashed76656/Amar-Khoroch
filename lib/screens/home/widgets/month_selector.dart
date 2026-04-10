import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/core/utils/app_date_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/providers/transaction_provider.dart';

/// Month & year selector with left/right navigation arrows.
class MonthSelector extends ConsumerWidget {
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final isCurrentMonth = AppDateUtils.isCurrentMonth(selectedMonth);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ArrowButton(
            icon: CupertinoIcons.chevron_left,
            onTap: () {
              ref.read(selectedMonthProvider.notifier).state =
                  AppDateUtils.previousMonth(selectedMonth);
            },
          ),
          GestureDetector(
            onTap: () => _showMonthPicker(context, ref),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Text(
                AppDateUtils.formatMonthYear(selectedMonth),
                key: ValueKey(selectedMonth),
                style: AppTheme.titleLarge,
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: isCurrentMonth ? 0.3 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: _ArrowButton(
              icon: CupertinoIcons.chevron_right,
              onTap: isCurrentMonth
                  ? null
                  : () {
                      ref.read(selectedMonthProvider.notifier).state =
                          AppDateUtils.nextMonth(selectedMonth);
                    },
            ),
          ),
        ],
      ),
    );
  }

  void _showMonthPicker(BuildContext context, WidgetRef ref) {
    final current = ref.read(selectedMonthProvider);
    DateTime tempDate = current;

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      ref.read(selectedMonthProvider.notifier).state =
                          DateTime(tempDate.year, tempDate.month);
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.monthYear,
                initialDateTime: current,
                maximumDate: DateTime.now(),
                onDateTimeChanged: (date) {
                  tempDate = date;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ArrowButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(10),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? AppTheme.textPrimary : AppTheme.textTertiary,
        ),
      ),
    );
  }
}

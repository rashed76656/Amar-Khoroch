import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/core/utils/currency_formatter.dart';

/// Category data for the donut chart.
class ChartCategoryData {
  final String name;
  final double amount;
  final Color color;
  final double percentage;

  ChartCategoryData({
    required this.name,
    required this.amount,
    required this.color,
    required this.percentage,
  });
}

/// Donut chart showing category distribution with total in the center.
class DonutChart extends StatelessWidget {
  final List<ChartCategoryData> data;
  final double total;
  final bool isVisible;

  const DonutChart({
    super.key,
    required this.data,
    required this.total,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: data.map((item) {
                return PieChartSectionData(
                  value: item.amount,
                  color: item.color,
                  radius: 32,
                  title: '',
                  badgeWidget: null,
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 70,
              startDegreeOffset: -90,
            ),
          ),
          // Center text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isVisible
                    ? CurrencyFormatter.format(total)
                    : '৳ ••••',
                style: AppTheme.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';

class GenreDistributionChart extends StatelessWidget {
  const GenreDistributionChart({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildChartContainer(
      title: 'Tracks per Genre',
      subtitle: 'Distribution of tracks across genres',
      child: SizedBox(
        height: 220,
        child: BarChart(_buildBarChartData()),
      ),
    );
  }

  BarChartData _buildBarChartData() {
    final data = [
      _GenreData('Pop', 45, AppColors.primaryNeon),
      _GenreData('Rock', 38, AppColors.primaryNeon.withValues(alpha: 0.8)),
      _GenreData('Hip-Hop', 32, AppColors.primaryNeon.withValues(alpha: 0.6)),
      _GenreData('R&B', 28, AppColors.primaryNeon.withValues(alpha: 0.5)),
      _GenreData('Jazz', 22, AppColors.primaryNeon.withValues(alpha: 0.4)),
      _GenreData('EDM', 18, AppColors.primaryNeon.withValues(alpha: 0.3)),
    ];

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 55,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 10,
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppColors.borderDark,
          strokeWidth: 0.5,
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < data.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    data[index].label,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(
        data.length,
        (i) => BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: data[i].value,
              color: data[i].color,
              width: 28,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 55,
                color: AppColors.surfaceElevated,
              ),
            ),
          ],
        ),
      ),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => AppColors.surfaceElevated,
          tooltipRoundedRadius: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              '${data[group.x].label}\n${rod.toY.toInt()} tracks',
              const TextStyle(
                color: AppColors.primaryNeon,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChartContainer({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryNeon.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: AppColors.primaryNeon,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _GenreData {
  final String label;
  final double value;
  final Color color;

  const _GenreData(this.label, this.value, this.color);
}

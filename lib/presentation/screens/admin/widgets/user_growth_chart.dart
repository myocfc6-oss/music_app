import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';

class UserGrowthChart extends StatefulWidget {
  const UserGrowthChart({super.key});

  @override
  State<UserGrowthChart> createState() => _UserGrowthChartState();
}

class _UserGrowthChartState extends State<UserGrowthChart> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<_MonthData> _data = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final now = DateTime.now();
      final months = <_MonthData>[];

      for (int i = 11; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i, 1);
        final nextMonth = DateTime(date.year, date.month + 1, 1);
        final label = _monthLabel(date.month);

        final result = await _supabase
            .from('user_tbl')
            .select('user_id')
            .gte('created_at', date.toIso8601String())
            .lt('created_at', nextMonth.toIso8601String());

        months.add(_MonthData(label, (result as List).length.toDouble()));
      }

      if (mounted) {
        setState(() {
          _data = months;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _data = List.generate(12, (i) => _MonthData(_monthLabel(i + 1), 0));
          _isLoading = false;
        });
      }
    }
  }

  String _monthLabel(int month) {
    const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return labels[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return _buildChartContainer(
      title: 'User Growth',
      subtitle: 'Monthly new user registrations',
      child: SizedBox(
        height: 220,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon, strokeWidth: 2))
            : LineChart(_buildLineChartData()),
      ),
    );
  }

  LineChartData _buildLineChartData() {
    final maxY = _data.isEmpty
        ? 10.0
        : (_data.map((d) => d.value).reduce((a, b) => a > b ? a : b) * 1.2).clamp(10, double.infinity).toDouble();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 5,
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
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < _data.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _data[index].label,
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
      minX: 0,
      maxX: (_data.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            _data.length,
            (i) => FlSpot(i.toDouble(), _data[i].value),
          ),
          isCurved: true,
          curveSmoothness: 0.3,
          color: AppColors.primaryNeon,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 3,
              color: AppColors.primaryNeon,
              strokeWidth: 1.5,
              strokeColor: AppColors.surfaceCard,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryNeon.withValues(alpha: 0.25),
                AppColors.primaryNeon.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => AppColors.surfaceElevated,
          tooltipRoundedRadius: 8,
          getTooltipItems: (spots) {
            return spots.map((spot) {
              return LineTooltipItem(
                '${spot.y.toInt()} users',
                const TextStyle(
                  color: AppColors.primaryNeon,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            }).toList();
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
                  Icons.trending_up_rounded,
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

class _MonthData {
  final String label;
  final double value;

  const _MonthData(this.label, this.value);
}

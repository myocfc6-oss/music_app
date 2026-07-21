import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';

class GenreDistributionChart extends StatefulWidget {
  const GenreDistributionChart({super.key});

  @override
  State<GenreDistributionChart> createState() => _GenreDistributionChartState();
}

class _GenreDistributionChartState extends State<GenreDistributionChart> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<_GenreData> _data = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final result = await _supabase
          .from('genres_tbl')
          .select('genres_id, name');

      final genres = result as List;
      final List<_GenreData> genreData = [];

      for (final genre in genres) {
        final tracks = await _supabase
            .from('track_tbl')
            .select('track_id')
            .eq('genres_id', genre['genres_id']);

        final count = (tracks as List).length;
        if (count > 0) {
          genreData.add(_GenreData(
            genre['name'] ?? 'Unknown',
            count.toDouble(),
          ));
        }
      }

      genreData.sort((a, b) => b.value.compareTo(a.value));

      if (mounted) {
        setState(() {
          _data = genreData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _data = [];
          _isLoading = false;
        });
      }
    }
  }

  Color _barColor(int index) {
    final opacity = 1.0 - (index * 0.12).clamp(0.0, 0.7);
    return AppColors.primaryNeon.withValues(alpha: opacity);
  }

  @override
  Widget build(BuildContext context) {
    return _buildChartContainer(
      title: 'Tracks per Genre',
      subtitle: 'Distribution of tracks across genres',
      child: SizedBox(
        height: 220,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon, strokeWidth: 2))
            : _data.isEmpty
                ? const Center(
                    child: Text('No genre data available',
                        style: TextStyle(color: AppColors.textMuted)),
                  )
                : BarChart(_buildBarChartData()),
      ),
    );
  }

  BarChartData _buildBarChartData() {
    final maxY = _data.isEmpty
        ? 10.0
        : (_data.map((d) => d.value).reduce((a, b) => a > b ? a : b) * 1.3).clamp(10, double.infinity).toDouble();

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
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
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < _data.length) {
                final label = _data[index].label;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    label.length > 6 ? '${label.substring(0, 5)}..' : label,
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
        _data.length,
        (i) => BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: _data[i].value,
              color: _barColor(i),
              width: 28,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY,
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
              '${_data[group.x].label}\n${rod.toY.toInt()} tracks',
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

  const _GenreData(this.label, this.value);
}

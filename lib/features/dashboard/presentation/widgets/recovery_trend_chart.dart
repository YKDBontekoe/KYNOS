import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/features/dashboard/providers/health_history_provider.dart';

class RecoveryTrendChart extends ConsumerWidget {
  const RecoveryTrendChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(healthHistoryProvider);

    return Container(
      padding: const EdgeInsets.all(tokens.Spacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECOVERY TREND',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryLabel,
              letterSpacing: 0.8,
            ),
          ),
          const Gap(tokens.Spacing.lg),
          SizedBox(
            height: 180,
            child: historyAsync.when(
              data: (summaries) {
                if (summaries.isEmpty) {
                  return const Center(
                    child: Text(
                      'Not enough data.',
                      style: TextStyle(color: AppTheme.secondaryLabel),
                    ),
                  );
                }
                return _buildChart(summaries);
              },
              loading: () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (e, s) => const Center(
                child: Text(
                  'Failed to load history',
                  style: TextStyle(color: AppTheme.secondaryLabel),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<HealthSummary> summaries) {
    final sorted = List<HealthSummary>.from(summaries)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = <FlSpot>[];
    for (int i = 0; i < sorted.length; i++) {
      final hrv = sorted[i].hrvMs;
      if (hrv != null) {
        spots.add(FlSpot(i.toDouble(), hrv));
      }
    }

    if (spots.isEmpty) {
      return const Center(
        child: Text(
          'No HRV data recorded.',
          style: TextStyle(color: AppTheme.secondaryLabel),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.separator.withValues(alpha: 0.5),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    value.toInt().toString(),
                    style: GoogleFonts.inter(
                      color: AppTheme.secondaryLabel,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= sorted.length) return const SizedBox.shrink();
                final date = sorted[idx].date;
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    days[date.weekday - 1],
                    style: GoogleFonts.inter(
                      color: AppTheme.secondaryLabel,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.exercise,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: AppTheme.exercise,
                strokeWidth: 2,
                strokeColor: AppTheme.card,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.exercise.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

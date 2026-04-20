import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/utils/readiness_calculator.dart';
import 'package:kynos/features/dashboard/presentation/widgets/activity_ring.dart';
import 'package:kynos/features/dashboard/providers/health_provider.dart';

class ReadinessCard extends ConsumerWidget {
  const ReadinessCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthSummaryAsync = ref.watch(healthSummaryProvider);

    final score = healthSummaryAsync.when(
      data: (summary) => calculateReadiness(summary),
      loading: () => 0,
      error: (_, _) => 0,
    );

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          ActivityRing(
            progress: healthSummaryAsync.when(
              data: (summary) => summary != null ? score / 100.0 : 0.0,
              loading: () => 0.0,
              error: (e, s) => 0.0,
            ),
            size: 80,
            strokeWidth: 8,
            colors: const [AppTheme.move, AppTheme.exercise, AppTheme.stand],
          ),
          const Gap(20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'READINESS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryLabel,
                    letterSpacing: 0.8,
                  ),
                ),
                const Gap(4),
                healthSummaryAsync.when(
                  data: (summary) => Text(
                    summary != null ? score.toString() : '—',
                    style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: summary != null ? AppTheme.purple : AppTheme.label,
                      height: 1,
                      letterSpacing: -1,
                    ),
                  ),
                  loading: () => const SizedBox(
                    height: 40,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (e, s) => Text(
                    'Error',
                    style: GoogleFonts.inter(fontSize: 24, color: Colors.red),
                  ),
                ),
                const Gap(6),
                Text(
                  healthSummaryAsync.when(
                    data: (summary) => summary != null
                        ? (score >= 60
                              ? 'Great recovery. Optimal conditions for a high-intensity interval run today.'
                              : 'Recovery focus. Prioritise stretching and rest today.')
                        : 'Connect HealthKit to unlock your daily readiness.',
                    loading: () => 'Calculating readiness...',
                    error: (e, s) => 'Could not calculate readiness.',
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.secondaryLabel,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

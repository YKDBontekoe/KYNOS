import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/features/dashboard/providers/coach_insight_provider.dart';
import 'package:shimmer/shimmer.dart';

class CoachInsightCard extends ConsumerWidget {
  const CoachInsightCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightAsync = ref.watch(coachInsightProvider);

    return Container(
      padding: const EdgeInsets.all(tokens.Spacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.purple.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.purple.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppTheme.purple,
                size: 18,
              ),
              const Gap(8),
              Text(
                "COACH's INSIGHT",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.purple,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const Gap(tokens.Spacing.md),
          insightAsync.when(
            data: (text) => text.isEmpty
                ? const _InsightSkeleton()
                : Text(
                    text,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.5,
                      color: AppTheme.label,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
            loading: () => const _InsightSkeleton(),
            error: (e, s) => Text(
              "Let's focus on consistency today.",
              style: GoogleFonts.inter(
                fontSize: 15,
                height: 1.5,
                color: AppTheme.label,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightSkeleton extends StatelessWidget {
  const _InsightSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.separator,
      highlightColor: AppTheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 14,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.separator,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Gap(8),
          Container(
            height: 14,
            width: 200,
            decoration: BoxDecoration(
              color: AppTheme.separator,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

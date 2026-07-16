import 'package:kynos/domain/entities/coach/training_plan.dart';

/// Source of the deterministic “do this today” directive.
enum TodayDirectiveSource { plan, readinessFallback, buildPlanCta }

/// Resolved coaching directive shown on the coach home surface.
class TodayDirective {
  const TodayDirective({
    required this.headline,
    required this.detail,
    required this.source,
    required this.rationale,
    this.sessionType,
    this.targetDistanceKm,
    this.targetDurationMinutes,
    this.adherence = PlanAdherenceStatus.pending,
    this.forcedRecovery = false,
    this.ctaLabel,
  });

  final String headline;
  final String detail;
  final TodayDirectiveSource source;
  final List<String> rationale;
  final PlanSessionType? sessionType;
  final double? targetDistanceKm;
  final int? targetDurationMinutes;
  final PlanAdherenceStatus adherence;
  final bool forcedRecovery;
  final String? ctaLabel;

  String get promptSeed {
    if (source == TodayDirectiveSource.buildPlanCta) {
      return 'Build my multi-week training plan based on my goals.';
    }
    if (forcedRecovery) {
      return 'Why am I on recovery today, and what should I do instead?';
    }
    return 'Walk me through today’s session: $headline';
  }
}

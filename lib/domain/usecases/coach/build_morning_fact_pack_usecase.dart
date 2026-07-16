import 'package:kynos/core/constants/app_constants.dart';
import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/entities/coach/daily_coach_brief.dart';
import 'package:kynos/domain/entities/coach/today_directive.dart';

/// Compact, deterministic morning signals for small on-device models.
///
/// Precomputed in Dart so constrained Gemma often needs zero tool calls.
class MorningFactPack {
  const MorningFactPack({
    required this.readinessScore,
    required this.readinessBand,
    required this.acwrBand,
    required this.sleepHours,
    required this.hrvMs,
    required this.directiveTitle,
    required this.directiveSessionType,
    required this.briefRecommendation,
    required this.riskFlags,
    required this.promptBlock,
  });

  final int readinessScore;
  final String readinessBand;
  final String acwrBand;
  final double? sleepHours;
  final double? hrvMs;
  final String? directiveTitle;
  final String? directiveSessionType;
  final String? briefRecommendation;
  final List<String> riskFlags;

  /// ~220-char fact block safe to prepend into constrained prompts.
  final String promptBlock;

  bool get hasRisk => riskFlags.isNotEmpty;
}

class BuildMorningFactPackUseCase {
  const BuildMorningFactPackUseCase();

  MorningFactPack call({
    required CoachContext context,
    DailyCoachBrief? brief,
    TodayDirective? directive,
  }) {
    final today = context.healthHistory.isEmpty
        ? null
        : (List.of(context.healthHistory)
              ..sort((a, b) => b.date.compareTo(a.date)))
            .first;
    final readiness = context.readinessScore.round();
    final acwr = context.acwr;
    final sleep = today?.sleepHours;
    final hrv = today?.hrvMs;

    final readinessBand = switch (readiness) {
      >= 75 => 'high',
      >= 55 => 'moderate',
      _ => 'low',
    };
    final acwrBand = switch (acwr) {
      null => 'unknown',
      > AppConstants.acwrSafeMax => 'elevated',
      >= 0.8 => 'productive',
      _ => 'light',
    };

    final flags = <String>[
      if (acwr != null && acwr > AppConstants.acwrSafeMax)
        'ACWR ${acwr.toStringAsFixed(2)} above safe max',
      if (sleep != null && sleep < 6.5)
        'sleep ${sleep.toStringAsFixed(1)}h',
      if (hrv != null && hrv < 35) 'HRV ${hrv.round()}ms low',
      if (readiness < 50) 'readiness $readiness low',
    ];

    final resolvedBrief = brief ?? context.dailyBrief;
    final resolvedDirective = directive ?? context.todayDirective;

    final parts = <String>[
      'readiness $readiness ($readinessBand)',
      if (sleep != null) 'sleep ${sleep.toStringAsFixed(1)}h',
      if (hrv != null) 'HRV ${hrv.round()}ms',
      'ACWR $acwrBand',
      if (resolvedDirective != null)
        'today ${resolvedDirective.sessionType?.name ?? 'session'}: ${resolvedDirective.headline}',
      if (resolvedBrief != null) resolvedBrief.recommendation,
      if (flags.isNotEmpty) 'risk: ${flags.join('; ')}',
    ];

    var promptBlock = 'MORNING: ${parts.join(' | ')}';
    if (promptBlock.length > 220) {
      promptBlock = '${promptBlock.substring(0, 217)}...';
    }

    return MorningFactPack(
      readinessScore: readiness,
      readinessBand: readinessBand,
      acwrBand: acwrBand,
      sleepHours: sleep,
      hrvMs: hrv,
      directiveTitle: resolvedDirective?.headline,
      directiveSessionType: resolvedDirective?.sessionType?.name,
      briefRecommendation: resolvedBrief?.recommendation,
      riskFlags: flags,
      promptBlock: promptBlock,
    );
  }
}

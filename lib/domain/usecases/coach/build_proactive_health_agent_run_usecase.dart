import 'package:kynos/core/constants/app_constants.dart';
import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/usecases/coach/build_morning_fact_pack_usecase.dart';

/// Kind of proactive health-agent run seeded into coach chat.
enum ProactiveHealthAgentKind {
  morningPulse,
  postRunDebrief,
  riskRadar,
  experimentLoop,
}

/// Deterministic proactive coaching card + optional chat seed prompt.
class ProactiveHealthAgentRun {
  const ProactiveHealthAgentRun({
    required this.kind,
    required this.headline,
    required this.detail,
    required this.seedPrompt,
    this.riskFlags = const [],
  });

  final ProactiveHealthAgentKind kind;
  final String headline;
  final String detail;
  final String seedPrompt;
  final List<String> riskFlags;
}

/// Builds proactive health-agent runs without LLM inference.
///
/// Tools/Dart own the analysis; the LLM only narrates when the user engages.
class BuildProactiveHealthAgentRunUseCase {
  const BuildProactiveHealthAgentRunUseCase();

  /// Morning pulse from readiness + brief + today directive.
  ProactiveHealthAgentRun morningPulse({
    required CoachContext context,
    MorningFactPack? factPack,
  }) {
    final pack =
        factPack ?? const BuildMorningFactPackUseCase().call(context: context);
    final directive = context.todayDirective;
    final headline = directive?.headline ?? 'Morning pulse';
    final detail = pack.hasRisk
        ? 'Signals flag recovery bias (${pack.riskFlags.take(2).join(', ')}). '
            '${pack.briefRecommendation ?? 'Start easy and reassess.'}'
        : 'Readiness ${pack.readinessScore} (${pack.readinessBand}). '
            '${directive?.detail ?? pack.briefRecommendation ?? 'Train as planned.'}';

    return ProactiveHealthAgentRun(
      kind: ProactiveHealthAgentKind.morningPulse,
      headline: headline,
      detail: detail,
      seedPrompt: directive?.promptSeed ??
          'Give me today’s coaching pulse from my readiness and plan.',
      riskFlags: pack.riskFlags,
    );
  }

  /// Post-run debrief when a recent run and optional summary exist.
  ProactiveHealthAgentRun? postRunDebrief({
    required CoachContext context,
  }) {
    if (context.recentRuns.isEmpty) return null;
    final run = context.recentRuns.first;
    final summary = context.postRunDebriefSummary;
    final km = (run.distanceMeters ?? 0) / 1000;
    final detail = summary ??
        'Latest run ${km.toStringAsFixed(1)} km. '
            'Review splits and how this lands on training load.';

    return ProactiveHealthAgentRun(
      kind: ProactiveHealthAgentKind.postRunDebrief,
      headline: 'Post-run debrief',
      detail: detail,
      seedPrompt:
          'Debrief my latest run: pace splits, load impact, and recovery focus.',
    );
  }

  /// Risk radar when ACWR or multi-signal recovery risk is elevated.
  ProactiveHealthAgentRun? riskRadar({
    required CoachContext context,
    MorningFactPack? factPack,
  }) {
    final pack =
        factPack ?? const BuildMorningFactPackUseCase().call(context: context);
    final acwr = context.acwr;
    final elevatedLoad = acwr != null && acwr > AppConstants.acwrSafeMax;
    if (!elevatedLoad && !pack.hasRisk) return null;

    return ProactiveHealthAgentRun(
      kind: ProactiveHealthAgentKind.riskRadar,
      headline: 'Risk radar',
      detail: pack.riskFlags.isEmpty
          ? 'Training load looks elevated — consider dialing today back.'
          : pack.riskFlags.take(3).join(' · '),
      seedPrompt: elevatedLoad
          ? 'My ACWR is elevated. Explain the risk and propose adjusting '
              'today’s session with adjust_plan_week if needed.'
          : 'My risk radar is up. Explain the signals and whether I should '
              'adjust today’s session.',
      riskFlags: pack.riskFlags,
    );
  }

  /// Closes the loop on an active wellbeing experiment.
  ProactiveHealthAgentRun? experimentLoop({
    required CoachContext context,
  }) {
    final active = context.wellbeingExperiments
        .where((e) => e.status == ExperimentStatus.active)
        .toList();
    if (active.isEmpty) return null;
    final experiment = active.first;
    final days = experiment.logs.length;
    final adhered = experiment.logs.where((l) => l.adhered).length;
    final detail =
        '${experiment.title}: day $days of ${experiment.durationDays}. '
        'Adhered $adhered/${experiment.logs.isEmpty ? experiment.durationDays : experiment.logs.length}. '
        'Hypothesis: ${experiment.hypothesis}';

    return ProactiveHealthAgentRun(
      kind: ProactiveHealthAgentKind.experimentLoop,
      headline: 'Experiment check-in',
      detail: detail,
      seedPrompt:
          'Review my wellbeing experiment "${experiment.title}" against the '
          'hypothesis and suggest whether to continue, tweak, or stop.',
    );
  }

  /// Ordered runs to surface on coach home (at most one of each kind).
  List<ProactiveHealthAgentRun> buildHomeRuns({
    required CoachContext context,
  }) {
    final pack = const BuildMorningFactPackUseCase().call(context: context);
    return [
      morningPulse(context: context, factPack: pack),
      ?riskRadar(context: context, factPack: pack),
      ?postRunDebrief(context: context),
      ?experimentLoop(context: context),
    ];
  }
}

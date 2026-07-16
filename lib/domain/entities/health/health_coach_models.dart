import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kynos/domain/entities/health/health_metric.dart';

part 'health_coach_models.freezed.dart';
part 'health_coach_models.g.dart';

enum BaselineQuality { learning, stable }

enum FindingConfidence { low, moderate, high }

enum FindingBasis { measured, selfReported, inferred }

enum ExperimentStatus { proposed, active, completed, cancelled }

enum CoachActionType { createExperiment, saveMemory, activateTrainingPlan }

@freezed
abstract class HealthCheckIn with _$HealthCheckIn {
  const factory HealthCheckIn({
    required DateTime date,
    required int energy,
    required int mood,
    required int stress,
    required int soreness,
    @Default(false) bool feelingUnwell,
    String? note,
  }) = _HealthCheckIn;

  factory HealthCheckIn.fromJson(Map<String, Object?> json) =>
      _$HealthCheckInFromJson(json);
}

@freezed
abstract class PersonalBaseline with _$PersonalBaseline {
  const factory PersonalBaseline({
    required HealthMetric metric,
    required int observationCount,
    required double median,
    required double medianAbsoluteDeviation,
    required DateTime start,
    required DateTime end,
    required BaselineQuality quality,
  }) = _PersonalBaseline;

  factory PersonalBaseline.fromJson(Map<String, Object?> json) =>
      _$PersonalBaselineFromJson(json);
}

@freezed
abstract class HealthFinding with _$HealthFinding {
  const factory HealthFinding({
    required String id,
    required String observation,
    required List<String> evidence,
    required FindingConfidence confidence,
    required FindingBasis basis,
    @Default(<String>[]) List<String> limitations,
    HealthMetric? metric,
  }) = _HealthFinding;

  factory HealthFinding.fromJson(Map<String, Object?> json) =>
      _$HealthFindingFromJson(json);
}

@freezed
abstract class DailyHealthBrief with _$DailyHealthBrief {
  const factory DailyHealthBrief({
    required DateTime date,
    required String bodyStateSummary,
    required List<HealthFinding> findings,
    required String primaryAction,
    required String alternativeAction,
    required String fingerprint,
    required BaselineQuality baselineQuality,
  }) = _DailyHealthBrief;

  factory DailyHealthBrief.fromJson(Map<String, Object?> json) =>
      _$DailyHealthBriefFromJson(json);
}

@freezed
abstract class CoachMemory with _$CoachMemory {
  const factory CoachMemory({
    required String id,
    required String fact,
    required String provenance,
    required DateTime createdAt,
    @Default(false) bool confirmed,
  }) = _CoachMemory;

  factory CoachMemory.fromJson(Map<String, Object?> json) =>
      _$CoachMemoryFromJson(json);
}

@freezed
abstract class ExperimentLog with _$ExperimentLog {
  const factory ExperimentLog({
    required DateTime date,
    required bool adhered,
    int? energy,
    int? mood,
    String? note,
  }) = _ExperimentLog;

  factory ExperimentLog.fromJson(Map<String, Object?> json) =>
      _$ExperimentLogFromJson(json);
}

@freezed
abstract class WellbeingExperiment with _$WellbeingExperiment {
  const factory WellbeingExperiment({
    required String id,
    required String title,
    required String action,
    required String hypothesis,
    required int durationDays,
    required DateTime createdAt,
    required ExperimentStatus status,
    required List<HealthMetric> outcomeMetrics,
    @Default(<ExperimentLog>[]) List<ExperimentLog> logs,
    String? result,
  }) = _WellbeingExperiment;

  factory WellbeingExperiment.fromJson(Map<String, Object?> json) =>
      _$WellbeingExperimentFromJson(json);
}

@freezed
abstract class PendingCoachAction with _$PendingCoachAction {
  const factory PendingCoachAction({
    required String id,
    required CoachActionType type,
    required String title,
    required String explanation,
    required Map<String, Object?> payload,
  }) = _PendingCoachAction;

  factory PendingCoachAction.fromJson(Map<String, Object?> json) =>
      _$PendingCoachActionFromJson(json);
}

@freezed
abstract class HealthCoachState with _$HealthCoachState {
  const factory HealthCoachState({
    @Default(<HealthCheckIn>[]) List<HealthCheckIn> checkIns,
    @Default(<CoachMemory>[]) List<CoachMemory> memories,
    @Default(<WellbeingExperiment>[]) List<WellbeingExperiment> experiments,
  }) = _HealthCoachState;

  factory HealthCoachState.fromJson(Map<String, Object?> json) =>
      _$HealthCoachStateFromJson(json);
}

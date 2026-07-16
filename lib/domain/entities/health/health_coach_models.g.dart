// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_coach_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HealthCheckIn _$HealthCheckInFromJson(Map<String, dynamic> json) =>
    _HealthCheckIn(
      date: DateTime.parse(json['date'] as String),
      energy: (json['energy'] as num).toInt(),
      mood: (json['mood'] as num).toInt(),
      stress: (json['stress'] as num).toInt(),
      soreness: (json['soreness'] as num).toInt(),
      feelingUnwell: json['feelingUnwell'] as bool? ?? false,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$HealthCheckInToJson(_HealthCheckIn instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'energy': instance.energy,
      'mood': instance.mood,
      'stress': instance.stress,
      'soreness': instance.soreness,
      'feelingUnwell': instance.feelingUnwell,
      'note': instance.note,
    };

_PersonalBaseline _$PersonalBaselineFromJson(Map<String, dynamic> json) =>
    _PersonalBaseline(
      metric: $enumDecode(_$HealthMetricEnumMap, json['metric']),
      observationCount: (json['observationCount'] as num).toInt(),
      median: (json['median'] as num).toDouble(),
      medianAbsoluteDeviation: (json['medianAbsoluteDeviation'] as num)
          .toDouble(),
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      quality: $enumDecode(_$BaselineQualityEnumMap, json['quality']),
    );

Map<String, dynamic> _$PersonalBaselineToJson(_PersonalBaseline instance) =>
    <String, dynamic>{
      'metric': _$HealthMetricEnumMap[instance.metric]!,
      'observationCount': instance.observationCount,
      'median': instance.median,
      'medianAbsoluteDeviation': instance.medianAbsoluteDeviation,
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'quality': _$BaselineQualityEnumMap[instance.quality]!,
    };

const _$HealthMetricEnumMap = {
  HealthMetric.hrv: 'hrv',
  HealthMetric.restingHeartRate: 'restingHeartRate',
  HealthMetric.averageHeartRate: 'averageHeartRate',
  HealthMetric.respiratoryRate: 'respiratoryRate',
  HealthMetric.bloodOxygen: 'bloodOxygen',
  HealthMetric.sleep: 'sleep',
  HealthMetric.steps: 'steps',
  HealthMetric.distance: 'distance',
  HealthMetric.exerciseTime: 'exerciseTime',
  HealthMetric.activeEnergy: 'activeEnergy',
  HealthMetric.totalEnergy: 'totalEnergy',
  HealthMetric.selfReportedEnergy: 'selfReportedEnergy',
  HealthMetric.selfReportedMood: 'selfReportedMood',
  HealthMetric.selfReportedStress: 'selfReportedStress',
};

const _$BaselineQualityEnumMap = {
  BaselineQuality.learning: 'learning',
  BaselineQuality.stable: 'stable',
};

_HealthFinding _$HealthFindingFromJson(Map<String, dynamic> json) =>
    _HealthFinding(
      id: json['id'] as String,
      observation: json['observation'] as String,
      evidence: (json['evidence'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      confidence: $enumDecode(_$FindingConfidenceEnumMap, json['confidence']),
      basis: $enumDecode(_$FindingBasisEnumMap, json['basis']),
      limitations:
          (json['limitations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      metric: $enumDecodeNullable(_$HealthMetricEnumMap, json['metric']),
    );

Map<String, dynamic> _$HealthFindingToJson(_HealthFinding instance) =>
    <String, dynamic>{
      'id': instance.id,
      'observation': instance.observation,
      'evidence': instance.evidence,
      'confidence': _$FindingConfidenceEnumMap[instance.confidence]!,
      'basis': _$FindingBasisEnumMap[instance.basis]!,
      'limitations': instance.limitations,
      'metric': _$HealthMetricEnumMap[instance.metric],
    };

const _$FindingConfidenceEnumMap = {
  FindingConfidence.low: 'low',
  FindingConfidence.moderate: 'moderate',
  FindingConfidence.high: 'high',
};

const _$FindingBasisEnumMap = {
  FindingBasis.measured: 'measured',
  FindingBasis.selfReported: 'selfReported',
  FindingBasis.inferred: 'inferred',
};

_DailyHealthBrief _$DailyHealthBriefFromJson(Map<String, dynamic> json) =>
    _DailyHealthBrief(
      date: DateTime.parse(json['date'] as String),
      bodyStateSummary: json['bodyStateSummary'] as String,
      findings: (json['findings'] as List<dynamic>)
          .map((e) => HealthFinding.fromJson(e as Map<String, dynamic>))
          .toList(),
      primaryAction: json['primaryAction'] as String,
      alternativeAction: json['alternativeAction'] as String,
      fingerprint: json['fingerprint'] as String,
      baselineQuality: $enumDecode(
        _$BaselineQualityEnumMap,
        json['baselineQuality'],
      ),
    );

Map<String, dynamic> _$DailyHealthBriefToJson(_DailyHealthBrief instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'bodyStateSummary': instance.bodyStateSummary,
      'findings': instance.findings,
      'primaryAction': instance.primaryAction,
      'alternativeAction': instance.alternativeAction,
      'fingerprint': instance.fingerprint,
      'baselineQuality': _$BaselineQualityEnumMap[instance.baselineQuality]!,
    };

_CoachMemory _$CoachMemoryFromJson(Map<String, dynamic> json) => _CoachMemory(
  id: json['id'] as String,
  fact: json['fact'] as String,
  provenance: json['provenance'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  confirmed: json['confirmed'] as bool? ?? false,
);

Map<String, dynamic> _$CoachMemoryToJson(_CoachMemory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fact': instance.fact,
      'provenance': instance.provenance,
      'createdAt': instance.createdAt.toIso8601String(),
      'confirmed': instance.confirmed,
    };

_ExperimentLog _$ExperimentLogFromJson(Map<String, dynamic> json) =>
    _ExperimentLog(
      date: DateTime.parse(json['date'] as String),
      adhered: json['adhered'] as bool,
      energy: (json['energy'] as num?)?.toInt(),
      mood: (json['mood'] as num?)?.toInt(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$ExperimentLogToJson(_ExperimentLog instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'adhered': instance.adhered,
      'energy': instance.energy,
      'mood': instance.mood,
      'note': instance.note,
    };

_WellbeingExperiment _$WellbeingExperimentFromJson(Map<String, dynamic> json) =>
    _WellbeingExperiment(
      id: json['id'] as String,
      title: json['title'] as String,
      action: json['action'] as String,
      hypothesis: json['hypothesis'] as String,
      durationDays: (json['durationDays'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: $enumDecode(_$ExperimentStatusEnumMap, json['status']),
      outcomeMetrics: (json['outcomeMetrics'] as List<dynamic>)
          .map((e) => $enumDecode(_$HealthMetricEnumMap, e))
          .toList(),
      logs:
          (json['logs'] as List<dynamic>?)
              ?.map((e) => ExperimentLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ExperimentLog>[],
      result: json['result'] as String?,
    );

Map<String, dynamic> _$WellbeingExperimentToJson(
  _WellbeingExperiment instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'action': instance.action,
  'hypothesis': instance.hypothesis,
  'durationDays': instance.durationDays,
  'createdAt': instance.createdAt.toIso8601String(),
  'status': _$ExperimentStatusEnumMap[instance.status]!,
  'outcomeMetrics': instance.outcomeMetrics
      .map((e) => _$HealthMetricEnumMap[e]!)
      .toList(),
  'logs': instance.logs,
  'result': instance.result,
};

const _$ExperimentStatusEnumMap = {
  ExperimentStatus.proposed: 'proposed',
  ExperimentStatus.active: 'active',
  ExperimentStatus.completed: 'completed',
  ExperimentStatus.cancelled: 'cancelled',
};

_PendingCoachAction _$PendingCoachActionFromJson(Map<String, dynamic> json) =>
    _PendingCoachAction(
      id: json['id'] as String,
      type: $enumDecode(_$CoachActionTypeEnumMap, json['type']),
      title: json['title'] as String,
      explanation: json['explanation'] as String,
      payload: json['payload'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$PendingCoachActionToJson(_PendingCoachAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$CoachActionTypeEnumMap[instance.type]!,
      'title': instance.title,
      'explanation': instance.explanation,
      'payload': instance.payload,
    };

const _$CoachActionTypeEnumMap = {
  CoachActionType.createExperiment: 'createExperiment',
  CoachActionType.saveMemory: 'saveMemory',
  CoachActionType.activateTrainingPlan: 'activateTrainingPlan',
};

_HealthCoachState _$HealthCoachStateFromJson(Map<String, dynamic> json) =>
    _HealthCoachState(
      checkIns:
          (json['checkIns'] as List<dynamic>?)
              ?.map((e) => HealthCheckIn.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <HealthCheckIn>[],
      memories:
          (json['memories'] as List<dynamic>?)
              ?.map((e) => CoachMemory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CoachMemory>[],
      experiments:
          (json['experiments'] as List<dynamic>?)
              ?.map(
                (e) => WellbeingExperiment.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <WellbeingExperiment>[],
    );

Map<String, dynamic> _$HealthCoachStateToJson(_HealthCoachState instance) =>
    <String, dynamic>{
      'checkIns': instance.checkIns,
      'memories': instance.memories,
      'experiments': instance.experiments,
    };

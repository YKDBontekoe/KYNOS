/// Session types the coach may prescribe on a plan day.
enum PlanSessionType {
  rest,
  easy,
  longRun,
  tempo,
  intervals,
  recovery,
  race,
}

/// Adherence status for a prescribed day.
enum PlanAdherenceStatus { pending, done, skipped, swapped }

/// One day inside a multi-week training plan.
class PlanDay {
  const PlanDay({
    required this.date,
    required this.sessionType,
    required this.title,
    this.targetDistanceKm,
    this.targetDurationMinutes,
    this.intensityNote,
    this.notes,
    this.adherence = PlanAdherenceStatus.pending,
    this.adherenceNote,
  });

  final DateTime date;
  final PlanSessionType sessionType;
  final String title;
  final double? targetDistanceKm;
  final int? targetDurationMinutes;
  final String? intensityNote;
  final String? notes;
  final PlanAdherenceStatus adherence;
  final String? adherenceNote;

  DateTime get dayKey => DateTime(date.year, date.month, date.day);

  PlanDay copyWith({
    DateTime? date,
    PlanSessionType? sessionType,
    String? title,
    double? targetDistanceKm,
    int? targetDurationMinutes,
    String? intensityNote,
    String? notes,
    PlanAdherenceStatus? adherence,
    String? adherenceNote,
  }) => PlanDay(
    date: date ?? this.date,
    sessionType: sessionType ?? this.sessionType,
    title: title ?? this.title,
    targetDistanceKm: targetDistanceKm ?? this.targetDistanceKm,
    targetDurationMinutes: targetDurationMinutes ?? this.targetDurationMinutes,
    intensityNote: intensityNote ?? this.intensityNote,
    notes: notes ?? this.notes,
    adherence: adherence ?? this.adherence,
    adherenceNote: adherenceNote ?? this.adherenceNote,
  );

  Map<String, Object?> toJson() => {
    'date': date.toIso8601String(),
    'sessionType': sessionType.name,
    'title': title,
    'targetDistanceKm': targetDistanceKm,
    'targetDurationMinutes': targetDurationMinutes,
    'intensityNote': intensityNote,
    'notes': notes,
    'adherence': adherence.name,
    'adherenceNote': adherenceNote,
  };

  factory PlanDay.fromJson(Map<String, Object?> json) {
    return PlanDay(
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      sessionType: PlanSessionType.values.firstWhere(
        (value) => value.name == json['sessionType'],
        orElse: () => PlanSessionType.easy,
      ),
      title: json['title'] as String? ?? 'Session',
      targetDistanceKm: (json['targetDistanceKm'] as num?)?.toDouble(),
      targetDurationMinutes: (json['targetDurationMinutes'] as num?)?.toInt(),
      intensityNote: json['intensityNote'] as String?,
      notes: json['notes'] as String?,
      adherence: PlanAdherenceStatus.values.firstWhere(
        (value) => value.name == json['adherence'],
        orElse: () => PlanAdherenceStatus.pending,
      ),
      adherenceNote: json['adherenceNote'] as String?,
    );
  }
}

/// Multi-week training plan owned by the assertive coach.
class TrainingPlan {
  const TrainingPlan({
    required this.id,
    required this.title,
    required this.goal,
    required this.startDate,
    required this.weeks,
    required this.days,
    required this.createdAt,
    this.weeklyVolumeTargetKm,
    this.longRunWeekday = DateTime.sunday,
    this.active = true,
  });

  final String id;
  final String title;
  final String goal;
  final DateTime startDate;
  final int weeks;
  final List<PlanDay> days;
  final DateTime createdAt;
  final double? weeklyVolumeTargetKm;
  final int longRunWeekday;
  final bool active;

  PlanDay? dayFor(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    for (final day in days) {
      if (day.dayKey == key) return day;
    }
    return null;
  }

  TrainingPlan copyWith({
    String? id,
    String? title,
    String? goal,
    DateTime? startDate,
    int? weeks,
    List<PlanDay>? days,
    DateTime? createdAt,
    double? weeklyVolumeTargetKm,
    int? longRunWeekday,
    bool? active,
  }) => TrainingPlan(
    id: id ?? this.id,
    title: title ?? this.title,
    goal: goal ?? this.goal,
    startDate: startDate ?? this.startDate,
    weeks: weeks ?? this.weeks,
    days: days ?? this.days,
    createdAt: createdAt ?? this.createdAt,
    weeklyVolumeTargetKm: weeklyVolumeTargetKm ?? this.weeklyVolumeTargetKm,
    longRunWeekday: longRunWeekday ?? this.longRunWeekday,
    active: active ?? this.active,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'goal': goal,
    'startDate': startDate.toIso8601String(),
    'weeks': weeks,
    'days': days.map((day) => day.toJson()).toList(growable: false),
    'createdAt': createdAt.toIso8601String(),
    'weeklyVolumeTargetKm': weeklyVolumeTargetKm,
    'longRunWeekday': longRunWeekday,
    'active': active,
  };

  factory TrainingPlan.fromJson(Map<String, Object?> json) {
    final rawDays = json['days'] as List<dynamic>? ?? const [];
    return TrainingPlan(
      id: json['id'] as String? ?? 'plan',
      title: json['title'] as String? ?? 'Training plan',
      goal: json['goal'] as String? ?? 'general fitness',
      startDate:
          DateTime.tryParse(json['startDate'] as String? ?? '') ??
          DateTime.now(),
      weeks: (json['weeks'] as num?)?.toInt() ?? 4,
      days: [
        for (final item in rawDays)
          if (item is Map<String, Object?>) PlanDay.fromJson(item)
          else if (item is Map)
            PlanDay.fromJson(Map<String, Object?>.from(item)),
      ],
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      weeklyVolumeTargetKm: (json['weeklyVolumeTargetKm'] as num?)?.toDouble(),
      longRunWeekday: (json['longRunWeekday'] as num?)?.toInt() ?? DateTime.sunday,
      active: json['active'] as bool? ?? true,
    );
  }
}

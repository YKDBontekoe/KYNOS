/// Runner preferences that sensors cannot infer.
class AthleteCoachProfile {
  const AthleteCoachProfile({
    this.goal = 'general fitness',
    this.eventDate,
    this.experience = 'recreational',
    this.preferredTrainingDays = const [],
    this.safetyAcknowledged = false,
  });

  final String goal;
  final DateTime? eventDate;
  final String experience;
  final List<int> preferredTrainingDays;
  final bool safetyAcknowledged;

  AthleteCoachProfile copyWith({
    String? goal,
    DateTime? eventDate,
    String? experience,
    List<int>? preferredTrainingDays,
    bool? safetyAcknowledged,
  }) => AthleteCoachProfile(
    goal: goal ?? this.goal,
    eventDate: eventDate ?? this.eventDate,
    experience: experience ?? this.experience,
    preferredTrainingDays: preferredTrainingDays ?? this.preferredTrainingDays,
    safetyAcknowledged: safetyAcknowledged ?? this.safetyAcknowledged,
  );

  Map<String, dynamic> toJson() => {
    'goal': goal,
    'event_date': eventDate?.toIso8601String(),
    'experience': experience,
    'preferred_training_days': preferredTrainingDays,
    'safety_acknowledged': safetyAcknowledged,
  };

  factory AthleteCoachProfile.fromJson(Map<String, dynamic> json) {
    final days = (json['preferred_training_days'] as List<dynamic>? ?? [])
        .whereType<num>()
        .map((day) => day.toInt())
        .where((day) => day >= 1 && day <= 7)
        .toList();
    return AthleteCoachProfile(
      goal: json['goal'] as String? ?? 'general fitness',
      eventDate: DateTime.tryParse(json['event_date'] as String? ?? ''),
      experience: json['experience'] as String? ?? 'recreational',
      preferredTrainingDays: days,
      safetyAcknowledged: json['safety_acknowledged'] as bool? ?? false,
    );
  }
}

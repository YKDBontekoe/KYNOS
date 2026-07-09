/// Optional subjective recovery input captured before the day's advice.
class MorningCheckIn {
  const MorningCheckIn({
    required this.date,
    required this.fatigue,
    required this.soreness,
    required this.motivation,
  });

  final DateTime date;
  final int fatigue;
  final int soreness;
  final int motivation;

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'fatigue': fatigue,
    'soreness': soreness,
    'motivation': motivation,
  };

  factory MorningCheckIn.fromJson(Map<String, dynamic> json) => MorningCheckIn(
    date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    fatigue: _clamp(json['fatigue'] as num? ?? 0),
    soreness: _clamp(json['soreness'] as num? ?? 0),
    motivation: _clamp(json['motivation'] as num? ?? 0),
  );

  static int _clamp(num value) => value.round().clamp(0, 10);
}

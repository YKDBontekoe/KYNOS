import 'package:kynos/domain/entities/gamification/character_stats.dart';

/// Outcome of spending Spirit on a run expedition.
class ExpeditionEvent {
  const ExpeditionEvent({
    required this.title,
    required this.narrative,
    required this.xpReward,
    this.statDeltas = const {},
    this.summitBonus = 0,
  });

  final String title;
  final String narrative;
  final int xpReward;
  final Map<CharacterStatId, int> statDeltas;
  final int summitBonus;

  Map<String, dynamic> toJson() => {
        'title': title,
        'narrative': narrative,
        'xp_reward': xpReward,
        'stat_deltas': statDeltas.map(
          (k, v) => MapEntry(k.name, v),
        ),
        'summit_bonus': summitBonus,
      };

  factory ExpeditionEvent.fromJson(Map<String, dynamic> json) {
    final rawDeltas = json['stat_deltas'] as Map<String, dynamic>? ?? {};
    final deltas = <CharacterStatId, int>{};
    for (final entry in rawDeltas.entries) {
      final id = CharacterStatId.values.firstWhere(
        (s) => s.name == entry.key,
        orElse: () => CharacterStatId.endurance,
      );
      deltas[id] = (entry.value as num).toInt();
    }
    return ExpeditionEvent(
      title: json['title'] as String? ?? 'Expedition',
      narrative: json['narrative'] as String? ?? '',
      xpReward: (json['xp_reward'] as num?)?.toInt() ?? 0,
      statDeltas: deltas,
      summitBonus: (json['summit_bonus'] as num?)?.toInt() ?? 0,
    );
  }
}

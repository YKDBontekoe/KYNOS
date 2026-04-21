sealed class CharacterClass {
  const CharacterClass();

  String get id;
  String get name;
  String get epithet;
  String get lore;
  String get signatoryPower;
  String get powerDescription;

  /// ARGB color representing this class.
  int get colorValue;

  static CharacterClass fromId(String id) => switch (id) {
        'phantom' => const Phantom(),
        'iron' => const Iron(),
        'surge' => const Surge(),
        'sage' => const Sage(),
        _ => const Apex(),
      };
}

final class Phantom extends CharacterClass {
  const Phantom();

  @override
  String get id => 'phantom';

  @override
  String get name => 'The Phantom';

  @override
  String get epithet => 'Ghost in the machine';

  @override
  String get lore =>
      'High cadence, featherlight footstrike. You vanish before they notice you were ever there.';

  @override
  String get signatoryPower => 'Ghost Mode';

  @override
  String get powerDescription =>
      'Invisible on weekly leaderboards. You hunt — not the other way around.';

  @override
  int get colorValue => 0xFF8B5CF6;
}

final class Iron extends CharacterClass {
  const Iron();

  @override
  String get id => 'iron';

  @override
  String get name => 'The Iron';

  @override
  String get epithet => "The Iron doesn't break";

  @override
  String get lore =>
      'High load tolerance, relentless base building. Fatigue is a feature, not a bug.';

  @override
  String get signatoryPower => 'Iron Will';

  @override
  String get powerDescription =>
      "Streaks don't break on planned rest days. The Iron rests to come back harder.";

  @override
  int get colorValue => 0xFFEF4444;
}

final class Surge extends CharacterClass {
  const Surge();

  @override
  String get id => 'surge';

  @override
  String get name => 'The Surge';

  @override
  String get epithet => 'Explosive by design';

  @override
  String get lore =>
      'Interval-dominant, fast-twitch focus. Every run is a calculated detonation.';

  @override
  String get signatoryPower => 'Overdrive';

  @override
  String get powerDescription =>
      'Earn 2× XP on any run where you set a personal record.';

  @override
  int get colorValue => 0xFFFF9F0A;
}

final class Sage extends CharacterClass {
  const Sage();

  @override
  String get id => 'sage';

  @override
  String get name => 'The Sage';

  @override
  String get epithet => 'Perfect recovery, perfect timing';

  @override
  String get lore =>
      'HRV-optimised, biometric-aware. You don\'t train hard — you train smart.';

  @override
  String get signatoryPower => 'Foresight';

  @override
  String get powerDescription =>
      'AI predicts your peak performance window 2 weeks out with higher accuracy.';

  @override
  int get colorValue => 0xFF34C759;
}

final class Apex extends CharacterClass {
  const Apex();

  @override
  String get id => 'apex';

  @override
  String get name => 'The Apex';

  @override
  String get epithet => 'Balanced. Dangerous.';

  @override
  String get lore =>
      'No weakness, no ceiling. The rarest class — forged from equal mastery of all disciplines.';

  @override
  String get signatoryPower => 'Adaptable';

  @override
  String get powerDescription =>
      "Temporarily equip any other class's signatory power once per week.";

  @override
  int get colorValue => 0xFF007AFF;
}

import 'package:flutter/material.dart';
import 'package:kynos/core/theme/app_theme.dart';

enum CharacterStatId {
  strength,
  endurance,
  speed,
  form,
  recovery,
  willpower;

  String get label => switch (this) {
        strength => 'STR',
        endurance => 'END',
        speed => 'SPD',
        form => 'FRM',
        recovery => 'RCV',
        willpower => 'WIL',
      };

  String get fullName => switch (this) {
        strength => 'Strength',
        endurance => 'Endurance',
        speed => 'Speed',
        form => 'Form',
        recovery => 'Recovery',
        willpower => 'Willpower',
      };

  String get description => switch (this) {
        strength => 'Running power & training load',
        endurance => 'Chronic load & long run trend',
        speed => 'Pace progression over 30 days',
        form => 'Gait model quality & cadence',
        recovery => 'HRV, sleep & readiness score',
        willpower => 'Runs completed under low readiness',
      };

  Color get color => switch (this) {
        strength => AppTheme.energy,
        endurance => AppTheme.stand,
        speed => AppTheme.move,
        form => AppTheme.exercise,
        recovery => AppTheme.purple,
        willpower => const Color(0xFFFFD60A),
      };
}

class CharacterStats {
  const CharacterStats({
    this.strength = 10,
    this.endurance = 10,
    this.speed = 10,
    this.form = 10,
    this.recovery = 10,
    this.willpower = 10,
  });

  final int strength;
  final int endurance;
  final int speed;
  final int form;
  final int recovery;
  final int willpower;

  int operator [](CharacterStatId stat) => switch (stat) {
        CharacterStatId.strength => strength,
        CharacterStatId.endurance => endurance,
        CharacterStatId.speed => speed,
        CharacterStatId.form => form,
        CharacterStatId.recovery => recovery,
        CharacterStatId.willpower => willpower,
      };

  CharacterStatId get weakest {
    final values = {
      CharacterStatId.strength: strength,
      CharacterStatId.endurance: endurance,
      CharacterStatId.speed: speed,
      CharacterStatId.form: form,
      CharacterStatId.recovery: recovery,
      CharacterStatId.willpower: willpower,
    };
    return values.entries.reduce((a, b) => a.value <= b.value ? a : b).key;
  }

  CharacterStats copyWith({
    int? strength,
    int? endurance,
    int? speed,
    int? form,
    int? recovery,
    int? willpower,
  }) =>
      CharacterStats(
        strength: (strength ?? this.strength).clamp(0, 100),
        endurance: (endurance ?? this.endurance).clamp(0, 100),
        speed: (speed ?? this.speed).clamp(0, 100),
        form: (form ?? this.form).clamp(0, 100),
        recovery: (recovery ?? this.recovery).clamp(0, 100),
        willpower: (willpower ?? this.willpower).clamp(0, 100),
      );

  CharacterStats applyDeltas(Map<CharacterStatId, int> deltas) => copyWith(
        strength: strength + (deltas[CharacterStatId.strength] ?? 0),
        endurance: endurance + (deltas[CharacterStatId.endurance] ?? 0),
        speed: speed + (deltas[CharacterStatId.speed] ?? 0),
        form: form + (deltas[CharacterStatId.form] ?? 0),
        recovery: recovery + (deltas[CharacterStatId.recovery] ?? 0),
        willpower: willpower + (deltas[CharacterStatId.willpower] ?? 0),
      );

  Map<String, dynamic> toJson() => {
        'strength': strength,
        'endurance': endurance,
        'speed': speed,
        'form': form,
        'recovery': recovery,
        'willpower': willpower,
      };

  factory CharacterStats.fromJson(Map<String, dynamic> json) => CharacterStats(
        strength: (json['strength'] as num?)?.toInt() ?? 10,
        endurance: (json['endurance'] as num?)?.toInt() ?? 10,
        speed: (json['speed'] as num?)?.toInt() ?? 10,
        form: (json['form'] as num?)?.toInt() ?? 10,
        recovery: (json['recovery'] as num?)?.toInt() ?? 10,
        willpower: (json['willpower'] as num?)?.toInt() ?? 10,
      );
}

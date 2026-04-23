import 'package:flutter/material.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/domain/entities/gamification/character_stats.dart';

extension CharacterStatTheme on CharacterStatId {
  Color get color => switch (this) {
        CharacterStatId.strength => AppTheme.energy,
        CharacterStatId.endurance => AppTheme.stand,
        CharacterStatId.speed => AppTheme.move,
        CharacterStatId.form => AppTheme.exercise,
        CharacterStatId.recovery => AppTheme.purple,
        CharacterStatId.willpower => const Color(0xFFFFD60A),
      };
}

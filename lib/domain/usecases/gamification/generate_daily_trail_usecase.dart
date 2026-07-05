import 'package:kynos/core/constants/gamification_constants.dart';
import 'package:kynos/domain/entities/gamification/trail_node.dart';
import 'package:kynos/domain/utils/seeded_roll.dart';

class GenerateDailyTrailUseCase {
  const GenerateDailyTrailUseCase();

  List<TrailNode> call({
    required int characterLevel,
    required DateTime date,
    bool forceBoss = false,
  }) {
    final seed = _seed(characterLevel, date);
    final isBossDay = forceBoss || date.weekday == DateTime.sunday;

    final pattern = isBossDay
        ? <TrailNodeType>[
            TrailNodeType.start,
            TrailNodeType.encounter,
            TrailNodeType.rest,
            TrailNodeType.encounter,
            TrailNodeType.treasure,
            TrailNodeType.encounter,
            TrailNodeType.boss,
          ]
        : <TrailNodeType>[
            TrailNodeType.start,
            TrailNodeType.encounter,
            TrailNodeType.treasure,
            TrailNodeType.encounter,
            TrailNodeType.rest,
            TrailNodeType.encounter,
            TrailNodeType.treasure,
          ];

    return List.generate(GamificationConstants.trailNodeCount, (index) {
      final type = pattern[index];
      final enemyRoll = seededRoll(seed + index * 17);
      final enemyId = switch (type) {
        TrailNodeType.encounter => _encounterEnemy(enemyRoll, characterLevel),
        TrailNodeType.boss => 'boss_${characterLevel ~/ 5}',
        _ => 'none',
      };
      return TrailNode(index: index, type: type, enemyId: enemyId);
    });
  }

  int _seed(int level, DateTime date) =>
      level * 1000 + date.year * 10000 + date.month * 100 + date.day;

  String _encounterEnemy(int roll, int level) {
    final tier = level < 10
        ? 'grunt'
        : level < 25
            ? 'veteran'
            : 'elite';
    final variant = roll % 3;
    return 'trail_${tier}_$variant';
  }
}

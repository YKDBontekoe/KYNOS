enum CombatAction { strike, rush, brace, focus, recover }

extension CombatActionLabel on CombatAction {
  String get label => switch (this) {
        CombatAction.strike => 'Strike',
        CombatAction.rush => 'Rush',
        CombatAction.brace => 'Brace',
        CombatAction.focus => 'Focus',
        CombatAction.recover => 'Recover',
      };
}

enum EncounterOutcome { inProgress, victory, defeat, retreated }

class EncounterState {
  const EncounterState({
    required this.enemyId,
    required this.enemyMaxHp,
    required this.enemyHp,
    required this.turnCount,
    required this.outcome,
    this.blockingNextHit = false,
    this.focusedNextTurn = false,
    this.firstActionFree = true,
    this.combatLog = const [],
    this.isBoss = false,
  });

  final String enemyId;
  final int enemyMaxHp;
  final int enemyHp;
  final int turnCount;
  final EncounterOutcome outcome;
  final bool blockingNextHit;
  final bool focusedNextTurn;
  final bool firstActionFree;
  final List<String> combatLog;
  final bool isBoss;

  bool get isActive => outcome == EncounterOutcome.inProgress;

  EncounterState copyWith({
    int? enemyHp,
    int? turnCount,
    EncounterOutcome? outcome,
    bool? blockingNextHit,
    bool? focusedNextTurn,
    bool? firstActionFree,
    List<String>? combatLog,
  }) =>
      EncounterState(
        enemyId: enemyId,
        enemyMaxHp: enemyMaxHp,
        enemyHp: enemyHp ?? this.enemyHp,
        turnCount: turnCount ?? this.turnCount,
        outcome: outcome ?? this.outcome,
        blockingNextHit: blockingNextHit ?? this.blockingNextHit,
        focusedNextTurn: focusedNextTurn ?? this.focusedNextTurn,
        firstActionFree: firstActionFree ?? this.firstActionFree,
        combatLog: combatLog ?? this.combatLog,
        isBoss: isBoss,
      );

  Map<String, dynamic> toJson() => {
        'enemy_id': enemyId,
        'enemy_max_hp': enemyMaxHp,
        'enemy_hp': enemyHp,
        'turn_count': turnCount,
        'outcome': outcome.name,
        'blocking_next_hit': blockingNextHit,
        'focused_next_turn': focusedNextTurn,
        'first_action_free': firstActionFree,
        'combat_log': combatLog,
        'is_boss': isBoss,
      };

  factory EncounterState.fromJson(Map<String, dynamic> json) => EncounterState(
        enemyId: json['enemy_id'] as String? ?? 'trail_grunt',
        enemyMaxHp: (json['enemy_max_hp'] as num?)?.toInt() ?? 40,
        enemyHp: (json['enemy_hp'] as num?)?.toInt() ?? 40,
        turnCount: (json['turn_count'] as num?)?.toInt() ?? 0,
        outcome: EncounterOutcome.values.firstWhere(
          (o) => o.name == json['outcome'],
          orElse: () => EncounterOutcome.inProgress,
        ),
        blockingNextHit: json['blocking_next_hit'] as bool? ?? false,
        focusedNextTurn: json['focused_next_turn'] as bool? ?? false,
        firstActionFree: json['first_action_free'] as bool? ?? true,
        combatLog: (json['combat_log'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        isBoss: json['is_boss'] as bool? ?? false,
      );
}

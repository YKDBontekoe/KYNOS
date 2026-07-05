import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/gamification/activity_resources.dart';
import 'package:kynos/domain/entities/gamification/adventure_session.dart';
import 'package:kynos/domain/entities/gamification/trail_node.dart';
import 'package:kynos/domain/usecases/gamification/generate_daily_trail_usecase.dart';
import 'package:kynos/features/character/presentation/widgets/trail_run_game_panel.dart';
import 'package:kynos/features/character/providers/adventure_provider.dart';

void main() {
  testWidgets('trail run panel shows advance button', (tester) async {
    const generateTrail = GenerateDailyTrailUseCase();
    final nodes = generateTrail(characterLevel: 3, date: DateTime(2026, 7, 6));
    final session = AdventureSession(
      date: DateTime(2026, 7, 6),
      nodes: nodes,
      currentIndex: 0,
      spentMovePoints: 0,
      spentStamina: 0,
    );
    final viewState = AdventureViewState(
      session: session,
      resources: const ActivityResources(
        totalMovePoints: 5,
        totalStamina: 10,
        spentMovePoints: 0,
        spentStamina: 0,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adventureSessionProvider.overrideWith(
            () => _StaticAdventureNotifier(viewState),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: TrailRunGamePanel()),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('TRAIL RUN'), findsOneWidget);
    expect(find.text('Advance'), findsOneWidget);
    expect(find.text('MOVES'), findsOneWidget);
    expect(find.text('STAMINA'), findsOneWidget);
  });
}

class _StaticAdventureNotifier extends AdventureSessionNotifier {
  _StaticAdventureNotifier(this._state);

  final AdventureViewState _state;

  @override
  Future<AdventureViewState?> build() async => _state;
}

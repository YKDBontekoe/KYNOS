import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/gamification/adventure_session.dart';
import 'package:kynos/domain/entities/gamification/trail_node.dart';
import 'package:kynos/domain/usecases/gamification/generate_daily_trail_usecase.dart';
import 'package:kynos/features/character/presentation/widgets/trail_map.dart';

void main() {
  testWidgets('trail map shows status label on a single horizontal line', (tester) async {
    const generateTrail = GenerateDailyTrailUseCase();
    final nodes = generateTrail(characterLevel: 1, date: DateTime(2026, 7, 6));
    final session = AdventureSession(
      date: DateTime(2026, 7, 6),
      nodes: nodes,
      currentIndex: 0,
      spentMovePoints: 0,
      spentStamina: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrailMap(
            session: session,
            canAdvance: true,
            onAdvance: () {},
          ),
        ),
      ),
    );

    await tester.pump();

    final statusFinder = find.text('Node 1/${nodes.length} · START');
    expect(statusFinder, findsOneWidget);

    final text = tester.widget<Text>(statusFinder);
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);

    final box = tester.renderObject<RenderBox>(statusFinder);
    expect(box.size.width, greaterThan(120));
    expect(box.size.height, lessThan(24));
  });
}

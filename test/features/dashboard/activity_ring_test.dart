import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/features/dashboard/presentation/widgets/activity_ring.dart';

void main() {
  testWidgets('ActivityRing renders with RingPainter', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ActivityRing(
            ringProgresses: [0.5, 0.25],
            size: 100,
            strokeWidth: 8,
            colors: [Colors.red, Colors.blue],
          ),
        ),
      ),
    );

    expect(find.byType(ActivityRing), findsOneWidget);
    final ring = tester.widget<ActivityRing>(find.byType(ActivityRing));
    expect(ring.ringProgresses, [0.5, 0.25]);
  });

  testWidgets('AnimatedActivityRing builds with target progresses', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedActivityRing(
            ringProgresses: [0.75, 0.5],
            size: 100,
            strokeWidth: 8,
            colors: [Colors.red, Colors.blue],
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(AnimatedActivityRing), findsOneWidget);
    final ring =
        tester.widget<AnimatedActivityRing>(find.byType(AnimatedActivityRing));
    expect(ring.ringProgresses, [0.75, 0.5]);
  });
}

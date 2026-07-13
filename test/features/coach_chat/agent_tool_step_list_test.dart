import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/coach/coach_tool_call.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/agent_tool_step_list.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/assistant_bubble.dart';

void main() {
  testWidgets('AgentToolStepList renders running, success, and error steps', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AgentToolStepList(
            steps: [
              CoachToolStep(
                toolName: 'get_recent_runs',
                status: CoachToolStatus.running,
                displayLabel: 'Checking your recent runs',
              ),
              CoachToolStep(
                toolName: 'get_training_load',
                status: CoachToolStatus.success,
                displayLabel: 'Training load reviewed',
              ),
              CoachToolStep(
                toolName: 'get_health_trend',
                status: CoachToolStatus.error,
                displayLabel: 'Health metrics disabled',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Checking your recent runs'), findsOneWidget);
    expect(find.text('Training load reviewed'), findsOneWidget);
    expect(find.text('Health metrics disabled'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
  });

  testWidgets('AgentToolStepList renders nothing for an empty step list', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AgentToolStepList(steps: [])),
      ),
    );

    expect(find.byType(SizedBox), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('AssistantBubble shows tool steps above the answer content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AssistantBubble(
            content: 'Based on your last two runs, ease off tomorrow.',
            isStreaming: false,
            toolSteps: [
              CoachToolStep(
                toolName: 'get_recent_runs',
                status: CoachToolStatus.success,
                displayLabel: '2 runs found',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('2 runs found'), findsOneWidget);
    expect(find.textContaining('ease off tomorrow'), findsOneWidget);
  });
}

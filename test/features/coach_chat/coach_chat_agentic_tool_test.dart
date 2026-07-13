import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/ai_task_kind.dart';
import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/domain/entities/cloud_data_level.dart';
import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/entities/coach/coach_tool_call.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/domain/utils/gemma_device_capability.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_provider.dart';
import 'package:kynos/features/coach_chat/providers/coach_conversations_provider.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/shared/providers/gemma_tier_provider.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ProviderContainer> buildContainer(
    _ScriptedAgenticAiCoachRepository fakeAi,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        healthRepositoryProvider.overrideWithValue(_FakeHealthRepository()),
        chatAiCoachRepositoryProvider.overrideWithValue(fakeAi),
        gemmaInferenceTierProvider.overrideWith(
          (ref) async => GemmaInferenceTier.full,
        ),
      ],
    );
    await container
        .read(coachConversationsProvider.notifier)
        .ensureActiveConversation();
    await container.read(coachChatProvider.future);
    return container;
  }

  test(
    'resolves a TOOL_CALL directive before answering, and shows the step',
    () async {
      final fakeAi = _ScriptedAgenticAiCoachRepository(
        scriptedTurns: [
          'TOOL_CALL: {"name":"get_recent_runs","arguments":{"limit":2}}',
          'Great work on those runs — keep tomorrow easy.',
        ],
      );
      final container = await buildContainer(fakeAi);
      addTearDown(container.dispose);

      await container
          .read(coachChatProvider.notifier)
          .sendMessage("How's my training going?");

      final messages = container.read(coachChatProvider).value!;
      final assistant = messages.last;

      expect(assistant.role, MessageRole.assistant);
      expect(assistant.hasError, isFalse);
      expect(assistant.isStreaming, isFalse);
      expect(assistant.content, contains('keep tomorrow easy'));
      expect(assistant.content, isNot(contains('TOOL_CALL')));

      expect(assistant.toolSteps, isNotNull);
      expect(assistant.toolSteps, hasLength(1));
      expect(assistant.toolSteps!.single.toolName, 'get_recent_runs');
      expect(assistant.toolSteps!.single.status, CoachToolStatus.success);

      // The tool's result must have been fed back into the follow-up prompt.
      expect(fakeAi.capturedUserMessages, hasLength(2));
      expect(fakeAi.capturedUserMessages[1], contains('get_recent_runs'));
      expect(fakeAi.capturedUserMessages[1], contains('Runs (last'));
    },
  );

  test('answers directly and streams live when no tool call is made', () async {
    final fakeAi = _ScriptedAgenticAiCoachRepository(
      scriptedTurns: ['Rest today and hydrate well.'],
    );
    final container = await buildContainer(fakeAi);
    addTearDown(container.dispose);

    await container
        .read(coachChatProvider.notifier)
        .sendMessage('Should I run today?');

    final messages = container.read(coachChatProvider).value!;
    final assistant = messages.last;

    expect(assistant.hasError, isFalse);
    expect(assistant.content, 'Rest today and hydrate well.');
    expect(assistant.toolSteps, isNull);
    expect(fakeAi.capturedUserMessages, hasLength(1));
  });

  test('stops looping after the max tool step budget and answers', () async {
    final fakeAi = _ScriptedAgenticAiCoachRepository(
      scriptedTurns: [
        'TOOL_CALL: {"name":"get_training_load","arguments":{}}',
        'TOOL_CALL: {"name":"get_personal_bests","arguments":{}}',
        'TOOL_CALL: {"name":"get_health_trend","arguments":{"metric":"hrv"}}',
        'TOOL_CALL: {"name":"get_recent_runs","arguments":{}}',
        'Final answer after the tool budget was reached.',
      ],
    );
    final container = await buildContainer(fakeAi);
    addTearDown(container.dispose);

    await container
        .read(coachChatProvider.notifier)
        .sendMessage('Give me a full report.');

    final messages = container.read(coachChatProvider).value!;
    final assistant = messages.last;

    expect(assistant.toolSteps, hasLength(4));
    expect(assistant.hasError, isFalse);
    expect(
      assistant.content,
      'Final answer after the tool budget was reached.',
    );
    expect(fakeAi.capturedUserMessages, hasLength(5));
    expect(fakeAi.capturedUserMessages[1], contains('get_training_load'));
    expect(fakeAi.capturedUserMessages[4], contains('get_recent_runs'));
  });

  test(
    'never leaks a raw TOOL_CALL directive if the model keeps trying past the budget',
    () async {
      final fakeAi = _ScriptedAgenticAiCoachRepository(
        scriptedTurns: [
          'TOOL_CALL: {"name":"get_training_load","arguments":{}}',
          'TOOL_CALL: {"name":"get_personal_bests","arguments":{}}',
          'TOOL_CALL: {"name":"get_recent_runs","arguments":{}}',
          'TOOL_CALL: {"name":"get_health_trend","arguments":{"metric":"hrv"}}',
          'TOOL_CALL: {"name":"get_health_trend","arguments":{"metric":"sleep"}}',
        ],
      );
      final container = await buildContainer(fakeAi);
      addTearDown(container.dispose);

      await container
          .read(coachChatProvider.notifier)
          .sendMessage('Give me a full report.');

      final messages = container.read(coachChatProvider).value!;
      final assistant = messages.last;

      // The model never actually answers, so this degrades to a retryable
      // error — but it must never show raw tool-call syntax to the athlete.
      expect(assistant.content, isNot(contains('TOOL_CALL')));
      expect(assistant.hasError, isTrue);
      expect(assistant.toolSteps, hasLength(4));
    },
  );

  test('does not execute an identical tool request twice', () async {
    final fakeAi = _ScriptedAgenticAiCoachRepository(
      scriptedTurns: [
        'TOOL_CALL: {"name":"get_recent_runs","arguments":{"limit":2}}',
        'TOOL_CALL: {"name":"get_recent_runs","arguments":{"limit":2}}',
        'I used the existing local result.',
      ],
    );
    final container = await buildContainer(fakeAi);
    addTearDown(container.dispose);

    await container
        .read(coachChatProvider.notifier)
        .sendMessage('Review my recent movement.');

    final assistant = container.read(coachChatProvider).value!.last;
    expect(assistant.toolSteps, hasLength(1));
    expect(assistant.content, contains('existing local result'));
  });

  test(
    'severe symptom text uses static rules and never calls the model',
    () async {
      final fakeAi = _ScriptedAgenticAiCoachRepository(
        scriptedTurns: ['This must not be used.'],
      );
      final container = await buildContainer(fakeAi);
      addTearDown(container.dispose);

      await container
          .read(coachChatProvider.notifier)
          .sendMessage('I have chest pain and cannot breathe.');

      final assistant = container.read(coachChatProvider).value!.last;
      expect(assistant.attemptedBackend, AiInferenceBackend.rulesOnly);
      expect(assistant.content, contains('emergency services'));
      expect(fakeAi.capturedUserMessages, isEmpty);
    },
  );
}

/// Emits pre-scripted responses (one per call), split into small chunks to
/// exercise the notifier's incremental tool-call detection buffering.
class _ScriptedAgenticAiCoachRepository implements AiCoachRepository {
  _ScriptedAgenticAiCoachRepository({required this.scriptedTurns});

  final List<String> scriptedTurns;
  final List<String> capturedUserMessages = [];
  int _callCount = 0;

  @override
  bool get isReady => true;

  @override
  AiInferenceBackend lastBackend = AiInferenceBackend.onDevice;

  @override
  Stream<AiChunk> chat({
    required String userMessage,
    List<HealthSummary>? healthContext,
    CoachContext? coachContext,
    List<ChatMessage>? conversationHistory,
    AiTaskKind taskKind = AiTaskKind.coachChat,
    int estimatedPromptTokens = 0,
    AiInferenceBackend? preferredBackend,
    String? cloudModelIdOverride,
    CloudDataLevel? cloudDataLevelOverride,
  }) {
    capturedUserMessages.add(userMessage);
    final index = _callCount.clamp(0, scriptedTurns.length - 1);
    _callCount++;
    return _chunked(scriptedTurns[index]);
  }

  Stream<AiChunk> _chunked(String text) async* {
    for (var i = 0; i < text.length; i += 5) {
      await Future<void>.delayed(Duration.zero);
      yield text.substring(i, i + 5 > text.length ? text.length : i + 5);
    }
  }

  @override
  Future<void> resetSession() async {}

  @override
  Future<void> dispose() async {}
}

class _FakeHealthRepository implements HealthRepository {
  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<bool> hasPermissions() async => true;

  @override
  Future<({WorkoutSession? workout, Failure? failure})> getWorkoutById({
    required String workoutId,
  }) async {
    return (workout: null, failure: null);
  }

  @override
  Future<({List<HealthSummary> summaries, Failure? failure})> getSummaries({
    required int days,
  }) async {
    return (summaries: const <HealthSummary>[], failure: null);
  }

  @override
  Future<({List<WorkoutSession> runs, Failure? failure})> getRecentRuns({
    required int days,
    int limit = 30,
  }) async {
    return (
      runs: [
        WorkoutSession(
          id: 'r1',
          start: DateTime(2026, 7, 6, 7),
          end: DateTime(2026, 7, 6, 7, 30),
          workoutType: 'run',
          distanceMeters: 5000,
          sourceName: 'test',
        ),
        WorkoutSession(
          id: 'r2',
          start: DateTime(2026, 7, 4, 7),
          end: DateTime(2026, 7, 4, 7, 32),
          workoutType: 'run',
          distanceMeters: 5000,
          sourceName: 'test',
        ),
      ],
      failure: null,
    );
  }

  @override
  Future<({List<WorkoutRoutePoint> points, Failure? failure})> getRunRoute({
    required String workoutUuid,
  }) async {
    return (points: const <WorkoutRoutePoint>[], failure: null);
  }

  @override
  Future<({HealthSummary? summary, Failure? failure})> getToday() async {
    return (summary: null, failure: null);
  }
}

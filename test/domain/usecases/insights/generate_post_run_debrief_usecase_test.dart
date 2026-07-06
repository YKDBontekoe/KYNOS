import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/cloud_data_level.dart';
import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/ai_task_kind.dart';
import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';
import 'package:kynos/domain/usecases/insights/generate_post_run_debrief_usecase.dart';

void main() {
  group('GeneratePostRunDebriefUseCase', () {
    final session = WorkoutSession(
      id: 'run-1',
      start: DateTime(2026, 7, 5, 7, 0),
      end: DateTime(2026, 7, 5, 7, 45),
      workoutType: 'running',
      distanceMeters: 8000,
      sourceName: 'HealthKit',
    );

    final sameDay = HealthSummary(
      date: DateTime(2026, 7, 5),
      hrvMs: 42,
      rhrBpm: 58,
      sleepHours: 7.5,
    );

    test('returns baseline when AI coach is not ready', () async {
      final useCase = GeneratePostRunDebriefUseCase(
        aiCoach: _NotReadyAiCoach(),
      );

      final result = await useCase.call(
        session: session,
        sameDaySummary: sameDay,
      );

      expect(result.usedModel, isFalse);
      expect(result.highlight, contains('8.0 km'));
      expect(result.oneFix, isNotEmpty);
      expect(result.recoveryNote, isNotEmpty);
    });

    test('refines debrief when AI returns structured fields', () async {
      final useCase = GeneratePostRunDebriefUseCase(
        aiCoach: _RefiningAiCoach(
          response: 'HIGHLIGHT: Strong tempo finish\n'
              'ONE_FIX: Add strides tomorrow\n'
              'RECOVERY_NOTE: Foam roll calves',
        ),
      );

      final result = await useCase.call(
        session: session,
        sameDaySummary: sameDay,
      );

      expect(result.usedModel, isTrue);
      expect(result.highlight, 'Strong tempo finish');
      expect(result.oneFix, 'Add strides tomorrow');
      expect(result.recoveryNote, 'Foam roll calves');
    });

    test('returns baseline when resetSession throws', () async {
      final useCase = GeneratePostRunDebriefUseCase(
        aiCoach: _ThrowingAiCoach(throwOnReset: true),
      );

      final result = await useCase.call(
        session: session,
        sameDaySummary: sameDay,
      );

      expect(result.usedModel, isFalse);
      expect(result.highlight, contains('8.0 km'));
    });

    test('returns baseline when chat throws', () async {
      final useCase = GeneratePostRunDebriefUseCase(
        aiCoach: _ThrowingAiCoach(throwOnChat: true),
      );

      final result = await useCase.call(
        session: session,
        sameDaySummary: sameDay,
      );

      expect(result.usedModel, isFalse);
    });

    test('extractField ignores keys embedded in values', () {
      const text = 'SOME_HIGHLIGHT: ignore\nHIGHLIGHT: Real highlight';
      expect(
        GeneratePostRunDebriefUseCase.extractField(text, 'HIGHLIGHT'),
        'Real highlight',
      );
    });
  });
}

class _NotReadyAiCoach implements AiCoachRepository {
  @override
  bool get isReady => false;

  @override
  AiInferenceBackend lastBackend = AiInferenceBackend.onDevice;

  @override
  Stream<String> chat({
    required String userMessage,
    List<HealthSummary>? healthContext,
    CoachContext? coachContext,
    List<ChatMessage>? conversationHistory,
    AiTaskKind taskKind = AiTaskKind.coachChat,
    int estimatedPromptTokens = 0,
    AiInferenceBackend? preferredBackend,
    String? cloudModelIdOverride,
    CloudDataLevel? cloudDataLevelOverride,
  }) =>
      const Stream.empty();

  @override
  Future<void> dispose() async {}

  @override
  Future<void> resetSession() async {}
}

class _RefiningAiCoach implements AiCoachRepository {
  _RefiningAiCoach({required this.response});

  final String response;

  @override
  bool get isReady => true;

  @override
  AiInferenceBackend lastBackend = AiInferenceBackend.onDevice;

  @override
  Stream<String> chat({
    required String userMessage,
    List<HealthSummary>? healthContext,
    CoachContext? coachContext,
    List<ChatMessage>? conversationHistory,
    AiTaskKind taskKind = AiTaskKind.coachChat,
    int estimatedPromptTokens = 0,
    AiInferenceBackend? preferredBackend,
    String? cloudModelIdOverride,
    CloudDataLevel? cloudDataLevelOverride,
  }) async* {
    yield response;
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<void> resetSession() async {}
}

class _ThrowingAiCoach implements AiCoachRepository {
  _ThrowingAiCoach({this.throwOnReset = false, this.throwOnChat = false});

  final bool throwOnReset;
  final bool throwOnChat;

  @override
  bool get isReady => true;

  @override
  AiInferenceBackend lastBackend = AiInferenceBackend.onDevice;

  @override
  Stream<String> chat({
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
    if (throwOnChat) {
      return Stream<String>.error(StateError('chat failed'));
    }
    return const Stream.empty();
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<void> resetSession() async {
    if (throwOnReset) throw StateError('reset failed');
  }
}

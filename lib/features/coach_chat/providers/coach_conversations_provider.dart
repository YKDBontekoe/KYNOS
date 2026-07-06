import 'package:kynos/domain/entities/coach/coach_chat_seed.dart';
import 'package:kynos/domain/entities/coach/coach_conversation.dart';
import 'package:kynos/domain/entities/coach/coach_conversation_settings.dart';
import 'package:kynos/domain/entities/coach/coach_conversation_summary.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/shared/providers/coach_conversation_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'coach_conversations_provider.g.dart';

@Riverpod(keepAlive: true)
class ActiveCoachConversationId extends _$ActiveCoachConversationId {
  @override
  String? build() => null;

  void set(String? id) => state = id;
}

@Riverpod(keepAlive: true)
class CoachConversations extends _$CoachConversations {
  @override
  Future<List<CoachConversationSummary>> build() async {
    await _ensureMigrated();
    final result = await ref.read(listCoachConversationsUseCaseProvider).call();
    return result.summaries;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await build());
  }

  Future<String?> ensureActiveConversation({CoachChatSeedData? seed}) async {
    var activeId = ref.read(activeCoachConversationIdProvider);
    if (activeId != null) {
      final existing =
          await ref.read(getCoachConversationUseCaseProvider).call(activeId);
      if (existing.conversation != null) return activeId;
    }

    final summaries = state.value ?? await build();
    if (summaries.isNotEmpty) {
      activeId = summaries.first.id;
      await _setActive(activeId);
      return activeId;
    }

    return createConversation(seed: seed);
  }

  Future<String?> createConversation({
    CoachChatSeedData? seed,
    CoachConversationSettings? settings,
  }) async {
    final resolvedSettings = settings ?? CoachConversationSettings.defaults;
    final result = await ref.read(createCoachConversationUseCaseProvider).call(
          seed: seed,
          settings: resolvedSettings,
        );
    if (result.conversation == null) return null;
    await _setActive(result.conversation!.id);
    await refresh();
    return result.conversation!.id;
  }

  Future<void> switchConversation(String id) async {
    await ref.read(chatAiCoachRepositoryProvider).resetSession();
    await _setActive(id);
  }

  Future<void> deleteConversation(String id) async {
    await ref.read(deleteCoachConversationUseCaseProvider).call(id);
    final activeId = ref.read(activeCoachConversationIdProvider);
    if (activeId == id) {
      ref.read(activeCoachConversationIdProvider.notifier).set(null);
    }
    await refresh();
  }

  Future<void> updateSummary(CoachConversation conversation) async {
    await ref.read(updateCoachConversationUseCaseProvider).call(conversation);
    await refresh();
  }

  Future<CoachConversation?> loadConversation(String id) async {
    final result = await ref.read(getCoachConversationUseCaseProvider).call(id);
    return result.conversation;
  }

  Future<void> _setActive(String id) async {
    await ref
        .read(coachConversationRepositoryProvider)
        .writeActiveConversationId(id);
    ref.read(activeCoachConversationIdProvider.notifier).set(id);
  }

  Future<void> _ensureMigrated() async {
    final migrate = ref.read(migrateLegacyCoachChatUseCaseProvider);
    final result = await migrate.call();
    if (result.conversationId != null) {
      await ref.read(coachConversationRepositoryProvider).writeActiveConversationId(
            result.conversationId,
          );
      ref
          .read(activeCoachConversationIdProvider.notifier)
          .set(result.conversationId);
    } else {
      final active = await ref
          .read(coachConversationRepositoryProvider)
          .readActiveConversationId();
      if (active.activeId != null) {
        ref.read(activeCoachConversationIdProvider.notifier).set(active.activeId);
      }
    }
  }
}


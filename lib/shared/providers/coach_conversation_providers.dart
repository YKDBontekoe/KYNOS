import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/repositories/coach_conversation_repository.dart';
import 'package:kynos/domain/usecases/coach/create_coach_conversation_usecase.dart';
import 'package:kynos/domain/usecases/coach/delete_coach_conversation_usecase.dart';
import 'package:kynos/domain/usecases/coach/describe_coach_context_usecase.dart';
import 'package:kynos/domain/usecases/coach/export_coach_conversation_usecase.dart';
import 'package:kynos/domain/usecases/coach/filter_coach_context_usecase.dart';
import 'package:kynos/domain/usecases/coach/get_coach_conversation_usecase.dart';
import 'package:kynos/domain/usecases/coach/list_coach_conversations_usecase.dart';
import 'package:kynos/domain/usecases/coach/migrate_legacy_coach_chat_usecase.dart';
import 'package:kynos/domain/usecases/coach/update_coach_conversation_usecase.dart';
import 'package:kynos/infrastructure/coach/coach_conversation_repository_impl.dart';
import 'package:kynos/shared/providers/shared_preferences_provider.dart';

final coachConversationRepositoryProvider =
    Provider<CoachConversationRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CoachConversationRepositoryImpl(prefs);
});

final createCoachConversationUseCaseProvider =
    Provider<CreateCoachConversationUseCase>((ref) {
  return CreateCoachConversationUseCase(
    repository: ref.watch(coachConversationRepositoryProvider),
  );
});

final listCoachConversationsUseCaseProvider =
    Provider<ListCoachConversationsUseCase>((ref) {
  return ListCoachConversationsUseCase(
    repository: ref.watch(coachConversationRepositoryProvider),
  );
});

final getCoachConversationUseCaseProvider =
    Provider<GetCoachConversationUseCase>((ref) {
  return GetCoachConversationUseCase(
    repository: ref.watch(coachConversationRepositoryProvider),
  );
});

final updateCoachConversationUseCaseProvider =
    Provider<UpdateCoachConversationUseCase>((ref) {
  return UpdateCoachConversationUseCase(
    repository: ref.watch(coachConversationRepositoryProvider),
  );
});

final deleteCoachConversationUseCaseProvider =
    Provider<DeleteCoachConversationUseCase>((ref) {
  return DeleteCoachConversationUseCase(
    repository: ref.watch(coachConversationRepositoryProvider),
  );
});

final migrateLegacyCoachChatUseCaseProvider =
    Provider<MigrateLegacyCoachChatUseCase>((ref) {
  return MigrateLegacyCoachChatUseCase(
    repository: ref.watch(coachConversationRepositoryProvider),
  );
});

final filterCoachContextUseCaseProvider =
    Provider<FilterCoachContextUseCase>((ref) {
  return const FilterCoachContextUseCase();
});

final describeCoachContextUseCaseProvider =
    Provider<DescribeCoachContextUseCase>((ref) {
  return const DescribeCoachContextUseCase();
});

final exportCoachConversationUseCaseProvider =
    Provider<ExportCoachConversationUseCase>((ref) {
  return const ExportCoachConversationUseCase();
});

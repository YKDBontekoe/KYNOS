import 'package:kynos/domain/entities/coach/coach_conversation_summary.dart';
import 'package:kynos/domain/repositories/coach_conversation_repository.dart';

class ListCoachConversationsUseCase {
  const ListCoachConversationsUseCase({
    required CoachConversationRepository repository,
  }) : _repository = repository;

  final CoachConversationRepository _repository;

  Future<({List<CoachConversationSummary> summaries, String? failureMessage})>
      call({
    bool includeArchived = false,
    String? query,
  }) async {
    final result = await _repository.listSummaries();
    if (result.failure != null) {
      return (summaries: <CoachConversationSummary>[], failureMessage: result.failure!.message);
    }

    var summaries = result.summaries;
    if (!includeArchived) {
      summaries = summaries.where((s) => !s.isArchived).toList();
    }

    final trimmedQuery = query?.trim().toLowerCase();
    if (trimmedQuery != null && trimmedQuery.isNotEmpty) {
      summaries = summaries.where((summary) {
        final title = summary.title.toLowerCase();
        final preview = summary.lastMessagePreview?.toLowerCase() ?? '';
        return title.contains(trimmedQuery) || preview.contains(trimmedQuery);
      }).toList();
    }

    summaries.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return (summaries: summaries, failureMessage: null);
  }
}

import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/coach/coach_conversation.dart';
import 'package:kynos/domain/entities/coach/coach_conversation_summary.dart';
import 'package:kynos/domain/repositories/coach_conversation_repository.dart';
import 'package:kynos/infrastructure/coach/coach_conversation_codec.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoachConversationRepositoryImpl implements CoachConversationRepository {
  CoachConversationRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;
  final _logger = Logger();

  @override
  Future<({List<CoachConversationSummary> summaries, Failure? failure})>
      listSummaries() async {
    try {
      final raw = _prefs.getString(CoachConversationCodec.indexKey);
      return (summaries: CoachConversationCodec.decodeIndex(raw), failure: null);
    } on Object catch (error, stackTrace) {
      _logger.e('listSummaries failed', error: error, stackTrace: stackTrace);
      return (summaries: <CoachConversationSummary>[], failure: StorageFailure('$error'));
    }
  }

  @override
  Future<({CoachConversation? conversation, Failure? failure})> getById(
    String id,
  ) async {
    try {
      final raw = _prefs.getString(CoachConversationCodec.threadKey(id));
      final conversation = CoachConversationCodec.decodeThread(raw);
      if (conversation == null) {
        return (conversation: null, failure: const StorageFailure('Conversation not found'));
      }
      return (conversation: conversation, failure: null);
    } on Object catch (error, stackTrace) {
      _logger.e('getById failed', error: error, stackTrace: stackTrace);
      return (conversation: null, failure: StorageFailure('$error'));
    }
  }

  @override
  Future<({CoachConversation? conversation, Failure? failure})> create(
    CoachConversation conversation,
  ) async {
    try {
      await _writeThread(conversation);
      await _upsertSummary(
        CoachConversationCodec.summaryFromConversation(conversation),
      );
      await _enforceCap();
      return (conversation: conversation, failure: null);
    } on Object catch (error, stackTrace) {
      _logger.e('create failed', error: error, stackTrace: stackTrace);
      return (conversation: null, failure: StorageFailure('$error'));
    }
  }

  @override
  Future<({CoachConversation? conversation, Failure? failure})> update(
    CoachConversation conversation,
  ) async {
    try {
      await _writeThread(conversation);
      await _upsertSummary(
        CoachConversationCodec.summaryFromConversation(conversation),
      );
      return (conversation: conversation, failure: null);
    } on Object catch (error, stackTrace) {
      _logger.e('update failed', error: error, stackTrace: stackTrace);
      return (conversation: null, failure: StorageFailure('$error'));
    }
  }

  @override
  Future<({bool success, Failure? failure})> delete(String id) async {
    try {
      final summaries = CoachConversationCodec.decodeIndex(
        _prefs.getString(CoachConversationCodec.indexKey),
      );
      final next = summaries.where((s) => s.id != id).toList();
      await _prefs.setString(
        CoachConversationCodec.indexKey,
        CoachConversationCodec.encodeIndex(next),
      );
      await _prefs.remove(CoachConversationCodec.threadKey(id));
      final activeId = _prefs.getString(CoachConversationCodec.activeIdKey);
      if (activeId == id) {
        await _prefs.remove(CoachConversationCodec.activeIdKey);
      }
      return (success: true, failure: null);
    } on Object catch (error, stackTrace) {
      _logger.e('delete failed', error: error, stackTrace: stackTrace);
      return (success: false, failure: StorageFailure('$error'));
    }
  }

  @override
  Future<({bool migrated, String? conversationId, Failure? failure})>
      migrateLegacyIfNeeded() async {
    try {
      final existingIndex = _prefs.getString(CoachConversationCodec.indexKey);
      if (existingIndex != null && existingIndex.isNotEmpty) {
        return (migrated: false, conversationId: null, failure: null);
      }

      final legacyRaw = _prefs.getString(CoachConversationCodec.legacyKey);
      final legacyMessages =
          CoachConversationCodec.decodeLegacyMessages(legacyRaw);
      if (legacyMessages.isEmpty) {
        return (migrated: false, conversationId: null, failure: null);
      }

      final now = DateTime.now();
      final id = '${now.microsecondsSinceEpoch}_legacy';
      final conversation = CoachConversation(
        id: id,
        title: 'Previous chat',
        createdAt: now,
        updatedAt: now,
        messages: legacyMessages,
      );

      await create(conversation);
      await _prefs.remove(CoachConversationCodec.legacyKey);
      await writeActiveConversationId(id);

      return (migrated: true, conversationId: id, failure: null);
    } on Object catch (error, stackTrace) {
      _logger.e('migrateLegacyIfNeeded failed', error: error, stackTrace: stackTrace);
      return (migrated: false, conversationId: null, failure: StorageFailure('$error'));
    }
  }

  @override
  Future<({String? activeId, Failure? failure})> readActiveConversationId() async {
    try {
      return (
        activeId: _prefs.getString(CoachConversationCodec.activeIdKey),
        failure: null,
      );
    } on Object catch (error, stackTrace) {
      _logger.e('readActiveConversationId failed', error: error, stackTrace: stackTrace);
      return (activeId: null, failure: StorageFailure('$error'));
    }
  }

  @override
  Future<({bool success, Failure? failure})> writeActiveConversationId(
    String? id,
  ) async {
    try {
      if (id == null) {
        await _prefs.remove(CoachConversationCodec.activeIdKey);
      } else {
        await _prefs.setString(CoachConversationCodec.activeIdKey, id);
      }
      return (success: true, failure: null);
    } on Object catch (error, stackTrace) {
      _logger.e('writeActiveConversationId failed', error: error, stackTrace: stackTrace);
      return (success: false, failure: StorageFailure('$error'));
    }
  }

  Future<void> _writeThread(CoachConversation conversation) async {
    await _prefs.setString(
      CoachConversationCodec.threadKey(conversation.id),
      CoachConversationCodec.encodeThread(conversation),
    );
  }

  Future<void> _upsertSummary(CoachConversationSummary summary) async {
    final summaries = CoachConversationCodec.decodeIndex(
      _prefs.getString(CoachConversationCodec.indexKey),
    );
    final without = summaries.where((s) => s.id != summary.id).toList();
    without.add(summary);
    without.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    await _prefs.setString(
      CoachConversationCodec.indexKey,
      CoachConversationCodec.encodeIndex(without),
    );
  }

  Future<void> _enforceCap() async {
    var summaries = CoachConversationCodec.decodeIndex(
      _prefs.getString(CoachConversationCodec.indexKey),
    );
    if (summaries.length <= CoachConversationCodec.maxConversations) return;

    summaries.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? 1 : -1;
      if (a.isArchived != b.isArchived) return a.isArchived ? -1 : 1;
      return a.updatedAt.compareTo(b.updatedAt);
    });

    while (summaries.length > CoachConversationCodec.maxConversations) {
      final victim = summaries.firstWhere(
        (s) => !s.isPinned,
        orElse: () => summaries.first,
      );
      summaries = summaries.where((s) => s.id != victim.id).toList();
      await _prefs.remove(CoachConversationCodec.threadKey(victim.id));
    }

    await _prefs.setString(
      CoachConversationCodec.indexKey,
      CoachConversationCodec.encodeIndex(summaries),
    );
  }
}

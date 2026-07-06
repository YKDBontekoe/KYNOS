// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_conversations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActiveCoachConversationId)
final activeCoachConversationIdProvider = ActiveCoachConversationIdProvider._();

final class ActiveCoachConversationIdProvider
    extends $NotifierProvider<ActiveCoachConversationId, String?> {
  ActiveCoachConversationIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeCoachConversationIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeCoachConversationIdHash();

  @$internal
  @override
  ActiveCoachConversationId create() => ActiveCoachConversationId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$activeCoachConversationIdHash() =>
    r'a80a7d73c277ee8722c2c0ccbffe3a27146a928b';

abstract class _$ActiveCoachConversationId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(CoachConversations)
final coachConversationsProvider = CoachConversationsProvider._();

final class CoachConversationsProvider
    extends
        $AsyncNotifierProvider<
          CoachConversations,
          List<CoachConversationSummary>
        > {
  CoachConversationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coachConversationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coachConversationsHash();

  @$internal
  @override
  CoachConversations create() => CoachConversations();
}

String _$coachConversationsHash() =>
    r'd3c41e8f648c42a89272f462c3606e311ee7ea52';

abstract class _$CoachConversations
    extends $AsyncNotifier<List<CoachConversationSummary>> {
  FutureOr<List<CoachConversationSummary>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<CoachConversationSummary>>,
              List<CoachConversationSummary>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<CoachConversationSummary>>,
                List<CoachConversationSummary>
              >,
              AsyncValue<List<CoachConversationSummary>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CoachChatNotifier)
final coachChatProvider = CoachChatNotifierProvider._();

final class CoachChatNotifierProvider
    extends $AsyncNotifierProvider<CoachChatNotifier, List<ChatMessage>> {
  CoachChatNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coachChatProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coachChatNotifierHash();

  @$internal
  @override
  CoachChatNotifier create() => CoachChatNotifier();
}

String _$coachChatNotifierHash() => r'2487ade210702b690b21d729204f0f1558ea7541';

abstract class _$CoachChatNotifier extends $AsyncNotifier<List<ChatMessage>> {
  FutureOr<List<ChatMessage>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ChatMessage>>, List<ChatMessage>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ChatMessage>>, List<ChatMessage>>,
              AsyncValue<List<ChatMessage>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(LastAiInferenceBackend)
final lastAiInferenceBackendProvider = LastAiInferenceBackendProvider._();

final class LastAiInferenceBackendProvider
    extends $NotifierProvider<LastAiInferenceBackend, AiInferenceBackend> {
  LastAiInferenceBackendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastAiInferenceBackendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastAiInferenceBackendHash();

  @$internal
  @override
  LastAiInferenceBackend create() => LastAiInferenceBackend();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiInferenceBackend value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiInferenceBackend>(value),
    );
  }
}

String _$lastAiInferenceBackendHash() =>
    r'b75f67dd2b67661cd8608d88e3615c7e92a3be9e';

abstract class _$LastAiInferenceBackend extends $Notifier<AiInferenceBackend> {
  AiInferenceBackend build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AiInferenceBackend, AiInferenceBackend>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AiInferenceBackend, AiInferenceBackend>,
              AiInferenceBackend,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

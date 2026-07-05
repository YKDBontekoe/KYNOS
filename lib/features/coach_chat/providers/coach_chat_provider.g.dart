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

String _$coachChatNotifierHash() => r'3d9ee050b81804a63c6b078520d42a4f8b0b7699';

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

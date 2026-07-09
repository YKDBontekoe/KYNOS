// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_coach_conversation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActiveCoachConversation)
final activeCoachConversationProvider = ActiveCoachConversationProvider._();

final class ActiveCoachConversationProvider
    extends
        $AsyncNotifierProvider<ActiveCoachConversation, CoachConversation?> {
  ActiveCoachConversationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeCoachConversationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeCoachConversationHash();

  @$internal
  @override
  ActiveCoachConversation create() => ActiveCoachConversation();
}

String _$activeCoachConversationHash() =>
    r'bbf861e05ddccf2511778279a85d3efb0f0e934a';

abstract class _$ActiveCoachConversation
    extends $AsyncNotifier<CoachConversation?> {
  FutureOr<CoachConversation?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CoachConversation?>, CoachConversation?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CoachConversation?>, CoachConversation?>,
              AsyncValue<CoachConversation?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

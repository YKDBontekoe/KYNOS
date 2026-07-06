// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_run_debrief_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PostRunDebriefNotifier)
final postRunDebriefProvider = PostRunDebriefNotifierProvider._();

final class PostRunDebriefNotifierProvider
    extends
        $NotifierProvider<
          PostRunDebriefNotifier,
          AsyncValue<PostRunDebriefState?>
        > {
  PostRunDebriefNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postRunDebriefProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postRunDebriefNotifierHash();

  @$internal
  @override
  PostRunDebriefNotifier create() => PostRunDebriefNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<PostRunDebriefState?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<PostRunDebriefState?>>(
        value,
      ),
    );
  }
}

String _$postRunDebriefNotifierHash() =>
    r'09f97d2fb63fb0769d19edac8838ff2840d52eed';

abstract class _$PostRunDebriefNotifier
    extends $Notifier<AsyncValue<PostRunDebriefState?>> {
  AsyncValue<PostRunDebriefState?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PostRunDebriefState?>,
              AsyncValue<PostRunDebriefState?>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PostRunDebriefState?>,
                AsyncValue<PostRunDebriefState?>
              >,
              AsyncValue<PostRunDebriefState?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

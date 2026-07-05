// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'huggingface_token_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(readHuggingFaceToken)
final readHuggingFaceTokenProvider = ReadHuggingFaceTokenProvider._();

final class ReadHuggingFaceTokenProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  ReadHuggingFaceTokenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readHuggingFaceTokenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readHuggingFaceTokenHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return readHuggingFaceToken(ref);
  }
}

String _$readHuggingFaceTokenHash() =>
    r'2795fc6c1fbfa282123bb1ae146bdb1e0c12c323';

@ProviderFor(HuggingFaceTokenManager)
final huggingFaceTokenManagerProvider = HuggingFaceTokenManagerProvider._();

final class HuggingFaceTokenManagerProvider
    extends $AsyncNotifierProvider<HuggingFaceTokenManager, String?> {
  HuggingFaceTokenManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'huggingFaceTokenManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$huggingFaceTokenManagerHash();

  @$internal
  @override
  HuggingFaceTokenManager create() => HuggingFaceTokenManager();
}

String _$huggingFaceTokenManagerHash() =>
    r'624e50500f9adf437839a79a0c9c299bdbefd6d6';

abstract class _$HuggingFaceTokenManager extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

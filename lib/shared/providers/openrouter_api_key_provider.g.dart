// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openrouter_api_key_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(secureApiKeyStorage)
final secureApiKeyStorageProvider = SecureApiKeyStorageProvider._();

final class SecureApiKeyStorageProvider
    extends
        $FunctionalProvider<
          SecureApiKeyStorage,
          SecureApiKeyStorage,
          SecureApiKeyStorage
        >
    with $Provider<SecureApiKeyStorage> {
  SecureApiKeyStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureApiKeyStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureApiKeyStorageHash();

  @$internal
  @override
  $ProviderElement<SecureApiKeyStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SecureApiKeyStorage create(Ref ref) {
    return secureApiKeyStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecureApiKeyStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecureApiKeyStorage>(value),
    );
  }
}

String _$secureApiKeyStorageHash() =>
    r'b485ce4ae34aa1bc3385363909263b7d275c02bd';

@ProviderFor(readOpenRouterApiKey)
final readOpenRouterApiKeyProvider = ReadOpenRouterApiKeyProvider._();

final class ReadOpenRouterApiKeyProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  ReadOpenRouterApiKeyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readOpenRouterApiKeyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readOpenRouterApiKeyHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return readOpenRouterApiKey(ref);
  }
}

String _$readOpenRouterApiKeyHash() =>
    r'24ea89be059f5536f6e00e74a918b3192dc958fe';

@ProviderFor(OpenRouterApiKeyManager)
final openRouterApiKeyManagerProvider = OpenRouterApiKeyManagerProvider._();

final class OpenRouterApiKeyManagerProvider
    extends $AsyncNotifierProvider<OpenRouterApiKeyManager, String?> {
  OpenRouterApiKeyManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openRouterApiKeyManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openRouterApiKeyManagerHash();

  @$internal
  @override
  OpenRouterApiKeyManager create() => OpenRouterApiKeyManager();
}

String _$openRouterApiKeyManagerHash() =>
    r'f7753c25dc5f47ac6fbe24c1697c88d3928ae4f7';

abstract class _$OpenRouterApiKeyManager extends $AsyncNotifier<String?> {
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

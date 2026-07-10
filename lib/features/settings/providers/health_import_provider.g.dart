// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_import_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HealthImport)
final healthImportProvider = HealthImportProvider._();

final class HealthImportProvider
    extends $NotifierProvider<HealthImport, HealthImportState> {
  HealthImportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthImportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthImportHash();

  @$internal
  @override
  HealthImport create() => HealthImport();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HealthImportState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HealthImportState>(value),
    );
  }
}

String _$healthImportHash() => r'd10d98cf4aa580fab643b1ef06d2bd7c2e2855ae';

abstract class _$HealthImport extends $Notifier<HealthImportState> {
  HealthImportState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<HealthImportState, HealthImportState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HealthImportState, HealthImportState>,
              HealthImportState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

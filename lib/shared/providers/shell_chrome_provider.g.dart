// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shell_chrome_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controls visibility of the shell floating tab dock.
///
/// Tracks an open-sheet depth count so chained modal sheets
/// (`pop` then immediately `show` another) stay chrome-hidden until the
/// last sheet dismisses.

@ProviderFor(ShellChrome)
final shellChromeProvider = ShellChromeProvider._();

/// Controls visibility of the shell floating tab dock.
///
/// Tracks an open-sheet depth count so chained modal sheets
/// (`pop` then immediately `show` another) stay chrome-hidden until the
/// last sheet dismisses.
final class ShellChromeProvider extends $NotifierProvider<ShellChrome, bool> {
  /// Controls visibility of the shell floating tab dock.
  ///
  /// Tracks an open-sheet depth count so chained modal sheets
  /// (`pop` then immediately `show` another) stay chrome-hidden until the
  /// last sheet dismisses.
  ShellChromeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shellChromeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shellChromeHash();

  @$internal
  @override
  ShellChrome create() => ShellChrome();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$shellChromeHash() => r'4d403da9accc20c6b0dfdf7fc926094de0f12b1f';

/// Controls visibility of the shell floating tab dock.
///
/// Tracks an open-sheet depth count so chained modal sheets
/// (`pop` then immediately `show` another) stay chrome-hidden until the
/// last sheet dismisses.

abstract class _$ShellChrome extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

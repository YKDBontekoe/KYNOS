// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shell_chrome_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controls visibility of the shell floating tab dock.
///
/// Modal sheets opened from nested branch navigators can sit under the dock
/// unless they use the root navigator; explicitly hiding chrome also matches
/// the product intent for focused menus like Model & mode.

@ProviderFor(ShellChrome)
final shellChromeProvider = ShellChromeProvider._();

/// Controls visibility of the shell floating tab dock.
///
/// Modal sheets opened from nested branch navigators can sit under the dock
/// unless they use the root navigator; explicitly hiding chrome also matches
/// the product intent for focused menus like Model & mode.
final class ShellChromeProvider extends $NotifierProvider<ShellChrome, bool> {
  /// Controls visibility of the shell floating tab dock.
  ///
  /// Modal sheets opened from nested branch navigators can sit under the dock
  /// unless they use the root navigator; explicitly hiding chrome also matches
  /// the product intent for focused menus like Model & mode.
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

String _$shellChromeHash() => r'5b4721efe3dbe73a823ebf9fec70b03ea893d0b0';

/// Controls visibility of the shell floating tab dock.
///
/// Modal sheets opened from nested branch navigators can sit under the dock
/// unless they use the root navigator; explicitly hiding chrome also matches
/// the product intent for focused menus like Model & mode.

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

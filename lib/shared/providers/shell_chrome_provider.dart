import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shell_chrome_provider.g.dart';

/// Controls visibility of the shell floating tab dock.
///
/// Modal sheets opened from nested branch navigators can sit under the dock
/// unless they use the root navigator; explicitly hiding chrome also matches
/// the product intent for focused menus like Model & mode.
@Riverpod(keepAlive: true)
class ShellChrome extends _$ShellChrome {
  @override
  bool build() => true;

  void show() => state = true;

  void hide() => state = false;
}

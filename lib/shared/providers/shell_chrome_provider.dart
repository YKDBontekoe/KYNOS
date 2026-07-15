import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shell_chrome_provider.g.dart';

/// Controls visibility of the shell floating tab dock.
///
/// Tracks an open-sheet depth count so chained modal sheets
/// (`pop` then immediately `show` another) stay chrome-hidden until the
/// last sheet dismisses.
@Riverpod(keepAlive: true)
class ShellChrome extends _$ShellChrome {
  int _openSheetCount = 0;

  @override
  bool build() => true;

  /// Increments open-sheet depth and hides chrome while any sheet is open.
  void acquire() {
    _openSheetCount += 1;
    if (state) state = false;
  }

  /// Decrements open-sheet depth and shows chrome only when depth hits zero.
  void release() {
    if (_openSheetCount > 0) {
      _openSheetCount -= 1;
    }
    if (_openSheetCount == 0 && !state) {
      state = true;
    }
  }
}

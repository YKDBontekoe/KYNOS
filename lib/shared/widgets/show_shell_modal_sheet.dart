import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/shared/providers/shell_chrome_provider.dart';

/// Shows a modal bottom sheet while temporarily hiding the shell tab dock.
///
/// Uses acquire/release depth tracking so chained sheets (`pop` then open
/// another) keep the floating nav hidden until the last sheet closes.
Future<T?> showShellModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  ShapeBorder? shape,
  bool isScrollControlled = false,
  bool useRootNavigator = true,
}) {
  final container = ProviderScope.containerOf(context);
  final chrome = container.read(shellChromeProvider.notifier);
  chrome.acquire();

  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor,
    shape: shape,
    builder: builder,
  ).whenComplete(chrome.release);
}

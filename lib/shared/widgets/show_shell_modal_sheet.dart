import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/shared/providers/shell_chrome_provider.dart';

/// Shows a modal bottom sheet while temporarily hiding the shell tab dock.
///
/// Always prefer this for coach (and other shell-tab) menus so the floating
/// nav cannot cover sheet actions like Delete thread.
Future<T?> showShellModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  ShapeBorder? shape,
  bool isScrollControlled = false,
  bool useRootNavigator = true,
}) {
  final container = ProviderScope.containerOf(context);
  container.read(shellChromeProvider.notifier).hide();

  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor,
    shape: shape,
    builder: builder,
  ).whenComplete(() {
    container.read(shellChromeProvider.notifier).show();
  });
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pops the current route or navigates to [fallbackRoute] when nothing to pop.
void popOrGo(BuildContext context, String fallbackRoute) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallbackRoute);
  }
}

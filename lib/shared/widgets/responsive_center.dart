import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kynos/core/theme/theme.dart';

/// Centers content on wide viewports (web/desktop) with a max width cap.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = LayoutTokens.maxContentWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && MediaQuery.sizeOf(context).width <= maxWidth) {
      return child;
    }

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: maxWidth,
        height: MediaQuery.sizeOf(context).height,
        child: child,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';

/// Uppercase section label (e.g. "HEALTH METRICS").
class KynosSectionHeader extends StatelessWidget {
  const KynosSectionHeader({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    return Text(
      title.toUpperCase(),
      style: kynos.sectionLabelStyle,
    );
  }
}

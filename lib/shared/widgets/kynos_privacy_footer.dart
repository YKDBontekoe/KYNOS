import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';

/// Privacy trust footer — lock icon + on-device data message.
class KynosPrivacyFooter extends StatelessWidget {
  const KynosPrivacyFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_rounded, size: 14, color: kynos.tertiaryLabel),
        const Gap(Spacing.sm),
        Text(
          'All data stays on your device',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

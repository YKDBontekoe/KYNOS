import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/gamification/earned_title.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';

class TitlesPanel extends StatelessWidget {
  const TitlesPanel({super.key, required this.titles});

  final List<EarnedTitle> titles;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final title in titles)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                size: 14,
                color: AppTheme.energy,
              ),
              const Gap(Spacing.xs),
              KynosChip.accent(
                label: title.name,
                color: AppTheme.energy,
              ),
            ],
          ),
      ],
    );
  }
}

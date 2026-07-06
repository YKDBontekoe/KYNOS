import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_loading_line.dart';

/// Indeterminate progress while parsing or importing a health data file.
class HealthImportProgressCard extends StatelessWidget {
  const HealthImportProgressCard({
    super.key,
    required this.fileName,
    required this.message,
  });

  final String fileName;
  final String message;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return KynosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insert_drive_file_outlined,
                color: kynos.secondaryLabel,
                size: 20,
              ),
              const Gap(tokens.Spacing.sm),
              Expanded(
                child: Text(
                  fileName,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Gap(tokens.Spacing.md),
          const KynosLoadingLine(height: 16, widthFactor: 1),
          const Gap(tokens.Spacing.sm),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: kynos.secondaryLabel,
                ),
          ),
        ],
      ),
    );
  }
}

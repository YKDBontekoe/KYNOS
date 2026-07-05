import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/features/settings/presentation/widgets/health_import_preview_row.dart';
import 'package:kynos/infrastructure/health/import/apple_health_export_parser.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

class AppleHealthExportPreviewCard extends StatelessWidget {
  const AppleHealthExportPreviewCard({
    super.key,
    required this.preview,
    required this.isImporting,
    required this.onImport,
  });

  final AppleHealthExportParseResult preview;
  final bool isImporting;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KynosCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apple Health export preview',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Gap(tokens.Spacing.sm),
              HealthImportPreviewRow(
                label: 'Health records',
                value: '${preview.recordCount}',
              ),
              HealthImportPreviewRow(
                label: 'Daily summaries',
                value: '${preview.summaries.length}',
              ),
              HealthImportPreviewRow(
                label: 'Running workouts',
                value: '${preview.workouts.length}',
              ),
              HealthImportPreviewRow(
                label: 'Runs with GPS routes',
                value:
                    '${preview.workouts.where((w) => w.routePoints.isNotEmpty).length}',
              ),
              if (preview.skippedWorkouts > 0)
                HealthImportPreviewRow(
                  label: 'Skipped workouts',
                  value: '${preview.skippedWorkouts}',
                ),
            ],
          ),
        ),
        const Gap(tokens.Spacing.md),
        FilledButton(
          onPressed: isImporting ? null : onImport,
          child: Text(isImporting ? 'Importing…' : 'Import all data'),
        ),
      ],
    );
  }
}

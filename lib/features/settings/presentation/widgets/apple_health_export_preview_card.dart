import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/features/settings/presentation/widgets/health_import_preview_row.dart';
import 'package:kynos/shared/providers/health_import_providers.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_loading_line.dart';

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

  Future<void> _confirmImport(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import all health data?'),
        content: Text(
          'This will import ${preview.recordCount} health records, '
          '${preview.summaries.length} daily summaries, and '
          '${preview.workouts.length} running workouts onto this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onImport();
    }
  }

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
        if (isImporting) ...[
          const Gap(tokens.Spacing.md),
          const KynosLoadingLine(
            height: 16,
            widthFactor: 1,
            label: 'Importing metrics and runs…',
          ),
        ],
        const Gap(tokens.Spacing.md),
        FilledButton(
          onPressed: isImporting ? null : () => _confirmImport(context),
          child: Text(isImporting ? 'Importing…' : 'Import all data'),
        ),
      ],
    );
  }
}

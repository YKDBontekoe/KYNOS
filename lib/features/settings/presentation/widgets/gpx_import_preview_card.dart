import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/features/settings/presentation/widgets/health_import_preview_row.dart';
import 'package:kynos/shared/providers/health_import_providers.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_loading_line.dart';

class GpxImportPreviewCard extends StatelessWidget {
  const GpxImportPreviewCard({
    super.key,
    required this.preview,
    required this.isImporting,
    required this.onImport,
  });

  final GpxParseResult preview;
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
                'GPX preview',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Gap(tokens.Spacing.sm),
              HealthImportPreviewRow(
                label: 'Date',
                value: _formatDate(preview.workout.start),
              ),
              HealthImportPreviewRow(
                label: 'Duration',
                value: _formatDuration(preview.workout.duration),
              ),
              HealthImportPreviewRow(
                label: 'Distance',
                value:
                    '${((preview.workout.distanceMeters ?? 0) / 1000).toStringAsFixed(2)} km',
              ),
              HealthImportPreviewRow(
                label: 'Route points',
                value: '${preview.routePoints.length}',
              ),
            ],
          ),
        ),
        if (isImporting) ...[
          const Gap(tokens.Spacing.md),
          const KynosLoadingLine(
            height: 16,
            widthFactor: 1,
            label: 'Saving run to your history…',
          ),
        ],
        const Gap(tokens.Spacing.md),
        FilledButton(
          onPressed: isImporting ? null : onImport,
          child: Text(isImporting ? 'Importing…' : 'Confirm import'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}

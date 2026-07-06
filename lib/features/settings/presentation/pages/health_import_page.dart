import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/features/settings/presentation/widgets/apple_health_export_preview_card.dart';
import 'package:kynos/features/settings/presentation/widgets/gpx_import_preview_card.dart';
import 'package:kynos/features/settings/presentation/widgets/health_import_progress_card.dart';
import 'package:kynos/features/settings/providers/health_import_provider.dart';

class HealthImportPage extends ConsumerWidget {
  const HealthImportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kynos = context.kynosTheme;
    final importState = ref.watch(healthImportProvider);

    ref.listen(healthImportProvider, (previous, next) {
      final message = next.importMessage;
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        ref.read(healthImportProvider.notifier).clearImportFeedback();
      }

      final error = next.error;
      if (error != null &&
          error != previous?.error &&
          !next.isParsing &&
          !next.isImporting &&
          (next.gpxPreview != null || next.zipPreview != null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }

      final workout = next.importedWorkout;
      if (workout != null) {
        context.push(Routes.runRoute, extra: workout);
        ref.read(healthImportProvider.notifier).clearImportFeedback();
      }
    });

    return Scaffold(
      backgroundColor: kynos.background,
      appBar: AppBar(title: const Text('Import Health Data')),
      body: ListView(
        padding: const EdgeInsets.all(tokens.Spacing.md),
        children: [
          Text(
            'Sideloaded apps may not access HealthKit. Import your full Apple '
            'Health export.zip, or a single GPX route from Garmin or Strava.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Gap(tokens.Spacing.sm),
          Text(
            'Your file stays on this device and is never uploaded.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: kynos.secondaryLabel,
                ),
          ),
          const Gap(tokens.Spacing.lg),
          FilledButton.icon(
            onPressed: importState.isBusy
                ? null
                : () => ref.read(healthImportProvider.notifier).pickFile(),
            icon: const Icon(Icons.upload_file_outlined),
            label: Text(
              importState.isParsing ? 'Processing file…' : 'Choose export.zip or GPX',
            ),
          ),
          if (importState.isParsing &&
              importState.processingFileName != null &&
              importState.progressMessage != null) ...[
            const Gap(tokens.Spacing.lg),
            HealthImportProgressCard(
              fileName: importState.processingFileName!,
              message: importState.progressMessage!,
            ),
          ],
          if (importState.error != null &&
              importState.gpxPreview == null &&
              importState.zipPreview == null &&
              !importState.isParsing) ...[
            const Gap(tokens.Spacing.md),
            Text(
              importState.error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: kynos.move,
                  ),
            ),
          ],
          if (importState.zipPreview != null) ...[
            const Gap(tokens.Spacing.lg),
            AppleHealthExportPreviewCard(
              preview: importState.zipPreview!,
              isImporting: importState.isImporting,
              onImport: () =>
                  ref.read(healthImportProvider.notifier).confirmImport(),
            ),
          ],
          if (importState.gpxPreview != null) ...[
            const Gap(tokens.Spacing.lg),
            GpxImportPreviewCard(
              preview: importState.gpxPreview!,
              isImporting: importState.isImporting,
              onImport: () =>
                  ref.read(healthImportProvider.notifier).confirmImport(),
            ),
          ],
        ],
      ),
    );
  }
}

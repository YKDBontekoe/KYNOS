import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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
import 'package:kynos/shared/providers/health_providers.dart';

class HealthImportPage extends ConsumerStatefulWidget {
  const HealthImportPage({super.key});

  @override
  ConsumerState<HealthImportPage> createState() => _HealthImportPageState();
}

class _HealthImportPageState extends ConsumerState<HealthImportPage> {
  PlatformFile? _pickedFile;

  Future<void> _pickFile() async {
    setState(() => _pickedFile = null);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['gpx', 'zip'],
      withData: kIsWeb,
    );

    if (!mounted || result == null || result.files.isEmpty) return;

    final file = result.files.single;
    setState(() => _pickedFile = file);
    await ref.read(healthImportNotifierProvider.notifier).previewFile(file);
  }

  Future<void> _confirmImport() async {
    try {
      final result = await ref
          .read(healthImportNotifierProvider.notifier)
          .importSelected(_pickedFile);

      if (!mounted || result == null) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );

      final workout = result.importedWorkout;
      if (workout != null && mounted) {
        await context.push(Routes.runRoute, extra: workout);
      }
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_formatImportError(e))),
      );
    }
  }

  String _formatImportError(Object error) => error.toString();

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final importState = ref.watch(healthImportNotifierProvider);

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
            onPressed: importState.isBusy ? null : _pickFile,
            icon: const Icon(Icons.upload_file_outlined),
            label: Text(
              importState.isParsing
                  ? 'Processing file…'
                  : 'Choose export.zip or GPX',
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
          if (importState.errorMessage != null) ...[
            const Gap(tokens.Spacing.md),
            Text(
              importState.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: kynos.move,
                  ),
            ),
          ],
          if (importState.appleHealthPreview != null) ...[
            const Gap(tokens.Spacing.lg),
            AppleHealthExportPreviewCard(
              preview: importState.appleHealthPreview!,
              isImporting: importState.isImporting,
              onImport: _confirmImport,
            ),
          ],
          if (importState.gpxPreview != null) ...[
            const Gap(tokens.Spacing.lg),
            GpxImportPreviewCard(
              preview: importState.gpxPreview!,
              isImporting: importState.isImporting,
              onImport: _confirmImport,
            ),
          ],
        ],
      ),
    );
  }
}

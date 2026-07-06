import 'dart:convert';

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
import 'package:kynos/infrastructure/health/health_infrastructure_providers.dart';
import 'package:kynos/infrastructure/health/import/apple_health_export_isolate.dart';
import 'package:kynos/infrastructure/health/import/apple_health_export_parser.dart';
import 'package:kynos/infrastructure/health/import/gpx_workout_parser.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/utils/picked_file_bytes.dart';

class HealthImportPage extends ConsumerStatefulWidget {
  const HealthImportPage({super.key});

  @override
  ConsumerState<HealthImportPage> createState() => _HealthImportPageState();
}

class _HealthImportPageState extends ConsumerState<HealthImportPage> {
  GpxParseResult? _gpxPreview;
  AppleHealthExportParseResult? _zipPreview;
  PlatformFile? _pickedFile;
  String? _error;
  bool _isParsing = false;
  bool _isImporting = false;
  String? _processingFileName;
  String? _progressMessage;

  bool get _isBusy => _isParsing || _isImporting;

  Future<void> _pickFile() async {
    setState(() {
      _gpxPreview = null;
      _zipPreview = null;
      _pickedFile = null;
      _error = null;
      _isParsing = false;
      _processingFileName = null;
      _progressMessage = null;
    });

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['gpx', 'zip'],
      withData: kIsWeb,
    );

    if (!mounted || result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final extension = file.extension?.toLowerCase();
    final isZip = extension == 'zip';

    setState(() {
      _isParsing = true;
      _processingFileName = file.name;
      _progressMessage = isZip
          ? 'Reading and parsing your Apple Health export. '
              'Large archives can take a minute.'
          : 'Reading GPX route file…';
    });

    try {
      if (isZip) {
        final bytes = file.path == null ? await readPickedFileBytes(file) : null;
        final parsed = await parseAppleHealthZipAsync(
          zipPath: file.path,
          zipBytes: bytes,
        );
        if (!mounted) return;
        setState(() {
          _zipPreview = parsed;
          _pickedFile = file;
          _isParsing = false;
          _processingFileName = null;
          _progressMessage = null;
        });
      } else {
        final bytes = await readPickedFileBytes(file);
        final parsed = const GpxWorkoutParser().parse(
          utf8.decode(bytes, allowMalformed: true),
        );
        if (!mounted) return;
        setState(() {
          _gpxPreview = parsed;
          _pickedFile = file;
          _isParsing = false;
          _processingFileName = null;
          _progressMessage = null;
        });
      }
    } on OutOfMemoryError {
      if (!mounted) return;
      setState(() {
        _error =
            'This export is too large for available memory. '
            'Try exporting a shorter date range from the Health app.';
        _isParsing = false;
        _processingFileName = null;
        _progressMessage = null;
      });
    } on FormatException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isParsing = false;
        _processingFileName = null;
        _progressMessage = null;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to parse file: $e';
        _isParsing = false;
        _processingFileName = null;
        _progressMessage = null;
      });
    }
  }

  Future<void> _confirmImport() async {
    setState(() => _isImporting = true);

    final pickedFile = _pickedFile;
    final isZip = pickedFile?.extension?.toLowerCase() == 'zip';

    if (pickedFile != null && (_zipPreview != null || isZip)) {
      await _importZip(pickedFile);
    } else if (_gpxPreview != null) {
      await _importGpx();
    }

    if (mounted) {
      setState(() => _isImporting = false);
    }
  }

  Future<void> _importGpx() async {
    final preview = _gpxPreview;
    if (preview == null) return;

    final useCase = ref.read(importWorkoutUseCaseProvider);
    final result = await useCase(
      workout: preview.workout,
      routePoints: preview.routePoints,
    );

    if (!mounted) return;

    if (result.failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.failure!.message)),
      );
      return;
    }

    _invalidateHealthProviders();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Run imported successfully.')),
    );

    if (result.workout != null && mounted) {
      await context.push(Routes.runRoute, extra: result.workout);
    }
  }

  Future<void> _importZip(PlatformFile file) async {
    final preview = _zipPreview;
    final bytes = preview == null && file.path == null
        ? await readPickedFileBytes(file)
        : null;
    final useCase = ref.read(importAppleHealthExportUseCaseProvider);
    final result = await useCase(
      parsed: preview,
      zipPath: preview == null ? file.path : null,
      zipBytes: bytes,
    );

    if (!mounted) return;

    if (result.failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.failure!.message)),
      );
      return;
    }

    _invalidateHealthProviders();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Imported ${result.importedDays} days of metrics and '
          '${result.importedWorkouts} runs.',
        ),
      ),
    );
  }

  void _invalidateHealthProviders() {
    ref.invalidate(healthSummaryProvider);
    ref.invalidate(healthHistoryProvider);
    ref.invalidate(recentRunsProvider);
    ref.invalidate(importedWorkoutCountProvider);
  }

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

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
            onPressed: _isBusy ? null : _pickFile,
            icon: const Icon(Icons.upload_file_outlined),
            label: Text(
              _isParsing ? 'Processing file…' : 'Choose export.zip or GPX',
            ),
          ),
          if (_isParsing &&
              _processingFileName != null &&
              _progressMessage != null) ...[
            const Gap(tokens.Spacing.lg),
            HealthImportProgressCard(
              fileName: _processingFileName!,
              message: _progressMessage!,
            ),
          ],
          if (_error != null) ...[
            const Gap(tokens.Spacing.md),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: kynos.move,
                  ),
            ),
          ],
          if (_zipPreview != null) ...[
            const Gap(tokens.Spacing.lg),
            AppleHealthExportPreviewCard(
              preview: _zipPreview!,
              isImporting: _isImporting,
              onImport: _confirmImport,
            ),
          ],
          if (_gpxPreview != null) ...[
            const Gap(tokens.Spacing.lg),
            GpxImportPreviewCard(
              preview: _gpxPreview!,
              isImporting: _isImporting,
              onImport: _confirmImport,
            ),
          ],
        ],
      ),
    );
  }
}

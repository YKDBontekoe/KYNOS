import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/infrastructure/health/health_infrastructure_providers.dart';
import 'package:kynos/infrastructure/health/import/apple_health_export_parser.dart';
import 'package:kynos/infrastructure/health/import/gpx_workout_parser.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

class HealthImportPage extends ConsumerStatefulWidget {
  const HealthImportPage({super.key});

  @override
  ConsumerState<HealthImportPage> createState() => _HealthImportPageState();
}

class _HealthImportPageState extends ConsumerState<HealthImportPage> {
  GpxParseResult? _gpxPreview;
  AppleHealthExportParseResult? _zipPreview;
  List<int>? _zipBytes;
  String? _error;
  bool _isImporting = false;

  Future<void> _pickFile() async {
    setState(() {
      _gpxPreview = null;
      _zipPreview = null;
      _zipBytes = null;
      _error = null;
    });

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['gpx', 'zip'],
      withData: true,
    );

    if (!mounted || result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      setState(() => _error = 'Could not read the selected file.');
      return;
    }

    final extension = file.extension?.toLowerCase();
    try {
      if (extension == 'zip') {
        final parsed = const AppleHealthExportParser().parseZip(bytes);
        setState(() {
          _zipPreview = parsed;
          _zipBytes = bytes;
        });
      } else {
        final content = String.fromCharCodes(bytes);
        final parsed = const GpxWorkoutParser().parse(content);
        setState(() => _gpxPreview = parsed);
      }
    } on FormatException catch (e) {
      setState(() => _error = e.message);
    } on Object catch (e) {
      setState(() => _error = 'Failed to parse file: $e');
    }
  }

  Future<void> _confirmImport() async {
    setState(() => _isImporting = true);

    if (_zipPreview != null && _zipBytes != null) {
      await _importZip(_zipBytes!);
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

  Future<void> _importZip(List<int> bytes) async {
    final useCase = ref.read(importAppleHealthExportUseCaseProvider);
    final result = await useCase(zipBytes: bytes);

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
    final zipPreview = _zipPreview;
    final gpxPreview = _gpxPreview;

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
            onPressed: _isImporting ? null : _pickFile,
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Choose export.zip or GPX'),
          ),
          if (_error != null) ...[
            const Gap(tokens.Spacing.md),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: kynos.move,
                  ),
            ),
          ],
          if (zipPreview != null) ...[
            const Gap(tokens.Spacing.lg),
            KynosCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apple Health export preview',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Gap(tokens.Spacing.sm),
                  _PreviewRow(
                    label: 'Health records',
                    value: '${zipPreview.recordCount}',
                  ),
                  _PreviewRow(
                    label: 'Daily summaries',
                    value: '${zipPreview.summaries.length}',
                  ),
                  _PreviewRow(
                    label: 'Running workouts',
                    value: '${zipPreview.workouts.length}',
                  ),
                  _PreviewRow(
                    label: 'Runs with GPS routes',
                    value:
                        '${zipPreview.workouts.where((w) => w.routePoints.isNotEmpty).length}',
                  ),
                  if (zipPreview.skippedWorkouts > 0)
                    _PreviewRow(
                      label: 'Skipped workouts',
                      value: '${zipPreview.skippedWorkouts}',
                    ),
                ],
              ),
            ),
            const Gap(tokens.Spacing.md),
            FilledButton(
              onPressed: _isImporting ? null : _confirmImport,
              child: Text(_isImporting ? 'Importing…' : 'Import all data'),
            ),
          ],
          if (gpxPreview != null) ...[
            const Gap(tokens.Spacing.lg),
            KynosCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GPX preview',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Gap(tokens.Spacing.sm),
                  _PreviewRow(
                    label: 'Date',
                    value: _formatDate(gpxPreview.workout.start),
                  ),
                  _PreviewRow(
                    label: 'Duration',
                    value: _formatDuration(gpxPreview.workout.duration),
                  ),
                  _PreviewRow(
                    label: 'Distance',
                    value:
                        '${((gpxPreview.workout.distanceMeters ?? 0) / 1000).toStringAsFixed(2)} km',
                  ),
                  _PreviewRow(
                    label: 'Route points',
                    value: '${gpxPreview.routePoints.length}',
                  ),
                ],
              ),
            ),
            const Gap(tokens.Spacing.md),
            FilledButton(
              onPressed: _isImporting ? null : _confirmImport,
              child: Text(_isImporting ? 'Importing…' : 'Confirm import'),
            ),
          ],
        ],
      ),
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

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: tokens.Spacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

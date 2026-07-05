import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/infrastructure/health/health_infrastructure_providers.dart';
import 'package:kynos/infrastructure/health/import/gpx_workout_parser.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

class HealthImportPage extends ConsumerStatefulWidget {
  const HealthImportPage({super.key});

  @override
  ConsumerState<HealthImportPage> createState() => _HealthImportPageState();
}

class _HealthImportPageState extends ConsumerState<HealthImportPage> {
  GpxParseResult? _preview;
  String? _error;
  bool _isImporting = false;

  Future<void> _pickGpxFile() async {
    setState(() {
      _preview = null;
      _error = null;
    });

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['gpx'],
      withData: true,
    );

    if (!mounted || result == null || result.files.isEmpty) return;

    final bytes = result.files.single.bytes;
    if (bytes == null) {
      setState(() => _error = 'Could not read the selected file.');
      return;
    }

    try {
      final content = String.fromCharCodes(bytes);
      final parsed = const GpxWorkoutParser().parse(content);
      setState(() => _preview = parsed);
    } on FormatException catch (e) {
      setState(() => _error = e.message);
    } on Object catch (e) {
      setState(() => _error = 'Failed to parse GPX: $e');
    }
  }

  Future<void> _confirmImport() async {
    final preview = _preview;
    if (preview == null) return;

    setState(() => _isImporting = true);

    final useCase = ref.read(importWorkoutUseCaseProvider);
    final result = await useCase(
      workout: preview.workout,
      routePoints: preview.routePoints,
    );

    if (!mounted) return;

    setState(() => _isImporting = false);

    if (result.failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.failure!.message)),
      );
      return;
    }

    ref.invalidate(healthSummaryProvider);
    ref.invalidate(healthHistoryProvider);
    ref.invalidate(recentRunsProvider);
    ref.invalidate(importedWorkoutCountProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Run imported successfully.')),
    );

    if (result.workout != null && mounted) {
      await context.push(Routes.runRoute, extra: result.workout);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return Scaffold(
      backgroundColor: kynos.background,
      appBar: AppBar(title: const Text('Import Run')),
      body: ListView(
        padding: const EdgeInsets.all(tokens.Spacing.md),
        children: [
          Text(
            'Sideloaded apps may not access HealthKit. Import a GPX file '
            'exported from Garmin, Strava, or Apple Fitness instead.',
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
            onPressed: _isImporting ? null : _pickGpxFile,
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Choose GPX file'),
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
          if (_preview != null) ...[
            const Gap(tokens.Spacing.lg),
            KynosCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Gap(tokens.Spacing.sm),
                  _PreviewRow(
                    label: 'Date',
                    value: _formatDate(_preview!.workout.start),
                  ),
                  _PreviewRow(
                    label: 'Duration',
                    value: _formatDuration(_preview!.workout.duration),
                  ),
                  _PreviewRow(
                    label: 'Distance',
                    value:
                        '${((_preview!.workout.distanceMeters ?? 0) / 1000).toStringAsFixed(2)} km',
                  ),
                  _PreviewRow(
                    label: 'Route points',
                    value: '${_preview!.routePoints.length}',
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

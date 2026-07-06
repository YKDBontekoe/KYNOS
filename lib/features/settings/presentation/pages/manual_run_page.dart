import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/features/settings/providers/manual_run_provider.dart';
import 'package:kynos/shared/utils/health_platform_labels.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

class ManualRunPage extends ConsumerStatefulWidget {
  const ManualRunPage({super.key});

  @override
  ConsumerState<ManualRunPage> createState() => _ManualRunPageState();
}

class _ManualRunPageState extends ConsumerState<ManualRunPage> {
  final _durationMinutesController = TextEditingController(text: '45');
  final _distanceKmController = TextEditingController(text: '5');
  final _caloriesController = TextEditingController();

  @override
  void dispose() {
    _durationMinutesController.dispose();
    _distanceKmController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final runState = ref.read(manualRunProvider);
    final date = await showDatePicker(
      context: context,
      initialDate: runState.start,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (!mounted || date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(runState.start),
    );
    if (!mounted || time == null) return;

    ref.read(manualRunProvider.notifier).setStart(
          DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          ),
        );
  }

  Future<void> _saveRun() async {
    final durationMinutes = int.tryParse(_durationMinutesController.text);
    final distanceKm = double.tryParse(_distanceKmController.text);
    final calories = double.tryParse(_caloriesController.text);

    if (durationMinutes == null) {
      _showError('Enter a valid duration in minutes.');
      return;
    }
    if (distanceKm == null) {
      _showError('Enter a valid distance in km.');
      return;
    }

    await ref.read(manualRunProvider.notifier).saveRun(
          durationMinutes: durationMinutes,
          distanceKm: distanceKm,
          calories: calories,
        );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final runState = ref.watch(manualRunProvider);

    ref.listen(manualRunProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        _showError(next.error!);
      }
      if (next.saveSucceeded && previous?.saveSucceeded != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Run saved successfully.')),
        );
        context.pop();
      }
    });

    return Scaffold(
      backgroundColor: kynos.background,
      appBar: AppBar(title: const Text('Log Run')),
      body: ListView(
        padding: const EdgeInsets.all(tokens.Spacing.md),
        children: [
          Text(
            'Log a run manually when ${HealthPlatformLabels.platformName()} is unavailable or you have no GPX file.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Gap(tokens.Spacing.lg),
          KynosCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Start time'),
                  subtitle: Text(_formatDateTime(runState.start)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: runState.isSaving ? null : _pickStartDate,
                ),
                const Gap(tokens.Spacing.sm),
                TextField(
                  controller: _durationMinutesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration (minutes)',
                  ),
                ),
                const Gap(tokens.Spacing.sm),
                TextField(
                  controller: _distanceKmController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Distance (km)',
                  ),
                ),
                const Gap(tokens.Spacing.sm),
                TextField(
                  controller: _caloriesController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Calories (optional)',
                  ),
                ),
              ],
            ),
          ),
          const Gap(tokens.Spacing.lg),
          FilledButton(
            onPressed: runState.isSaving ? null : _saveRun,
            child: Text(runState.isSaving ? 'Saving…' : 'Save run'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

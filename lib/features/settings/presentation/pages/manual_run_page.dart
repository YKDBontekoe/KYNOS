import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/core/constants/imported_workout_ids.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

class ManualRunPage extends ConsumerStatefulWidget {
  const ManualRunPage({super.key});

  @override
  ConsumerState<ManualRunPage> createState() => _ManualRunPageState();
}

class _ManualRunPageState extends ConsumerState<ManualRunPage> {
  DateTime _start = DateTime.now().subtract(const Duration(hours: 1));
  final _durationMinutesController = TextEditingController(text: '45');
  final _distanceKmController = TextEditingController(text: '5');
  final _caloriesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _durationMinutesController.dispose();
    _distanceKmController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (!mounted || date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
    );
    if (!mounted || time == null) return;

    setState(() {
      _start = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _saveRun() async {
    final durationMinutes = int.tryParse(_durationMinutesController.text);
    final distanceKm = double.tryParse(_distanceKmController.text);
    final calories = double.tryParse(_caloriesController.text);

    if (durationMinutes == null || durationMinutes <= 0) {
      _showError('Enter a valid duration in minutes.');
      return;
    }
    if (distanceKm == null || distanceKm <= 0) {
      _showError('Enter a valid distance in km.');
      return;
    }

    setState(() => _isSaving = true);

    final workout = WorkoutSession(
      id: ImportedWorkoutIds.generate(),
      start: _start,
      end: _start.add(Duration(minutes: durationMinutes)),
      workoutType: 'running',
      distanceMeters: distanceKm * 1000,
      energyKcal: calories,
      sourceName: 'Manual entry',
    );

    final useCase = ref.read(manualRunImportProvider);
    final result = await useCase.importWorkout(workout: workout);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result.failure != null) {
      _showError(result.failure!.message);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Run saved successfully.')),
    );
    context.pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return Scaffold(
      backgroundColor: kynos.background,
      appBar: AppBar(title: const Text('Log Run')),
      body: ListView(
        padding: const EdgeInsets.all(tokens.Spacing.md),
        children: [
          Text(
            'Log a run manually when HealthKit is unavailable or you have no GPX file.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Gap(tokens.Spacing.lg),
          KynosCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Start time'),
                  subtitle: Text(_formatDateTime(_start)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: _isSaving ? null : _pickStartDate,
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
            onPressed: _isSaving ? null : _saveRun,
            child: Text(_isSaving ? 'Saving…' : 'Save run'),
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

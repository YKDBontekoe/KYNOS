import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';

class HealthCheckInSheet extends StatefulWidget {
  const HealthCheckInSheet({super.key, this.initial});

  final HealthCheckIn? initial;

  @override
  State<HealthCheckInSheet> createState() => _HealthCheckInSheetState();
}

class _HealthCheckInSheetState extends State<HealthCheckInSheet> {
  late double _energy = (widget.initial?.energy ?? 3).toDouble();
  late double _mood = (widget.initial?.mood ?? 3).toDouble();
  late double _stress = (widget.initial?.stress ?? 3).toDouble();
  late double _soreness = (widget.initial?.soreness ?? 1).toDouble();
  late bool _feelingUnwell = widget.initial?.feelingUnwell ?? false;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _noteController.text = widget.initial?.note ?? '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.lg,
          Spacing.lg,
          Spacing.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How are you today?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Gap(Spacing.xs),
            Text(
              'Your experience can matter more than a wearable score.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Gap(Spacing.lg),
            _scale(
              'Energy',
              _energy,
              (value) => setState(() => _energy = value),
            ),
            _scale('Mood', _mood, (value) => setState(() => _mood = value)),
            _scale(
              'Stress',
              _stress,
              (value) => setState(() => _stress = value),
            ),
            _scale(
              'Soreness',
              _soreness,
              (value) => setState(() => _soreness = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('I feel unwell'),
              subtitle: const Text(
                'KYNOS will prioritise your report over activity suggestions.',
              ),
              value: _feelingUnwell,
              onChanged: (value) => setState(() => _feelingUnwell = value),
            ),
            const Gap(Spacing.sm),
            TextField(
              controller: _noteController,
              maxLength: 240,
              decoration: const InputDecoration(
                labelText: 'Optional private note',
                hintText: 'Anything unusual today?',
              ),
            ),
            const Gap(Spacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(
                  context,
                  HealthCheckIn(
                    date: DateTime.now(),
                    energy: _energy.round(),
                    mood: _mood.round(),
                    stress: _stress.round(),
                    soreness: _soreness.round(),
                    feelingUnwell: _feelingUnwell,
                    note: _noteController.text.trim().isEmpty
                        ? null
                        : _noteController.text.trim(),
                  ),
                ),
                child: const Text('Save check-in on this device'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scale(String label, double value, ValueChanged<double> onChanged) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label · ${value.round()}/5'),
          Slider(
            value: value,
            min: 1,
            max: 5,
            divisions: 4,
            label: value.round().toString(),
            onChanged: onChanged,
          ),
        ],
      );
}

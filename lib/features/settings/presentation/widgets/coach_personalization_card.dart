import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/coach/athlete_coach_profile.dart';
import 'package:kynos/domain/entities/coach/morning_check_in.dart';
import 'package:kynos/shared/providers/coach_personalization_provider.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_dropdown_field.dart';

class CoachPersonalizationCard extends ConsumerWidget {
  const CoachPersonalizationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(coachPersonalizationProvider);
    final checkIn = state.morningCheckIn;
    return KynosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.psychology_outlined),
            title: const Text('Coach personalization'),
            subtitle: Text(
              state.profile == null
                  ? 'Add goals and preferences for better daily advice'
                  : 'Goal: ${state.profile!.goal} · ${state.profile!.experience}',
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _editProfile(context, ref, state.profile),
                  child: const Text('Profile'),
                ),
              ),
              const Gap(tokens.Spacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: () => _editCheckIn(context, ref, checkIn),
                  child: Text(
                    checkIn == null ? 'Morning check-in' : 'Update check-in',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editProfile(
    BuildContext context,
    WidgetRef ref,
    AthleteCoachProfile? current,
  ) async {
    final goal = TextEditingController(
      text: current?.goal ?? 'general fitness',
    );
    var experience = current?.experience ?? 'recreational';
    final result = await showDialog<AthleteCoachProfile>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Coach profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: goal,
                decoration: const InputDecoration(labelText: 'Primary goal'),
              ),
              const Gap(tokens.Spacing.sm),
              KynosDropdownField<String>(
                value: experience,
                label: 'Experience',
                icon: Icons.trending_up_rounded,
                items: const [
                  DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                  DropdownMenuItem(
                    value: 'recreational',
                    child: Text('Recreational'),
                  ),
                  DropdownMenuItem(
                    value: 'experienced',
                    child: Text('Experienced'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => experience = value ?? experience),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                AthleteCoachProfile(
                  goal: goal.text.trim(),
                  experience: experience,
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    goal.dispose();
    if (result != null && context.mounted) {
      await ref.read(coachPersonalizationProvider.notifier).saveProfile(result);
    }
  }

  Future<void> _editCheckIn(
    BuildContext context,
    WidgetRef ref,
    MorningCheckIn? current,
  ) async {
    var fatigue = (current?.fatigue ?? 5).toDouble();
    var soreness = (current?.soreness ?? 3).toDouble();
    var motivation = (current?.motivation ?? 5).toDouble();
    final result = await showDialog<MorningCheckIn>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Morning check-in'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _slider('Fatigue', fatigue, (v) => setState(() => fatigue = v)),
              _slider(
                'Soreness',
                soreness,
                (v) => setState(() => soreness = v),
              ),
              _slider(
                'Motivation',
                motivation,
                (v) => setState(() => motivation = v),
              ),
              const Text('0 = none, 10 = very high'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                MorningCheckIn(
                  date: DateTime.now(),
                  fatigue: fatigue.round(),
                  soreness: soreness.round(),
                  motivation: motivation.round(),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (result != null && context.mounted) {
      await ref
          .read(coachPersonalizationProvider.notifier)
          .saveMorningCheckIn(result);
    }
  }

  Widget _slider(String label, double value, ValueChanged<double> onChanged) =>
      Row(
        children: [
          SizedBox(width: 88, child: Text('$label ${value.round()}/10')),
          Expanded(
            child: Slider(
              value: value,
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: onChanged,
            ),
          ),
        ],
      );
}

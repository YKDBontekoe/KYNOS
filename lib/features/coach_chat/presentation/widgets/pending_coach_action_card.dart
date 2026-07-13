import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/shared/providers/health_coach_providers.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

class PendingCoachActionCard extends ConsumerWidget {
  const PendingCoachActionCard({super.key, required this.action});

  final PendingCoachAction action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(healthCoachDataProvider).value;
    final confirmed = switch (action.type) {
      CoachActionType.saveMemory =>
        state?.memories.any((item) => item.id == action.id) ?? false,
      CoachActionType.createExperiment =>
        state?.experiments.any((item) => item.id == action.id) ?? false,
    };
    return KynosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(action.title, style: Theme.of(context).textTheme.titleMedium),
          const Gap(Spacing.xs),
          Text(action.explanation),
          const Gap(Spacing.sm),
          FilledButton.icon(
            onPressed: confirmed
                ? null
                : () async {
                    await ref
                        .read(healthCoachDataProvider.notifier)
                        .confirmAction(action);
                  },
            icon: Icon(confirmed ? Icons.check_rounded : Icons.lock_outline),
            label: Text(confirmed ? 'Confirmed' : 'Review and confirm'),
          ),
        ],
      ),
    );
  }
}

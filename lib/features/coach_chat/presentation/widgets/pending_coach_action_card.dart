import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/coach/training_plan.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/shared/providers/health_coach_providers.dart';
import 'package:kynos/shared/providers/training_plan_providers.dart';
import 'package:kynos/shared/providers/weekly_adaptation_provider.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

class PendingCoachActionCard extends ConsumerWidget {
  const PendingCoachActionCard({super.key, required this.action});

  final PendingCoachAction action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(healthCoachDataProvider).value;
    final plan = ref.watch(trainingPlanDataProvider).value;
    final confirmed = switch (action.type) {
      CoachActionType.saveMemory =>
        state?.memories.any((item) => item.id == action.id) ?? false,
      CoachActionType.createExperiment =>
        state?.experiments.any((item) => item.id == action.id) ?? false,
      CoachActionType.activateTrainingPlan =>
        _isTrainingPlanConfirmed(action, plan),
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
                    if (action.type == CoachActionType.activateTrainingPlan) {
                      await ref
                          .read(trainingPlanDataProvider.notifier)
                          .activateFromAction(action);
                      if (action.id.startsWith('weekly_adapt_')) {
                        await ref
                            .read(weeklyAdaptationProvider.notifier)
                            .markConfirmed();
                      }
                      return;
                    }
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

  bool _isTrainingPlanConfirmed(
    PendingCoachAction action,
    TrainingPlan? plan,
  ) {
    if (plan == null) return false;
    if (plan.id == action.id) return true;
    final raw = action.payload['planJson']?.toString();
    if (raw == null || raw.isEmpty) return false;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return false;
      final payloadPlan = TrainingPlan.fromJson(
        Map<String, Object?>.from(decoded),
      );
      // Weekly / day-swap proposals: confirmed when the proposed day matches.
      final adaptedDayRaw = action.payload['adaptedDay']?.toString();
      if (adaptedDayRaw != null) {
        final adaptedAt = DateTime.tryParse(adaptedDayRaw);
        if (adaptedAt != null) {
          final proposed = payloadPlan.dayFor(adaptedAt);
          final current = plan.dayFor(adaptedAt);
          if (proposed == null || current == null) return false;
          return current.sessionType == proposed.sessionType &&
              current.title == proposed.title &&
              current.adherence == PlanAdherenceStatus.swapped;
        }
      }
      // Full plan activation: same id is enough only after days align on day 0.
      if (payloadPlan.id != plan.id) return false;
      if (payloadPlan.days.isEmpty || plan.days.isEmpty) return false;
      final firstPayload = payloadPlan.days.first;
      final firstCurrent = plan.dayFor(firstPayload.date);
      return firstCurrent != null &&
          firstCurrent.title == firstPayload.title &&
          firstCurrent.sessionType == firstPayload.sessionType;
    } on Object {
      return false;
    }
  }
}

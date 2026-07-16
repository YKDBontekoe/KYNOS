import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart' hide Radius;
import 'package:kynos/domain/entities/coach/coach_chat_seed.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/features/coach_chat/providers/active_coach_conversation_provider.dart';
import 'package:kynos/features/coach_chat/providers/coach_conversations_provider.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/widgets/show_shell_modal_sheet.dart';

void showFocusRunPickerSheet(BuildContext context, WidgetRef ref) {
  showShellModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.kynosTheme.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.Radius.xl)),
    ),
    builder: (context) => const FocusRunPickerSheet(),
  );
}

class FocusRunPickerSheet extends ConsumerWidget {
  const FocusRunPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runsAsync = ref.watch(recentRunsProvider(days: 60, limit: 20));

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.md,
        Spacing.md,
        MediaQuery.paddingOf(context).bottom + Spacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Attach focus run',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(Spacing.md),
          runsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Could not load runs: $e'),
            data: (runs) {
              if (runs.isEmpty) {
                return const Text('No recent runs available');
              }
              return SizedBox(
                height: 320,
                child: ListView.builder(
                  itemCount: runs.length,
                  itemBuilder: (context, index) {
                    final run = runs[index];
                    return ListTile(
                      title: Text(_runTitle(run)),
                      subtitle: Text(
                        '${(run.distanceMeters ?? 0) / 1000} km · ${run.start}',
                      ),
                      onTap: () => _attachRun(context, ref, run),
                    );
                  },
                ),
              );
            },
          ),
          TextButton(
            onPressed: () => _clearFocusRun(context, ref),
            child: const Text('Clear focus run'),
          ),
        ],
      ),
    );
  }

  String _runTitle(WorkoutSession run) => run.workoutType;

  Future<void> _attachRun(
    BuildContext context,
    WidgetRef ref,
    WorkoutSession run,
  ) async {
    final conversation = ref.read(activeCoachConversationProvider).value;
    if (conversation == null) return;
    final seed = (conversation.seed ?? const CoachChatSeedData()).copyWith(
      runId: run.id,
    );
    final updated = conversation.copyWith(
      seed: seed,
      updatedAt: DateTime.now(),
    );
    await ref.read(coachConversationsProvider.notifier).updateSummary(updated);
    ref.invalidate(activeCoachConversationProvider);
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _clearFocusRun(BuildContext context, WidgetRef ref) async {
    final conversation = ref.read(activeCoachConversationProvider).value;
    if (conversation == null) return;
    final seed = conversation.seed?.copyWith(runId: null);
    final updated = conversation.copyWith(
      seed: seed,
      updatedAt: DateTime.now(),
      clearSeed: conversation.seed != null &&
          (conversation.seed!.message == null ||
              conversation.seed!.message!.isEmpty),
    );
    await ref.read(coachConversationsProvider.notifier).updateSummary(updated);
    ref.invalidate(activeCoachConversationProvider);
    if (context.mounted) Navigator.pop(context);
  }
}

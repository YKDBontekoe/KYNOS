import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/coach/coach_backend_mode.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/context_inspector_sheet.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/conversation_list_sheet.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/focus_run_picker_sheet.dart';
import 'package:kynos/features/coach_chat/providers/active_coach_conversation_provider.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_provider.dart';
import 'package:kynos/features/coach_chat/providers/last_coach_context_provider.dart';
import 'package:kynos/shared/providers/settings_provider.dart';
import 'package:kynos/shared/utils/navigation_utils.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';

class CoachChatAppBar extends ConsumerWidget {
  const CoachChatAppBar({
    super.key,
    required this.onDeleteThread,
    required this.onExport,
  });

  final VoidCallback onDeleteThread;
  final VoidCallback onExport;

  void _close(BuildContext context) => popOrGo(context, Routes.dashboard);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backend = ref.watch(lastAiInferenceBackendProvider);
    final contextBadge = ref.watch(lastCoachContextProvider)?.contextBadge;
    final conversation = ref.watch(activeCoachConversationProvider).value;
    final globalSettings = ref.watch(settingsProvider);
    final kynos = context.kynosTheme;

    final modelName = switch (backend) {
      AiInferenceBackend.openRouter =>
        globalSettings.selectedCloudModelName ?? 'Cloud',
      _ => globalSettings.selectedLocalModelName,
    };
    final backendLabel = backend == AiInferenceBackend.openRouter
        ? 'Cloud · $modelName'
        : 'On-Device · $modelName';

    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.xs, Spacing.md, Spacing.sm),
            child: Row(
              children: [
                Semantics(
                  label: 'Close coach chat',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: kynos.secondaryLabel,
                    onPressed: () => _close(context),
                    tooltip: 'Close',
                  ),
                ),
                Semantics(
                  label: 'Conversation history',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.history_rounded),
                    color: kynos.secondaryLabel,
                    onPressed: () => showConversationListSheet(context),
                    tooltip: 'Conversations',
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation?.title ?? 'KYNOS Coach',
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (conversation?.settings.backendMode ==
                          CoachBackendMode.cloud)
                        Text(
                          'Cloud mode',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                    ],
                  ),
                ),
                _InferenceBadge(label: backendLabel, isCloud: backend == AiInferenceBackend.openRouter),
                const Gap(Spacing.xs),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, color: kynos.secondaryLabel),
                  onSelected: (value) {
                    switch (value) {
                      case 'context':
                        showContextInspectorSheet(context);
                      case 'focus_run':
                        showFocusRunPickerSheet(context, ref);
                      case 'export':
                        onExport();
                      case 'delete':
                        onDeleteThread();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'context', child: Text('Context sources')),
                    PopupMenuItem(value: 'focus_run', child: Text('Attach focus run')),
                    PopupMenuItem(value: 'export', child: Text('Export chat')),
                    PopupMenuItem(value: 'delete', child: Text('Delete thread')),
                  ],
                ),
              ],
            ),
          ),
          if (contextBadge != null && contextBadge.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, Spacing.sm),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => showContextInspectorSheet(context),
                  borderRadius: BorderRadius.circular(Radius.md),
                  child: KynosChip.accent(
                    label: contextBadge,
                    color: kynos.stand,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InferenceBadge extends StatelessWidget {
  const _InferenceBadge({required this.label, required this.isCloud});

  final String label;
  final bool isCloud;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final color = isCloud ? kynos.stand : kynos.exercise;
    final icon = isCloud ? Icons.cloud_outlined : Icons.lock_rounded;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const Gap(Spacing.xs),
        KynosChip.accent(label: label, color: color),
      ],
    );
  }
}

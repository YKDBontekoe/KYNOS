import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_provider.dart';
import 'package:kynos/shared/utils/navigation_utils.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';

class CoachChatAppBar extends ConsumerWidget {
  const CoachChatAppBar({super.key, required this.onClear});

  final VoidCallback onClear;

  void _close(BuildContext context) => popOrGo(context, Routes.dashboard);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backend = ref.watch(lastAiInferenceBackendProvider);
    final kynos = context.kynosTheme;
    return SafeArea(
      bottom: false,
      child: Padding(
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
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: kynos.exercise, shape: BoxShape.circle),
            ),
            const Gap(Spacing.sm),
            Text(
              'KYNOS Coach',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            _InferenceBadge(backend: backend),
            const Gap(Spacing.sm),
            Semantics(
              label: 'Clear conversation',
              button: true,
              child: Tooltip(
                message: 'Clear conversation',
                child: GestureDetector(
                  onTap: onClear,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: kynos.separator, borderRadius: BorderRadius.circular(Radius.md)),
                    child: Icon(Icons.refresh_rounded, size: 18, color: kynos.secondaryLabel),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InferenceBadge extends StatelessWidget {
  const _InferenceBadge({required this.backend});

  final AiInferenceBackend backend;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final isCloud = backend == AiInferenceBackend.openRouter;
    final color = isCloud ? kynos.stand : kynos.exercise;
    final label = isCloud ? 'Cloud' : 'On-Device';
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart' hide Radius;
import 'package:kynos/domain/entities/cloud_data_level.dart';
import 'package:kynos/domain/entities/coach/coach_conversation_settings.dart';
import 'package:kynos/domain/entities/coach/coach_data_source.dart';
import 'package:kynos/domain/utils/coach_context_formatter.dart';
import 'package:kynos/features/coach_chat/providers/active_coach_conversation_provider.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_provider.dart';
import 'package:kynos/features/coach_chat/providers/last_coach_context_provider.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/shared/providers/coach_context_provider.dart';
import 'package:kynos/shared/providers/coach_conversation_providers.dart';
import 'package:kynos/shared/providers/settings_provider.dart';
import 'package:kynos/shared/widgets/kynos_dropdown_field.dart';
import 'package:kynos/shared/widgets/show_shell_modal_sheet.dart';

void showContextInspectorSheet(BuildContext context) {
  showShellModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.kynosTheme.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.Radius.xl)),
    ),
    builder: (context) => const ContextInspectorSheet(),
  );
}

class ContextInspectorSheet extends ConsumerStatefulWidget {
  const ContextInspectorSheet({super.key});

  @override
  ConsumerState<ContextInspectorSheet> createState() =>
      _ContextInspectorSheetState();
}

class _ContextInspectorSheetState extends ConsumerState<ContextInspectorSheet> {
  bool _showPreview = false;

  Future<void> _toggleSource(
    CoachConversationSettings settings,
    CoachDataSource source,
    bool enabled,
  ) async {
    final nextPrefs = settings.contextPreferences.toggleSource(source, enabled);
    await ref.read(coachChatProvider.notifier).updateSettings(
          settings.copyWith(contextPreferences: nextPrefs),
        );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final conversation = ref.watch(activeCoachConversationProvider).value;
    final settings = conversation?.settings ?? CoachConversationSettings.defaults;
    final globalSettings = ref.watch(settingsProvider);
    final cloudConfigured = ref.watch(isCloudCoachConfiguredProvider).value ?? false;
    final fullContext = ref.watch(lastCoachContextProvider);
    final contextAsync = ref.watch(
      coachContextForConversationProvider(seed: conversation?.seed),
    );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return contextAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Context unavailable: $e')),
          data: (rawContext) {
            final filtered = ref.read(filterCoachContextUseCaseProvider).call(
                  context: rawContext,
                  preferences: settings.contextPreferences,
                );
            final cloudLevel = ref
                .read(filterCoachContextUseCaseProvider)
                .effectiveCloudLevel(
                  globalLevel: globalSettings.cloudDataLevel,
                  preferences: settings.contextPreferences,
                );
            final snapshots = ref.read(describeCoachContextUseCaseProvider).call(
                  context: rawContext,
                  preferences: settings.contextPreferences,
                  backendMode: settings.backendMode,
                  cloudConfigured: cloudConfigured,
                );
            final preview = CoachContextFormatter.formatForPrompt(
              filtered,
              cloudLevel: cloudLevel,
            );
            final estimatedTokens = (preview.length / 4).round();

            return ListView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(
                Spacing.md,
                Spacing.md,
                Spacing.md,
                MediaQuery.paddingOf(context).bottom + Spacing.lg,
              ),
              children: [
                Text(
                  'Coach context',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Gap(Spacing.sm),
                Text(
                  'Control which data sources are included in prompts. '
                  'Cloud level: ${cloudLevel.label}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Gap(Spacing.md),
                _BudgetMeter(estimatedTokens: estimatedTokens),
                const Gap(Spacing.md),
                for (final snapshot in snapshots)
                  SwitchListTile(
                    title: Text(snapshot.label),
                    subtitle: Text(snapshot.preview),
                    value: snapshot.isEnabled,
                    secondary: snapshot.willSendToCloud
                        ? Icon(Icons.cloud_outlined, color: kynos.stand, size: 18)
                        : Icon(Icons.lock_rounded, color: kynos.exercise, size: 18),
                    onChanged: (enabled) =>
                        _toggleSource(settings, snapshot.source, enabled),
                  ),
                const Gap(Spacing.sm),
                KynosDropdownField<CloudDataLevel>(
                  value: settings.contextPreferences.cloudLevelOverride ??
                      globalSettings.cloudDataLevel,
                  label: 'Cloud data level (this chat)',
                  icon: Icons.cloud_outlined,
                  items: CloudDataLevel.values
                      .map(
                        (level) => DropdownMenuItem(
                          value: level,
                          child: Text(level.label),
                        ),
                      )
                      .toList(),
                  onChanged: (level) async {
                    if (level == null) return;
                    await ref.read(coachChatProvider.notifier).updateSettings(
                          settings.copyWith(
                            contextPreferences: settings.contextPreferences
                                .copyWith(cloudLevelOverride: level),
                          ),
                        );
                  },
                ),
                const Gap(Spacing.md),
                ExpansionTile(
                  title: const Text('Preview prompt block'),
                  initiallyExpanded: _showPreview,
                  onExpansionChanged: (expanded) =>
                      setState(() => _showPreview = expanded),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(Spacing.md),
                      decoration: BoxDecoration(
                        color: kynos.separator,
                        borderRadius: BorderRadius.circular(tokens.Radius.md),
                      ),
                      child: SelectableText(
                        preview.isEmpty ? 'No context enabled' : preview,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                      ),
                    ),
                  ],
                ),
                if (fullContext != null) ...[
                  const Gap(Spacing.sm),
                  Text(
                    'Badge: ${fullContext.contextBadge}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _BudgetMeter extends StatelessWidget {
  const _BudgetMeter({required this.estimatedTokens});

  final int estimatedTokens;

  @override
  Widget build(BuildContext context) {
    const threshold = 800;
    final ratio = (estimatedTokens / threshold).clamp(0.0, 1.5);
    final kynos = context.kynosTheme;
    final willAutoCloud = estimatedTokens >= threshold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Context budget: ~$estimatedTokens tokens',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const Gap(Spacing.xs),
        LinearProgressIndicator(
          value: ratio > 1 ? 1 : ratio,
          backgroundColor: kynos.separator,
          color: willAutoCloud ? kynos.stand : kynos.exercise,
        ),
        const Gap(Spacing.xs),
        Text(
          willAutoCloud
              ? 'Auto mode may route to cloud (≥$threshold tokens)'
              : 'Auto mode stays on-device (<$threshold tokens)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

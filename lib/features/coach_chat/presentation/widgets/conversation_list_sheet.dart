import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart' hide Radius;
import 'package:kynos/domain/entities/coach/coach_conversation_summary.dart';
import 'package:kynos/domain/entities/coach/coach_seed_topic.dart';
import 'package:kynos/features/coach_chat/providers/active_coach_conversation_provider.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_provider.dart';
import 'package:kynos/features/coach_chat/providers/coach_conversations_provider.dart';
import 'package:kynos/shared/widgets/show_shell_modal_sheet.dart';

void showConversationListSheet(BuildContext context) {
  showShellModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.kynosTheme.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.Radius.xl)),
    ),
    builder: (context) => const ConversationListSheet(),
  );
}

class ConversationListSheet extends ConsumerStatefulWidget {
  const ConversationListSheet({super.key});

  @override
  ConsumerState<ConversationListSheet> createState() =>
      _ConversationListSheetState();
}

class _ConversationListSheetState extends ConsumerState<ConversationListSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openConversation(String id) async {
    await ref.read(coachConversationsProvider.notifier).switchConversation(id);
    ref.invalidate(coachChatProvider);
    ref.invalidate(activeCoachConversationProvider);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _createNewChat() async {
    final id =
        await ref.read(coachConversationsProvider.notifier).createConversation();
    if (id == null || !mounted) return;
    ref.invalidate(coachChatProvider);
    ref.invalidate(activeCoachConversationProvider);
    Navigator.pop(context);
  }

  Future<void> _deleteConversation(CoachConversationSummary summary) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete conversation?'),
        content: Text('Delete "${summary.title}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(coachConversationsProvider.notifier).deleteConversation(summary.id);
    ref.invalidate(coachChatProvider);
    ref.invalidate(activeCoachConversationProvider);
  }

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final conversations = ref.watch(coachConversationsProvider);
    final activeId = ref.watch(activeCoachConversationIdProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Column(
          children: [
            const Gap(Spacing.sm),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: kynos.separator,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.md,
                Spacing.md,
                Spacing.md,
                Spacing.sm,
              ),
              child: Row(
                children: [
                  Text(
                    'Conversations',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _createNewChat,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('New'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search conversations',
                  prefixIcon: const Icon(Icons.search_rounded),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.Radius.md),
                  ),
                ),
                onChanged: (value) => setState(() => _query = value.trim()),
              ),
            ),
            const Gap(Spacing.sm),
            Expanded(
              child: conversations.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Could not load: $e')),
                data: (summaries) {
                  final filtered = _query.isEmpty
                      ? summaries
                      : summaries.where((s) {
                          final q = _query.toLowerCase();
                          return s.title.toLowerCase().contains(q) ||
                              (s.lastMessagePreview?.toLowerCase().contains(q) ??
                                  false);
                        }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        _query.isEmpty
                            ? 'No conversations yet'
                            : 'No matches',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final summary = filtered[index];
                      final isActive = summary.id == activeId;
                      return ListTile(
                        selected: isActive,
                        leading: Icon(
                          summary.isPinned
                              ? Icons.push_pin_rounded
                              : Icons.chat_bubble_outline_rounded,
                          color: isActive ? kynos.stand : kynos.secondaryLabel,
                        ),
                        title: Text(
                          summary.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          summary.lastMessagePreview ?? _topicLabel(summary.seedTopic),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) async {
                            final notifier =
                                ref.read(coachConversationsProvider.notifier);
                            final conv =
                                await notifier.loadConversation(summary.id);
                            if (conv == null) return;
                            switch (action) {
                              case 'pin':
                                await notifier.updateSummary(
                                  conv.copyWith(isPinned: !conv.isPinned),
                                );
                              case 'archive':
                                await notifier.updateSummary(
                                  conv.copyWith(isArchived: !conv.isArchived),
                                );
                              case 'delete':
                                await _deleteConversation(summary);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'pin',
                              child: Text(
                                summary.isPinned ? 'Unpin' : 'Pin',
                              ),
                            ),
                            PopupMenuItem(
                              value: 'archive',
                              child: Text(
                                summary.isArchived ? 'Unarchive' : 'Archive',
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                        onTap: () => _openConversation(summary.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _topicLabel(CoachSeedTopic topic) {
    return switch (topic) {
      CoachSeedTopic.general => 'General coaching',
      CoachSeedTopic.metric => 'Metric focus',
      CoachSeedTopic.readiness => 'Readiness',
      CoachSeedTopic.run => 'Run focus',
      CoachSeedTopic.training => 'Training',
      CoachSeedTopic.gait => 'Gait',
      CoachSeedTopic.weeklyGoal => 'Weekly goal',
      CoachSeedTopic.postRunDebrief => 'Post-run debrief',
    };
  }
}

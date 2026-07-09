import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/glass_suggestion_chip.dart';

class FollowUpChips extends StatelessWidget {
  const FollowUpChips({
    super.key,
    required this.suggestions,
    required this.onTap,
  });

  final List<String> suggestions;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Follow up',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const Gap(Spacing.sm),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: [
              for (final suggestion in suggestions)
                GlassSuggestionChip(
                  label: suggestion,
                  onTap: () => onTap(suggestion),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

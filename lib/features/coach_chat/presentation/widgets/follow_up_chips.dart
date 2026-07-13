import 'package:flutter/material.dart';
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

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: Spacing.sm),
        itemBuilder: (context, index) => Center(
          child: GlassSuggestionChip(
            label: suggestions[index],
            onTap: () => onTap(suggestions[index]),
          ),
        ),
      ),
    );
  }
}

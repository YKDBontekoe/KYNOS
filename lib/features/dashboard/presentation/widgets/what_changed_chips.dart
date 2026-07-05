import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/insights/today_insights.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';

/// Horizontal highlight chips for top "what changed" insights.
class WhatChangedChips extends StatelessWidget {
  const WhatChangedChips({
    super.key,
    required this.insights,
  });

  final TodayInsights? insights;

  @override
  Widget build(BuildContext context) {
    if (insights == null || insights!.whatChanged.isEmpty) {
      return const SizedBox.shrink();
    }

    final kynos = context.kynosTheme;
    final chips = insights!.whatChanged.take(2).toList();

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, _) => const Gap(Spacing.sm),
        itemBuilder: (context, index) {
          return KynosChip.accent(
            label: _shorten(chips[index]),
            color: kynos.purple,
          );
        },
      ),
    );
  }

  String _shorten(String text) {
    if (text.length <= 48) return text;
    return '${text.substring(0, 45)}...';
  }
}

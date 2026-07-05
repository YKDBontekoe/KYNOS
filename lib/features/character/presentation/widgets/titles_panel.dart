import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/gamification/earned_title.dart';

class TitlesPanel extends StatelessWidget {
  const TitlesPanel({super.key, required this.titles});

  final List<EarnedTitle> titles;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final title in titles)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.separator,
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  size: 14,
                  color: AppTheme.energy,
                ),
                const Gap(Spacing.sm),
                Text(
                  title.name,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.label,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

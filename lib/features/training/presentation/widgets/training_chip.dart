import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;

/// Compact metadata chip for training insight cards.
class TrainingChip extends StatelessWidget {
  const TrainingChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: tokens.Spacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(tokens.Radius.md),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppTheme.secondaryLabel,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

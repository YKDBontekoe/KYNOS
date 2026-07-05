import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;

/// Chip size variants for badges and metric labels.
enum KynosChipSize { compact, standard, accent }

/// Unified chip / badge widget.
class KynosChip extends StatelessWidget {
  const KynosChip({
    super.key,
    required this.label,
    this.value,
    this.color,
    this.size = KynosChipSize.compact,
  });

  const KynosChip.metric({
    super.key,
    required this.label,
    required String this.value,
    this.color,
  }) : size = KynosChipSize.standard;

  const KynosChip.accent({
    super.key,
    required this.label,
    required Color this.color,
  })  : value = null,
        size = KynosChipSize.accent;

  final String label;
  final String? value;
  final Color? color;
  final KynosChipSize size;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return switch (size) {
      KynosChipSize.accent => _AccentChip(label: label, color: color!),
      KynosChipSize.standard => _MetricChip(label: label, value: value!),
      KynosChipSize.compact => Container(
          padding: const EdgeInsets.symmetric(
            horizontal: tokens.Spacing.sm,
            vertical: tokens.Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: kynos.background,
            borderRadius: BorderRadius.circular(tokens.Radius.md),
          ),
          child: Text(label, style: kynos.chipLabelStyle),
        ),
    };
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: tokens.Spacing.sm,
        vertical: tokens.Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: kynos.background,
        borderRadius: BorderRadius.circular(tokens.Radius.md),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: kynos.tertiaryLabel,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            TextSpan(
              text: value,
              style: GoogleFonts.dmMono(
                fontSize: 12,
                color: kynos.label,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccentChip extends StatelessWidget {
  const _AccentChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: tokens.Spacing.sm,
        vertical: tokens.Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(tokens.Radius.sm),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

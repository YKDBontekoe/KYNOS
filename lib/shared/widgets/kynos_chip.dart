import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/theme.dart';

/// Unified chip / badge widget.
class KynosChip extends StatelessWidget {
  const KynosChip({
    super.key,
    required this.label,
  })  : value = null,
        color = null,
        _size = _KynosChipVariant.compact;

  const KynosChip.metric({
    super.key,
    required this.label,
    required String this.value,
    this.color,
  }) : _size = _KynosChipVariant.metric;

  const KynosChip.accent({
    super.key,
    required this.label,
    required Color this.color,
  })  : value = null,
        _size = _KynosChipVariant.accent;

  final String label;
  final String? value;
  final Color? color;
  final _KynosChipVariant _size;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return switch (_size) {
      _KynosChipVariant.accent => _AccentChip(label: label, color: color!),
      _KynosChipVariant.metric => _MetricChip(label: label, value: value!),
      _KynosChipVariant.compact => Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: kynos.background,
            borderRadius: BorderRadius.circular(Radius.md),
          ),
          child: Text(label, style: kynos.chipLabelStyle),
        ),
    };
  }
}

enum _KynosChipVariant { compact, metric, accent }

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: kynos.background,
        borderRadius: BorderRadius.circular(Radius.md),
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
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(Radius.sm),
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

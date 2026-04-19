import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:shimmer/shimmer.dart';

/// Apple Fitness–style metric tile — white card, bold number, coloured icon dot.
class MetricTile extends StatelessWidget {
  final String label;
  final String? value;
  final String? unit;
  final IconData? icon;
  final Color? accentColor;

  const MetricTile({
    super.key,
    required this.label,
    this.value,
    this.unit,
    this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = accentColor ?? AppTheme.stand;

    return Container(
      padding: const EdgeInsets.all(tokens.Spacing.md),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coloured dot + label
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const Gap(6),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Gap(tokens.Spacing.sm),

          // Value + unit
          if (value == null)
            _Skeleton()
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value!,
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.label,
                    height: 1,
                    letterSpacing: -1,
                  ),
                ),
                if (unit != null) ...[
                  const Gap(3),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      unit!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.secondaryLabel,
                      ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.separator,
      highlightColor: AppTheme.background,
      child: Container(
        height: 32,
        width: 70,
        decoration: BoxDecoration(
          color: AppTheme.separator,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

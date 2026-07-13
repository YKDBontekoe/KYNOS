import 'package:flutter/material.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart' hide Radius;

/// A polished, card-styled dropdown for KYNOS forms and settings.
///
/// Wraps [DropdownButtonFormField] with the KYNOS filled-pill field look,
/// a leading icon, an animated chevron, and a themed floating menu — used
/// in place of bare [DropdownButtonFormField]/[DropdownButton] instances.
class KynosDropdownField<T> extends StatelessWidget {
  const KynosDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    this.icon,
    this.dense = false,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? label;
  final IconData? icon;

  /// Compact variant for inline use (e.g. list-tile trailing controls).
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final borderRadius = BorderRadius.circular(
      dense ? tokens.Radius.full : tokens.Radius.lg,
    );

    return DropdownButtonFormField<T>(
      key: ValueKey(value),
      initialValue: value,
      items: items,
      onChanged: onChanged,
      isDense: dense,
      isExpanded: !dense,
      borderRadius: BorderRadius.circular(tokens.Radius.md),
      dropdownColor: kynos.card,
      elevation: 6,
      icon: Icon(
        Icons.expand_more_rounded,
        size: dense ? 18 : 22,
        color: kynos.secondaryLabel,
      ),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: kynos.label,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        isDense: dense,
        labelText: dense ? null : label,
        filled: true,
        fillColor: dense ? kynos.background : kynos.card,
        contentPadding: dense
            ? const EdgeInsets.symmetric(
                horizontal: tokens.Spacing.md,
                vertical: tokens.Spacing.xs,
              )
            : const EdgeInsets.symmetric(
                horizontal: tokens.Spacing.md,
                vertical: tokens.Spacing.sm,
              ),
        prefixIcon: icon != null && !dense
            ? Icon(icon, color: kynos.stand, size: 20)
            : null,
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: kynos.separator),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: kynos.separator),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: kynos.stand, width: 1.5),
        ),
      ),
    );
  }
}

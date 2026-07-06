import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/shared/widgets/liquid_glass_surface.dart';

/// Glass pill suggestion chip with press-scale feedback.
class GlassSuggestionChip extends StatefulWidget {
  const GlassSuggestionChip({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  State<GlassSuggestionChip> createState() => _GlassSuggestionChipState();
}

class _GlassSuggestionChipState extends State<GlassSuggestionChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: Motion.fast,
    );
    _scale = Tween<double>(begin: 1, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Motion.curve),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _activate() {
    _pressController.reverse();
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: ScaleTransition(
        scale: _scale,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _activate,
            onHighlightChanged: (pressed) {
              if (pressed) {
                _pressController.forward();
              } else {
                _pressController.reverse();
              }
            },
            borderRadius: BorderRadius.circular(tokens.Radius.full),
            child: LiquidGlassSurface(
              borderRadius: tokens.Radius.full,
              padding: const EdgeInsets.symmetric(
                horizontal: tokens.Spacing.lg,
                vertical: tokens.Spacing.md,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

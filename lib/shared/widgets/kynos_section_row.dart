import 'package:flutter/material.dart';
import 'package:kynos/shared/widgets/kynos_section_header.dart';

/// Section header with an optional trailing action — Apple Health "See all" pattern.
class KynosSectionRow extends StatelessWidget {
  const KynosSectionRow({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    if (actionLabel == null || onAction == null) {
      return KynosSectionHeader(title: title);
    }

    return Row(
      children: [
        Expanded(child: KynosSectionHeader(title: title)),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(actionLabel!),
        ),
      ],
    );
  }
}

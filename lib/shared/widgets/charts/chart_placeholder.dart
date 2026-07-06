import 'package:flutter/material.dart';

/// Empty-state label shown inside chart areas.
class ChartPlaceholder extends StatelessWidget {
  const ChartPlaceholder({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

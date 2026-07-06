import 'package:flutter/material.dart';

/// Lightweight markdown-style rendering for coach replies (bold, bullets).
class CoachMarkdownText extends StatelessWidget {
  const CoachMarkdownText({
    super.key,
    required this.text,
    this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? Theme.of(context).textTheme.bodyLarge;
    final spans = <InlineSpan>[];
    final lines = text.split('\n');

    for (var i = 0; i < lines.length; i++) {
      if (i > 0) spans.add(const TextSpan(text: '\n'));
      final line = lines[i];
      if (line.trim().startsWith('- ') || line.trim().startsWith('* ')) {
        spans.add(TextSpan(text: '• ', style: baseStyle));
        spans.addAll(_parseInline(line.trim().substring(2), baseStyle));
      } else {
        spans.addAll(_parseInline(line, baseStyle));
      }
    }

    return SelectableText.rich(TextSpan(children: spans));
  }

  List<InlineSpan> _parseInline(String input, TextStyle? baseStyle) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*');
    var start = 0;

    for (final match in pattern.allMatches(input)) {
      if (match.start > start) {
        spans.add(TextSpan(text: input.substring(start, match.start), style: baseStyle));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: baseStyle?.copyWith(fontWeight: FontWeight.w700),
        ),
      );
      start = match.end;
    }

    if (start < input.length) {
      spans.add(TextSpan(text: input.substring(start), style: baseStyle));
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: input, style: baseStyle));
    }

    return spans;
  }
}

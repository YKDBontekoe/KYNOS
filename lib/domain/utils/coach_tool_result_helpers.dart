import 'package:kynos/domain/entities/coach/coach_data_source.dart';
import 'package:kynos/domain/entities/coach/coach_tool_call.dart';

/// Shared argument coercion and result-factory helpers for coach tool
/// implementations (see `lib/domain/usecases/coach/coach_tool_*.dart`).
abstract final class CoachToolResultHelpers {
  static int intArg(
    CoachToolCall call,
    String key, {
    required int fallback,
    required int min,
    required int max,
  }) {
    final raw = call.arguments[key];
    final value =
        raw is num ? raw.toInt() : int.tryParse(raw?.toString() ?? '') ?? fallback;
    return value.clamp(min, max);
  }

  static double doubleArg(
    CoachToolCall call,
    String key, {
    required double fallback,
    required double min,
    required double max,
  }) {
    final value = rawDoubleArg(call, key) ?? fallback;
    return value.clamp(min, max);
  }

  static double? rawDoubleArg(CoachToolCall call, String key) {
    final raw = call.arguments[key];
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw?.toString() ?? '');
  }

  static String? stringArg(CoachToolCall call, String key) {
    final raw = call.arguments[key];
    return raw?.toString();
  }

  static CoachToolResult disabled(CoachToolCall call, CoachDataSource source) {
    return CoachToolResult(
      call: call,
      isError: true,
      promptSummary:
          "${source.label} is disabled in this conversation's privacy settings; "
          'answer without it and do not ask again.',
      displayLabel: '${source.label} disabled',
    );
  }

  static CoachToolResult error(CoachToolCall call, String message) {
    return CoachToolResult(
      call: call,
      isError: true,
      promptSummary: message,
      displayLabel: 'Tool error',
    );
  }
}

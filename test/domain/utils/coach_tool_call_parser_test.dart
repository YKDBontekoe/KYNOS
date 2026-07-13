import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/utils/coach_tool_call_parser.dart';

void main() {
  group('CoachToolCallParser.tryParse', () {
    test('parses a well-formed directive', () {
      const text = 'TOOL_CALL: {"name":"get_recent_runs","arguments":{"limit":5}}';
      final call = CoachToolCallParser.tryParse(text);

      expect(call, isNotNull);
      expect(call!.name, 'get_recent_runs');
      expect(call.arguments['limit'], 5);
    });

    test('parses a directive with nested argument objects', () {
      const text = 'Some preamble\n'
          'TOOL_CALL: {"name":"compute_pace_plan","arguments":{"distance_km":10,"meta":{"x":1}}}';
      final call = CoachToolCallParser.tryParse(text);

      expect(call, isNotNull);
      expect(call!.name, 'compute_pace_plan');
      expect(call.arguments['distance_km'], 10);
      expect(call.arguments['meta'], {'x': 1});
    });

    test('returns null when there is no directive', () {
      expect(CoachToolCallParser.tryParse('Just a normal answer.'), isNull);
    });

    test('returns null for malformed JSON', () {
      expect(
        CoachToolCallParser.tryParse('TOOL_CALL: {not valid json'),
        isNull,
      );
    });

    test('returns null when name is missing', () {
      expect(
        CoachToolCallParser.tryParse('TOOL_CALL: {"arguments":{}}'),
        isNull,
      );
    });

    test('defaults arguments to empty map when absent', () {
      final call = CoachToolCallParser.tryParse('TOOL_CALL: {"name":"get_training_load"}');
      expect(call, isNotNull);
      expect(call!.arguments, isEmpty);
    });
  });

  group('CoachToolCallParser.stripToolCallMarkup', () {
    test('removes the directive and keeps surrounding text', () {
      const text = 'Before text\n'
          'TOOL_CALL: {"name":"get_training_load","arguments":{}}\n'
          'After text';
      final stripped = CoachToolCallParser.stripToolCallMarkup(text);

      expect(stripped, isNot(contains('TOOL_CALL')));
      expect(stripped, contains('Before text'));
      expect(stripped, contains('After text'));
    });

    test('returns original text unchanged when no directive present', () {
      const text = 'A normal coach answer.';
      expect(CoachToolCallParser.stripToolCallMarkup(text), text);
    });
  });

  group('CoachToolCallParser.isDefinitelyNotToolCall', () {
    test('rules out text starting with a different character', () {
      expect(CoachToolCallParser.isDefinitelyNotToolCall('Rest today.'), isTrue);
    });

    test('stays ambiguous while text still matches the marker prefix', () {
      expect(CoachToolCallParser.isDefinitelyNotToolCall('TOOL'), isFalse);
      expect(CoachToolCallParser.isDefinitelyNotToolCall('TOOL_CALL:'), isFalse);
    });

    test('rules out once text diverges from the marker', () {
      expect(CoachToolCallParser.isDefinitelyNotToolCall('Took'), isTrue);
    });

    test('returns false for empty or whitespace-only input', () {
      expect(CoachToolCallParser.isDefinitelyNotToolCall(''), isFalse);
      expect(CoachToolCallParser.isDefinitelyNotToolCall('   '), isFalse);
    });
  });
}

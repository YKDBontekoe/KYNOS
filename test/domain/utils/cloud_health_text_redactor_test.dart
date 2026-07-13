import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/utils/cloud_health_text_redactor.dart';

void main() {
  test('keeps ordinary wellbeing questions intact', () {
    const question = 'Why has my energy changed this week?';
    expect(CloudHealthTextRedactor.redact(question), question);
  });

  test('withholds free-form symptom wording', () {
    final redacted = CloudHealthTextRedactor.redact(
      'I felt dizzy and had a headache after lunch.',
    );

    expect(redacted, isNot(contains('dizzy')));
    expect(redacted, isNot(contains('headache')));
    expect(redacted, contains('withheld'));
  });
}

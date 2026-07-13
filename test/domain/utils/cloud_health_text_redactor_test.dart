import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/utils/cloud_health_text_redactor.dart';

void main() {
  test('extracts an approved intent without retaining original wording', () {
    const question = 'Why has my energy changed this week?';
    final redacted = CloudHealthTextRedactor.redact(question);
    expect(redacted, contains('energy and recovery'));
    expect(redacted, isNot(contains('this week')));
  });

  test('withholds free-form symptom wording', () {
    final redacted = CloudHealthTextRedactor.redact(
      'I felt dizzy and had a headache after lunch.',
    );

    expect(redacted, isNot(contains('dizzy')));
    expect(redacted, isNot(contains('headache')));
    expect(redacted, contains('withheld'));
  });

  test('withholds unmatched health and location details', () {
    final redacted = CloudHealthTextRedactor.redact(
      'My left ankle feels odd near Amsterdam Central at 18:42.',
    );

    expect(redacted, isNot(contains('ankle')));
    expect(redacted, isNot(contains('Amsterdam')));
    expect(redacted, isNot(contains('18:42')));
  });
}

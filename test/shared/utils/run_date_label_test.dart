import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/shared/utils/run_date_label.dart';

void main() {
  test('formatRunHeroDateLabel matches run card hero format', () {
    expect(
      formatRunHeroDateLabel(DateTime(2026, 7, 5)),
      'Jul 5, 2026',
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/theme/motion.dart';
import 'package:kynos/core/theme/theme.dart';

void main() {
  test('Motion tokens are exported from theme barrel', () {
    expect(Motion.fast, const Duration(milliseconds: 200));
    expect(Motion.medium, const Duration(milliseconds: 280));
    expect(Motion.ringSweep, const Duration(milliseconds: 600));
    expect(Motion.curve, isNotNull);
  });
}

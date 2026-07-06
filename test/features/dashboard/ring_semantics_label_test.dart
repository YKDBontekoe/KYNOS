import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/features/dashboard/presentation/widgets/activity_ring.dart';

void main() {
  test('ringSemanticsLabel describes ring progress', () {
    expect(
      ringSemanticsLabel(const [0.5, 0.25]),
      'Activity rings: Ring 1 50 percent, Ring 2 25 percent',
    );
  });
}

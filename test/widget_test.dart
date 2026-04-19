import 'package:flutter_test/flutter_test.dart';

import 'package:kynos/app/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const KynosApp());
    expect(find.byType(KynosApp), findsOneWidget);
  });
}

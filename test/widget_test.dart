import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/app/app.dart';
import 'package:kynos/features/coach_chat/presentation/pages/coach_chat_page.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/chat_input_bar.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/coach_chat_app_bar.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/message_list.dart';
import 'package:kynos/shared/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Chat input has a usable editing surface', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatInputBar(
            controller: TextEditingController(),
            focusNode: FocusNode(),
            isStreaming: false,
            onSend: (_) {},
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(EditableText)).height, greaterThan(20));
    expect(find.byType(EditableText).hitTestable(), findsOneWidget);
  });

  testWidgets('App renders without crashing', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const KynosApp(),
      ),
    );
    expect(find.byType(KynosApp), findsOneWidget);
  });

  testWidgets('Coach shell fills a wide web-style viewport without overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const KynosApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(
      tester.getSize(find.byType(CoachChatPage)).height,
      greaterThan(500),
    );
    expect(tester.getSize(find.byType(CoachChatAppBar)).height, lessThan(100));
    expect(
      tester.getSize(find.byType(CoachChatEmptyState)).height,
      greaterThan(300),
    );
    expect(tester.getSize(find.byType(ChatInputBar)).height, lessThan(100));
    expect(find.byType(EditableText), findsOneWidget);
    expect(tester.getSize(find.byType(EditableText)).height, greaterThan(20));
    expect(find.byType(EditableText).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(find.text('Coach'), findsOneWidget);
    expect(find.text('Health'), findsOneWidget);
    expect(find.text('Journey'), findsOneWidget);
  });
}

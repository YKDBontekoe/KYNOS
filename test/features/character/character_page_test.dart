import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/features/character/presentation/pages/character_page.dart';
import 'package:kynos/shared/providers/camp_providers.dart';
import 'package:kynos/shared/providers/character_providers.dart';
import 'package:kynos/shared/providers/daily_quests_provider.dart';
import 'package:kynos/shared/providers/health_coach_providers.dart';
import 'package:kynos/shared/providers/nexus_lab_provider.dart';

class _StubCampSession extends CampSessionNotifier {
  @override
  Future<CampViewState?> build() async => null;
}

class _StubHealthCoachData extends HealthCoachData {
  @override
  Future<HealthCoachState> build() async => const HealthCoachState();
}

class _StubNexusLab extends NexusLabNotifier {
  @override
  Future<NexusLabState> build() async => NexusLabState(
        coefficients: (b0: null, b1: null, b2: null),
      );
}

void main() {
  testWidgets('CharacterPage renders large title header', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          runnerCharacterProvider.overrideWith((ref) async => null),
          dailyQuestsProvider.overrideWith((ref) async => const []),
          campSessionProvider.overrideWith(_StubCampSession.new),
          healthCoachDataProvider.overrideWith(_StubHealthCoachData.new),
          nexusLabProvider.overrideWith(_StubNexusLab.new),
        ],
        child: const MaterialApp(home: CharacterPage()),
      ),
    );

    await tester.pump();

    expect(find.text('Journey'), findsOneWidget);
  });
}

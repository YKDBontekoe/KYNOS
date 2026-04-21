import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/repositories/biomechanics_repository.dart';
import 'package:kynos/features/nexus_lab/presentation/nexus_lab_page.dart';
import 'package:kynos/shared/providers/biomechanics_provider.dart';

void main() {
  testWidgets('renders Nexus Lab page', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          biomechanicsRepositoryProvider.overrideWithValue(
            _FakeBiomechanicsRepository(),
          ),
        ],
        child: const MaterialApp(home: NexusLabPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('KYNOS Lab'), findsOneWidget);
    expect(find.text('Run Calibration'), findsOneWidget);
  });
}

class _FakeBiomechanicsRepository implements BiomechanicsRepository {
  @override
  ({double? b0, double? b1, double? b2}) get coefficients =>
      (b0: 0.1, b1: 0.2, b2: 0.3);

  @override
  Future<({double? prediction, Failure? failure})> infer({
    required double cadenceSpm,
    required double powerWatts,
  }) async {
    return (prediction: 1.0, failure: null);
  }

  @override
  Future<Failure?> restore() async => null;

  @override
  Future<Failure?> save() async => null;

  @override
  Future<Failure?> train(List<BiomechanicsSample> samples) async => null;
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/gamification/trail_node.dart';
import 'package:kynos/domain/usecases/gamification/generate_daily_trail_usecase.dart';

void main() {
  const useCase = GenerateDailyTrailUseCase();
  final date = DateTime(2026, 7, 6);

  test('generates deterministic trail for same date and level', () {
    final a = useCase(characterLevel: 5, date: date);
    final b = useCase(characterLevel: 5, date: date);

    expect(a.length, 7);
    expect(a.map((n) => n.type).toList(), b.map((n) => n.type).toList());
  });

  test('sunday trail ends with boss node', () {
    final sunday = DateTime(2026, 7, 5);
    final nodes = useCase(characterLevel: 10, date: sunday);

    expect(nodes.last.type, TrailNodeType.boss);
  });

  test('weekday trail has treasure nodes', () {
    final nodes = useCase(characterLevel: 10, date: date);

    expect(nodes.any((n) => n.type == TrailNodeType.treasure), isTrue);
    expect(nodes.first.type, TrailNodeType.start);
  });
}

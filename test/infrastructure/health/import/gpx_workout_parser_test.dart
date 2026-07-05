import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/infrastructure/health/import/gpx_workout_parser.dart';

void main() {
  group('GpxWorkoutParser', () {
    const parser = GpxWorkoutParser();

    test('parses valid GPX with timestamps and route points', () {
      const gpx = '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1">
  <trk>
    <trkseg>
      <trkpt lat="37.7749" lon="-122.4194">
        <time>2026-04-20T07:00:00Z</time>
      </trkpt>
      <trkpt lat="37.7755" lon="-122.4180">
        <time>2026-04-20T07:30:00Z</time>
      </trkpt>
    </trkseg>
  </trk>
</gpx>
''';

      final result = parser.parse(gpx);

      expect(result.routePoints, hasLength(2));
      expect(result.workout.workoutType, 'running');
      expect(result.workout.distanceMeters, greaterThan(0));
      expect(result.workout.start, DateTime.utc(2026, 4, 20, 7));
      expect(result.workout.end, DateTime.utc(2026, 4, 20, 7, 30));
      expect(result.workout.id.startsWith('import:'), isTrue);
    });

    test('throws when GPX has no track points', () {
      const gpx = '<?xml version="1.0"?><gpx></gpx>';

      expect(() => parser.parse(gpx), throwsFormatException);
    });

    test('parses points without timestamps', () {
      const gpx = '''
<gpx>
  <trk>
    <trkseg>
      <trkpt lat="51.5" lon="-0.1"/>
      <trkpt lat="51.51" lon="-0.11"/>
    </trkseg>
  </trk>
</gpx>
''';

      final result = parser.parse(gpx);

      expect(result.routePoints, hasLength(2));
      expect(result.workout.distanceMeters, greaterThan(0));
    });
  });
}

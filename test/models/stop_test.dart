import 'package:flutter_test/flutter_test.dart';
import 'package:swiss_departure_board/models/stop.dart';

void main() {
  group('Stop.fromJson', () {
    test('parses all fields from a well-formed API response', () {
      final json = {
        'id': '8503000',
        'name': 'Zürich HB',
        'coordinate': {'x': 47.378177, 'y': 8.540192},
        'distance': 320,
      };

      final stop = Stop.fromJson(json);

      expect(stop.id, equals('8503000'));
      expect(stop.name, equals('Zürich HB'));
      expect(stop.latitude, closeTo(47.378177, 0.000001));
      expect(stop.longitude, closeTo(8.540192, 0.000001));
      expect(stop.distance, equals(320));
    });

    test('handles missing coordinate gracefully (defaults to 0.0)', () {
      final json = {
        'id': '1234',
        'name': 'Test Stop',
      };

      final stop = Stop.fromJson(json);

      expect(stop.latitude, equals(0.0));
      expect(stop.longitude, equals(0.0));
      expect(stop.distance, isNull);
    });

    test('toJson round-trips back to the original stop via fromJson', () {
      const original = Stop(
        id: '8503000',
        name: 'Zürich HB',
        latitude: 47.378177,
        longitude: 8.540192,
        distance: 500,
      );

      final restored = Stop.fromJson(original.toJson());

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.latitude, closeTo(original.latitude, 0.000001));
      expect(restored.longitude, closeTo(original.longitude, 0.000001));
      expect(restored.distance, equals(original.distance));
    });

    test('equality is based on id and name', () {
      const a = Stop(id: '1', name: 'A', latitude: 0, longitude: 0);
      const b = Stop(id: '1', name: 'A', latitude: 1, longitude: 1);
      const c = Stop(id: '2', name: 'A', latitude: 0, longitude: 0);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}

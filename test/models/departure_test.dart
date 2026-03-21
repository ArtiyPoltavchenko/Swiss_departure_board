import 'package:flutter_test/flutter_test.dart';
import 'package:swiss_departure_board/models/departure.dart';

void main() {
  group('Departure.fromStationboardEntry', () {
    test('parses all fields from a well-formed stationboard entry', () {
      final json = {
        'stop': {
          'departure': '2040-01-15T10:30:00+0000',
          'platform': '3',
          'prognosis': {
            'departure': '2040-01-15T10:32:00+0000',
          },
        },
        'to': 'Wollishofen',
        'category': 'T',
        'number': '7',
        'name': 'Tram 7',
      };

      final d = Departure.fromStationboardEntry(json);

      expect(d.line, equals('7'));
      expect(d.destination, equals('Wollishofen'));
      expect(d.category, equals('tram'));
      expect(d.platform, equals('3'));
      expect(d.hasDisruption, isFalse);
      expect(d.scheduledTime, equals(DateTime.parse('2040-01-15T10:30:00+0000')));
      expect(d.estimatedTime, equals(DateTime.parse('2040-01-15T10:32:00+0000')));
    });

    test('falls back to scheduledTime when estimatedTime is absent', () {
      final json = {
        'stop': {
          'departure': '2040-06-01T08:00:00+0000',
          'prognosis': {},
        },
        'to': 'Bern',
        'category': 'IC',
        'number': '5',
      };

      final d = Departure.fromStationboardEntry(json);

      expect(d.estimatedTime, isNull);
      // minutesUntil must use scheduledTime — result should be positive
      expect(d.minutesUntil, greaterThan(0));
    });

    test('minutesUntil returns 0 when time is in the past', () {
      final pastTime =
          DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String();
      final json = {
        'stop': {'departure': pastTime, 'prognosis': {}},
        'to': 'Basel',
        'category': 'IC',
        'number': '1',
      };

      final d = Departure.fromStationboardEntry(json);

      expect(d.minutesUntil, equals(0));
      expect(d.isDeparting, isTrue);
    });

    test('normalises empty platform string to null', () {
      // Fixed: API returns "" for stops without a platform. Previously this
      // showed "Pl. " in the UI instead of hiding the sub-label.
      final json = {
        'stop': {
          'departure':
              DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
          'platform': '',
          'prognosis': {},
        },
        'to': 'Bern',
        'category': 'IC',
        'number': '1',
      };

      final d = Departure.fromStationboardEntry(json);
      expect(d.platform, isNull);
    });

    test('uses estimatedTime over scheduledTime for minutesUntil', () {
      final scheduled = DateTime.now().add(const Duration(minutes: 10));
      final estimated = DateTime.now().add(const Duration(minutes: 15));
      final json = {
        'stop': {
          'departure': scheduled.toIso8601String(),
          'prognosis': {'departure': estimated.toIso8601String()},
        },
        'to': 'Lausanne',
        'category': 'IR',
        'number': '17',
      };

      final d = Departure.fromStationboardEntry(json);

      // minutesUntil should reflect estimated (+15 min), not scheduled (+10)
      expect(d.minutesUntil, greaterThanOrEqualTo(14));
    });

    test('category normalisation covers all real API uppercase values', () {
      // Real API sends these UPPERCASE values — verify each maps correctly.
      // Fixed: RE, BAT, FUN, GB were previously missing and fell through to
      // the default, returning the raw lowercase string instead of the
      // normalised category used by DepartureTile color logic.
      expect(_departureWithCategory('T').category, equals('tram'));
      expect(_departureWithCategory('BUS').category, equals('bus'));
      expect(_departureWithCategory('IC').category, equals('train'));
      expect(_departureWithCategory('IR').category, equals('train'));
      expect(_departureWithCategory('RE').category, equals('train'));
      expect(_departureWithCategory('S').category, equals('train'));
      expect(_departureWithCategory('BAT').category, equals('ship'));
      expect(_departureWithCategory('FUN').category, equals('cableway'));
      expect(_departureWithCategory('GB').category, equals('cableway'));
      expect(_departureWithCategory('UNKNOWN').category, equals('unknown'));

      // Legacy lowercase inputs (from cached data) still work.
      expect(_departureWithCategory('tram').category, equals('tram'));
      expect(_departureWithCategory('bus').category, equals('bus'));
      expect(_departureWithCategory('ship').category, equals('ship'));
    });
  });
}

Departure _departureWithCategory(String category) {
  final json = {
    'stop': {
      'departure': DateTime.now()
          .add(const Duration(minutes: 30))
          .toIso8601String(),
      'prognosis': {},
    },
    'to': 'Test',
    'category': category,
    'number': '1',
  };
  return Departure.fromStationboardEntry(json);
}

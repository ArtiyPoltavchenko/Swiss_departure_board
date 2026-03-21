import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:swiss_departure_board/services/exceptions.dart';
import 'package:swiss_departure_board/services/location_service.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Creates a fake [Position] for use in tests.
Position _fakePosition({double lat = 47.378177, double lng = 8.540192}) =>
    Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      accuracy: 5.0,
      altitude: 408.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('LocationService', () {
    test('returns coordinates from an injected position getter', () async {
      final service = LocationService(
        positionGetter: () async => _fakePosition(lat: 46.9480, lng: 7.4474),
      );

      final (lat, lng) = await service.getCurrentPosition();

      expect(lat, closeTo(46.9480, 0.0001));
      expect(lng, closeTo(7.4474, 0.0001));
    });

    test('propagates LocationTimeoutException from the getter', () async {
      final service = LocationService(
        positionGetter: () async {
          throw const LocationTimeoutException();
        },
      );

      expect(
        () => service.getCurrentPosition(),
        throwsA(isA<LocationTimeoutException>()),
      );
    });

    test('propagates LocationPermissionDeniedException from the getter',
        () async {
      final service = LocationService(
        positionGetter: () async {
          throw const LocationPermissionDeniedException();
        },
      );

      expect(
        () => service.getCurrentPosition(),
        throwsA(isA<LocationPermissionDeniedException>()),
      );
    });
  });
}

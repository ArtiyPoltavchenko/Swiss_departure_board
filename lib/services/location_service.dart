import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'exceptions.dart';

/// Riverpod provider for [LocationService].
final locationServiceProvider =
    Provider<LocationService>((_) => LocationService());

/// Typedef for injecting a custom position getter (used in tests).
typedef PositionGetter = Future<Position> Function();

/// Wrapper around the geolocator package.
///
/// Requests permission if needed and returns the device's current position.
/// In tests, inject a [PositionGetter] to avoid touching real device APIs.
class LocationService {
  final PositionGetter? _positionGetter;

  LocationService({PositionGetter? positionGetter})
      : _positionGetter = positionGetter;

  /// Returns the current position as a `(latitude, longitude)` record.
  ///
  /// Throws [LocationPermissionDeniedException] if access is denied.
  /// Throws [LocationServiceDisabledException] if GPS is off.
  /// Throws [LocationTimeoutException] if position cannot be obtained within
  /// 15 seconds.
  Future<(double, double)> getCurrentPosition() async {
    if (_positionGetter == null) {
      // Check service enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationServiceDisabledException();
      }

      // Request / check permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw const LocationPermissionDeniedException();
      }
    }

    try {
      final position = await (_positionGetter != null
              ? _positionGetter!()
              : Geolocator.getCurrentPosition(
                  locationSettings: const LocationSettings(
                    accuracy: LocationAccuracy.high,
                    timeLimit: Duration(seconds: 15),
                  ),
                ))
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw const LocationTimeoutException(),
      );

      return (position.latitude, position.longitude);
    } on LocationTimeoutException {
      rethrow;
    } on LocationPermissionDeniedException {
      rethrow;
    } on LocationServiceDisabledException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw const LocationTimeoutException();
      }
      rethrow;
    }
  }
}

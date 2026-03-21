import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/stop.dart';
import '../services/location_service.dart';
import '../services/preferences.dart';
import '../services/transport_api.dart';

/// Exposes the list of nearby stops as [AsyncValue<List<Stop>>].
///
/// Starts empty; call [StopNotifier.fetchNearbyStops] to load.
final stopProvider =
    AsyncNotifierProvider<StopNotifier, List<Stop>>(StopNotifier.new);

class StopNotifier extends AsyncNotifier<List<Stop>> {
  @override
  Future<List<Stop>> build() async => const [];

  /// Geolocates the device and loads nearby stops from the API.
  Future<void> fetchNearbyStops() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final location = ref.read(locationServiceProvider);
      final api = ref.read(transportApiProvider);
      final (lat, lng) = await location.getCurrentPosition();
      return api.getNearbyStops(lat, lng);
    });
  }

  /// Restores the last used stop from SharedPreferences.
  Future<Stop?> loadLastStop() async {
    final prefs = ref.read(preferencesProvider);
    return prefs.loadLastStop();
  }

  /// Persists [stop] as the last selected stop.
  Future<void> saveLastStop(Stop stop) async {
    final prefs = ref.read(preferencesProvider);
    await prefs.saveLastStop(stop);
  }
}

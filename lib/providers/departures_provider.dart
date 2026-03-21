import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/departure.dart';
import 'settings_provider.dart';
import '../services/transport_api.dart';

/// Exposes departures for a given station ID as [AsyncValue<List<Departure>>].
///
/// Uses `FutureProvider.family` so it can be keyed by station ID.
/// The departure limit is read from [settingsProvider].
final departuresProvider =
    FutureProvider.family<List<Departure>, String>((ref, stationId) async {
  final api = ref.read(transportApiProvider);
  final settings = ref.watch(settingsProvider);

  // Re-fetch whenever the departure count setting changes.
  final limit = switch (settings) {
    AsyncData(:final value) => value.departureCount,
    _ => 10,
  };

  return api.getDepartures(stationId, limit: limit);
});

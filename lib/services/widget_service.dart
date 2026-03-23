import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/departure.dart';
import '../models/stop.dart';
import 'transport_api.dart';

/// Fully static service that feeds data to the Android home screen widget.
///
/// Runs in two contexts:
/// - Foreground: called by the app when the user selects a stop.
/// - Background: called by WorkManager every ~15 minutes.
///
/// Both contexts share identical logic — read last stop from SharedPreferences,
/// fetch top-4 departures, write widget keys, trigger RemoteViews refresh.
class WidgetService {
  WidgetService._();

  /// SharedPreferences key where the app stores the last selected stop JSON.
  /// Must match the key used in [Preferences] (lib/services/preferences.dart).
  static const _keyLastStop = 'last_stop';

  /// Qualified class name of the Kotlin AppWidgetProvider.
  static const _providerClass =
      'ch.swissdeparture.swiss_departure_board.HomeWidgetProvider';

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Fetches the latest departures and writes them to SharedPreferences so the
  /// home screen widget can display them.
  ///
  /// Never throws — all errors are caught and ignored silently so that a failed
  /// background task does not crash WorkManager.
  static Future<void> updateWidgetData() async {
    try {
      final stop = await _resolveStop();
      if (stop == null) return;

      final api = TransportApi();
      final departures = await api.getDepartures(stop.id, limit: 4);

      await _writeWidgetData(stop.name, departures);
      await HomeWidget.updateWidget(
        qualifiedAndroidName: _providerClass,
      );
    } catch (_) {
      // Silent fail: widget stays stale rather than crashing.
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Returns the stop to display.
  ///
  /// Priority:
  /// 1. Last stop saved by the app (SharedPreferences).
  /// 2. Nearest stop via geolocation (best-effort, often unavailable in BG).
  static Future<Stop?> _resolveStop() async {
    // Try saved stop first (most reliable in background).
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyLastStop);
    if (raw != null) {
      try {
        return Stop.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {}
    }

    // Fallback: attempt geolocation (may fail in background context).
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 10),
      );
      final api = TransportApi();
      final stops = await api.getNearbyStops(pos.latitude, pos.longitude, limit: 1);
      return stops.isNotEmpty ? stops.first : null;
    } catch (_) {
      return null;
    }
  }

  /// Writes all widget SharedPreferences keys for the given [departures].
  static Future<void> _writeWidgetData(
    String stopName,
    List<Departure> departures,
  ) async {
    await HomeWidget.saveWidgetData<String>('widget_stop_name', stopName);
    await HomeWidget.saveWidgetData<int>(
        'widget_departure_count', departures.length);

    for (var i = 0; i < 4; i++) {
      if (i < departures.length) {
        final d = departures[i];
        final time = d.isDeparting ? 'Now' : '${d.minutesUntil} min';
        await HomeWidget.saveWidgetData<String>(
            'widget_departure_${i}_line', d.line);
        await HomeWidget.saveWidgetData<String>(
            'widget_departure_${i}_dest', d.destination);
        await HomeWidget.saveWidgetData<String>(
            'widget_departure_${i}_time', time);
        await HomeWidget.saveWidgetData<String>(
            'widget_departure_${i}_color', _categoryColor(d.category));
      } else {
        // Clear rows beyond the actual departure count.
        await HomeWidget.saveWidgetData<String>(
            'widget_departure_${i}_line', '');
        await HomeWidget.saveWidgetData<String>(
            'widget_departure_${i}_dest', '');
        await HomeWidget.saveWidgetData<String>(
            'widget_departure_${i}_time', '');
        await HomeWidget.saveWidgetData<String>(
            'widget_departure_${i}_color', '#666666');
      }
    }
  }

  /// Maps a departure category to the hex badge color used in the widget.
  /// Mirrors the color logic in DepartureTile and HomeWidgetProvider.kt.
  static String _categoryColor(String category) {
    switch (category) {
      case 'tram':
        return '#e20000';
      case 'bus':
        return '#0063b6';
      case 'train':
        return '#333333';
      case 'ship':
        return '#00857c';
      case 'cableway':
        return '#8b5e3c';
      default:
        return '#666666';
    }
  }
}

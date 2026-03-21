import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/stop.dart';

/// Riverpod provider for [Preferences].
final preferencesProvider = Provider<Preferences>((_) => Preferences());

/// Keys used in SharedPreferences.
abstract final class _Keys {
  static const lastStop = 'last_stop';
  static const departureCount = 'departure_count';
  static const locale = 'locale';
  static const refreshInterval = 'refresh_interval';
}

/// Wrapper around SharedPreferences for app settings and last-used stop.
class Preferences {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ---------------------------------------------------------------------------
  // Last selected stop
  // ---------------------------------------------------------------------------

  Future<Stop?> loadLastStop() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_Keys.lastStop);
    if (raw == null) return null;
    try {
      return Stop.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLastStop(Stop stop) async {
    final prefs = await _prefs;
    await prefs.setString(_Keys.lastStop, jsonEncode(stop.toJson()));
  }

  // ---------------------------------------------------------------------------
  // Departure count
  // ---------------------------------------------------------------------------

  Future<int> loadDepartureCount() async {
    final prefs = await _prefs;
    return prefs.getInt(_Keys.departureCount) ?? 10;
  }

  Future<void> saveDepartureCount(int count) async {
    final prefs = await _prefs;
    await prefs.setInt(_Keys.departureCount, count);
  }

  // ---------------------------------------------------------------------------
  // Locale
  // ---------------------------------------------------------------------------

  Future<String> loadLocale() async {
    final prefs = await _prefs;
    return prefs.getString(_Keys.locale) ?? 'de';
  }

  Future<void> saveLocale(String locale) async {
    final prefs = await _prefs;
    await prefs.setString(_Keys.locale, locale);
  }

  // ---------------------------------------------------------------------------
  // Auto-refresh interval
  // ---------------------------------------------------------------------------

  Future<int> loadRefreshInterval() async {
    final prefs = await _prefs;
    return prefs.getInt(_Keys.refreshInterval) ?? 30;
  }

  Future<void> saveRefreshInterval(int seconds) async {
    final prefs = await _prefs;
    await prefs.setInt(_Keys.refreshInterval, seconds);
  }
}

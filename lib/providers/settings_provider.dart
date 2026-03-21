import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/preferences.dart';

/// Immutable snapshot of user-configurable settings.
class AppSettings {
  final int departureCount;
  final String locale;

  /// Auto-refresh interval in seconds. Supported values: 15, 30, 60, 120.
  final int refreshIntervalSeconds;

  const AppSettings({
    this.departureCount = 10,
    this.locale = 'de',
    this.refreshIntervalSeconds = 30,
  });

  AppSettings copyWith({
    int? departureCount,
    String? locale,
    int? refreshIntervalSeconds,
  }) =>
      AppSettings(
        departureCount: departureCount ?? this.departureCount,
        locale: locale ?? this.locale,
        refreshIntervalSeconds:
            refreshIntervalSeconds ?? this.refreshIntervalSeconds,
      );
}

/// Exposes app settings as [AsyncValue<AppSettings>].
///
/// Loads from SharedPreferences on first read.
/// Use the notifier methods to persist changes.
final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final prefs = ref.read(preferencesProvider);
    final count = await prefs.loadDepartureCount();
    final locale = await prefs.loadLocale();
    final interval = await prefs.loadRefreshInterval();
    return AppSettings(
      departureCount: count,
      locale: locale,
      refreshIntervalSeconds: interval,
    );
  }

  /// Updates the number of departures shown and persists the value.
  Future<void> setDepartureCount(int count) async {
    final prefs = ref.read(preferencesProvider);
    await prefs.saveDepartureCount(count);
    state = state.whenData((s) => s.copyWith(departureCount: count));
  }

  /// Updates the UI locale and persists the value.
  Future<void> setLocale(String locale) async {
    final prefs = ref.read(preferencesProvider);
    await prefs.saveLocale(locale);
    state = state.whenData((s) => s.copyWith(locale: locale));
  }

  /// Updates the auto-refresh interval and persists the value.
  Future<void> setRefreshInterval(int seconds) async {
    final prefs = ref.read(preferencesProvider);
    await prefs.saveRefreshInterval(seconds);
    state = state.whenData((s) => s.copyWith(refreshIntervalSeconds: seconds));
  }
}

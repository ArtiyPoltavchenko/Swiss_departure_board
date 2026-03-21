import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/preferences.dart';

/// Immutable snapshot of user-configurable settings.
class AppSettings {
  final int departureCount;
  final String locale;

  const AppSettings({
    this.departureCount = 10,
    this.locale = 'de',
  });

  AppSettings copyWith({int? departureCount, String? locale}) => AppSettings(
        departureCount: departureCount ?? this.departureCount,
        locale: locale ?? this.locale,
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
    return AppSettings(departureCount: count, locale: locale);
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
}
